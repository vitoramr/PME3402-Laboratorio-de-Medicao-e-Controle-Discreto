/*
=============================================================================
                        
                        Escola Politécnica da USP
         PME3402 - Laboratório de Medição e Controle Discreto
       --------------------------------------------------------------
            ATIVIDADE 4 - CONTROLE DE MOTOR POR PID DISCRETO
       --------------------------------------------------------------
                                GRUPO 13
                                Membros:
                      Tiago Vieira de Campos Krause
                        Vinicius Rosario Dyonisio
                    Vítor Albuquerque Maranhao Ribeiro
                          Vitória Garcia Bittar
                       
       --------------------------------------------------------------
                        Professores responsáveis:
                         Edilson Hiroshi Tamai
                              Flávio Trigo
                              
=============================================================================

Esse programa foi desenvolvido no Scilab 6.1

INSTRUÇÕES PARA RODAR O PROGRAMA
Antes de rodar o programa, siga os seguintes passos
1) Certifique-se de que o Scilab está aberto na pasta "/Atividade 5/"
em que o programa se encontra
2) Certifique-se de que os dados do sensor Ultrassônico estão na pasta
"/Atividade 5/Processing_save_serial" dentro da pasta do programa
3) Rode o programa
*/

//LIMPEZA DE MEMÓRIA
clear;
clc;    // Limpeza de variáveis e do console
xdel(winsid()); // Fecha as janelas abertas

// =============================================================================
// CARREGAMENTO DOS DADOS
// =============================================================================

// Lendo arquivos
data_folder = 'Processing_save_serial'

file_names = [
    'Leitura_Sensor_10_14_15_35_4.csv',  // T = 2, Sinal varia de 0 a 5V ( velocidade = (255/2)*sin(w*t) + (255/2) )
    'Leitura_Sensor_10_14_15_39_44.csv', // T = 2, Sinal varia de 0 a 5V ( velocidade = (255/2)*sin(w*t) + (255/2) )
    'Leitura_Sensor_10_14_15_49_25.csv', // T = 1, Sinal da velocidade = 105 + 50*sin(w*t)
    'Leitura_Sensor_10_14_15_52_23.csv', // T = 0.5 , Sinal varia de 0 a 5V ( velocidade = (255/2)*sin(w*t) + (255/2) )
];

//Ordem de chamada: csvRead(filename, separator, decimal, conversion, substitute, regexpcomments, range, header)
function [t,d,u] = data_read(data_folder,filename, plot_signal)
    // Obtendo os caminhos de cada arquivo do experimento
    base_path = pwd(); // Diretório atual onde o programa está
    s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)
    
    data_directory = base_path + s + data_folder;
    sensor   = csvRead(data_directory + s + filename, ',','.','double', [], [], [], 1 );
    
    t = sensor(:,1) / 1000; // Sinal está em ms
    d = sensor(:,2);        // Sinal do sensor em cm
    u = sensor(:,3)*5/255;  // Sinal tem a tensão entre 0 --> 0V e 255 --> 5V
    
    // Plotagem dos gráficos individuais
    if plot_signal then
        cores = [
            'blue4',
            'deepskyblue3',
            'aquamarine3',
            'springgreen4',
            'gold3',
            'firebrick1',
            'magenta3',
        ]
        scf();
            subplot(2,1,1)
            fig = gca();
            plot2d(t,d, style = color(cores(1)) );
            title('Distância lida pelo ultrassom (cm)');
            ylabel("d (cm)");
            xlabel("tempo(s)");
        
            subplot(2,1,2)
            plot2d(t,u, style = color(cores(1)) );
            title('Tensão enviada ao motor');
            ylabel("Tensão (V)");
            xlabel("tempo(s)");
    end
endfunction

plot_na_funcao = %F; // %T para True ou %F para False

[t1,d1,u1] = data_read(data_folder, file_names(1), plot_na_funcao);
[t2,d2,u2] = data_read(data_folder, file_names(2), plot_na_funcao);
[t3,d3,u3] = data_read(data_folder, file_names(3), plot_na_funcao);
[t4,d4,u4] = data_read(data_folder, file_names(4), plot_na_funcao);

// Analisando a frequência de amostragem do sinal do sensor
fa_t1 = 1.0 ./ ( t1(2:$,1) - t1(1:$-1,1) ) // Diferença entre um instante e outro
fa_t2 = 1.0 ./ ( t2(2:$,1) - t2(1:$-1,1) ) // Diferença entre um instante e outro
fa_t3 = 1.0 ./ ( t3(2:$,1) - t3(1:$-1,1) ) // Diferença entre um instante e outro
fa_t4 = 1.0 ./ ( t4(2:$,1) - t4(1:$-1,1) ) // Diferença entre um instante e outro

// Frequência de amostragem
// Como a frequência de amostragem tem grande variação, assume-se fa como a média
// dos valores dos vetores (fa_t).
// Foi testado, também, calcular a frequ~encia de amostragem como a média do
// vetor de frequências sem contar os valores estourados de f, mas houve muito
// pouca diferença em relação ao valor usado.
fa1 = mean(fa_t1);
fa2 = mean(fa_t2);
fa3 = mean(fa_t3);
fa4 = mean(fa_t4);

// Para lidar com os outliers, remove-se medições anômalas do sensor (Trimming Outliers)
max_dist = 70; // Valor máximo para contabilizar a distância
                // Se a distância for maior do que esse valor, exclui-se a distância

t1_trim = t1(d1<max_dist)
d1_trim = d1(d1<max_dist)

t2_trim = t2(d2<max_dist)
d2_trim = d2(d2<max_dist)

t3_trim = t3(d3<max_dist)
d3_trim = d3(d3<max_dist)

t4_trim = t4(d4<max_dist)
d4_trim = d4(d4<max_dist)

// Análise espectral dos sinais
function [f, psd] = spectral_treatment(signal_t,fs)
    /*
    Inputs:
    sinat_t --> um vetor unidimensional sinal_t (Nx1) que representa o valor de um
    sinal temporal
    fs      --> um valor real que representa a frequência de amostragem do sinal em Hz
    
    Outputs:
    f    --> vetor (N/2 x 1) de números reais com a escala de frequência do sinal em Hz
    psd  --> vetor (N/2 x 1) de números reais com a densidade espectral de potência do sinal temporal
    */
    
    N = length(signal_t);
    
    spectrum_f = fft(signal_t);
    
    spectrum_f = spectrum_f(1:N/2+1); // Como a fft é simétrica, pega-se metade do vetor
    
    psd = (1/(fs*N)) * ( abs(spectrum_f) ).^2 ; // PSD --> densidade espectral de potência
    psd(2:$-1) = 2*psd(2:$-1);
    
    f = (fs /N)*(0:N/2)'                    // Escala de frequências
endfunction

// Medição 1
[f1,psd_d1] = spectral_treatment(d1,fa1);
[# ,psd_u1] = spectral_treatment(u1,fa1);

[f1_trim, psd_d1_trim] = spectral_treatment(d1_trim ,fa1); // PSD do vetor "Cortado"

// Medição 2
[f2,psd_d2] = spectral_treatment(d2,fa2);
[# ,psd_u2] = spectral_treatment(u2,fa2);

[f2_trim, psd_d2_trim] = spectral_treatment( d2_trim ,fa2); // PSD do vetor "Cortado"

// Medição 3
[f3,psd_d3] = spectral_treatment(d3,fa3);
[# ,psd_u3] = spectral_treatment(u3,fa3);

[f3_trim, psd_d3_trim] = spectral_treatment( d3_trim ,fa3); // PSD do vetor "Cortado"

// Medição 4
[f4,psd_d4] = spectral_treatment(d4,fa4);
[# ,psd_u4] = spectral_treatment(u4,fa4);

[f4_trim, psd_d4_trim] = spectral_treatment( d4_trim ,fa4); // PSD do vetor "Cortado"

// =============================================================================
//                         ANÁLISE DOS RESULTADOS
// =============================================================================
/*
Sinal enviado ao motor para a medição 1:
T = 2s,  (f = 0.5Hz), Variando de 0V a 5V       ( velocidade = (255/2)*sin(w*t) + (255/2) )

Sinal enviado ao motor para a medição 2:
T = 2s,  (f = 0.5Hz), Variando de 0V a 5V       ( velocidade = (255/2)*sin(w*t) + (255/2) )

Sinal enviado ao motor para a medição 3:
T = 1s,  (f = 1  Hz), Variando de 1.07V a 3.04V ( velocidade = 105 + 50*sin(w*t) )

Sinal enviado ao motor para a medição 4:
T = 0.5s,(f = 2  Hz), Variando de 0V a 5V       ( velocidade = (255/2)*sin(w*t) + (255/2) )

As medições 1 e 2 foram nas condições do vídeo 1 (oscilando e batendo no "chão")
A medição 3 foi nas condições do vídeo 2 (oscilando sem bater)
Na medição 4, a bola ficou (não lembro?, eu acho que ela voou, mas caiu e não levantou mais. Acho que vou marcar mais um horário pra verificar como a bola ficou nessa posição)

[DADOS BRUTOS]
- fa e d --> picos de fa batem com os de d

[DADOS TRATADOS]
- Remover os outliers é uma maneira rudimentar de tratar os dados
- Resultados bons, mas podem ser melhor com um filtro

*/
// =============================================================================
//                         PLOTAGEM DOS GRÁFICOS
// =============================================================================

cores = [
'blue4',
'deepskyblue3',
'aquamarine3',
'springgreen4',
'gold3',
'firebrick1',
'magenta3',
]


fig1= scf(1);
    subplot(4,1,1)
    plot2d(t1, d1, style = color(cores(1)) );
    title('Distância captada pelo ultrassom na medição 1');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(4,1,2)
    plot2d(t1(2:$), fa_t1, style = color(cores(1)) );
    title('Frequência de amostragem do Arduino para a medição 1');
    ylabel("fs (Hz)");
    xlabel("Intervalo de medidas (s)");

    subplot(4,1,3)
    plot2d(t1_trim, d1_trim, style = color(cores(1)) ); // Plotando apenas entre 0 e max_dist
    title('Distância captada pelo ultrassom cortando outliers na medição 1');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(4,1,4)
    plot2d(t1,u1, style = color(cores(1)) );
    title('Tensão enviada ao motor na medição 1');
    ylabel("Tensão (V)");
    xlabel("tempo(s)");

    
fig2= scf(2);
    subplot(4,1,1)
    plot2d(t2, d2, style = color(cores(3)) ); // Plotando apenas entre 0 e 60
    title('Distância captada pelo ultrassom na medição 2');
    ylabel("d (cm)");
    xlabel("tempo(s)");

    subplot(4,1,2)
    plot2d(t2(2:$), fa_t2, style = color(cores(3)) );
    title('Frequência de amostragem do Arduino para a medição 2');
    ylabel("fs (Hz)");
    xlabel("Intervalo entre medidas (s)");

    subplot(4,1,3)
    plot2d(t2_trim,d2_trim, style = color(cores(3)) );
    title('Distância captada pelo ultrassom cortando outliers na medição 2');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(4,1,4)
    plot2d(t2,u2, style = color(cores(3)) );
    title('Tensão enviada ao motor na medição 2 ');
    ylabel("Tensão (V)");
    xlabel("tempo(s)");
    
    
fig3= scf(3);
    subplot(4,1,1)
    plot2d(t3, d3, style = color(cores(5)) ); // Plotando apenas entre 0 e 60
    title('Distância captada pelo ultrassom na medição 3');
    ylabel("d (cm)");
    xlabel("tempo(s)");

    subplot(4,1,2)
    plot2d(t3(2:$), fa_t3, style = color(cores(5)) );
    title('Frequência de amostragem do Arduino para a medição 3');
    ylabel("fs (Hz)");
    xlabel("Intervalo entre medidas (s)");
    
    subplot(4,1,3)
    plot2d(t3_trim,d3_trim, style = color(cores(5)) );
    title('Distância captada pelo ultrassom cortando outliers na medição 3');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(4,1,4)
    plot2d(t3,u3, style = color(cores(5)) );
    title('Tensão enviada ao motor na medição 3');
    ylabel("Tensão (V)");
    xlabel("tempo(s)");
    


fig4= scf(4);
    subplot(4,1,1)
    plot2d(t4, d4, style = color(cores(7)) );
    title('Distância captada pelo ultrassom na medição 4');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(4,1,2)
    plot2d(t4(2:$), fa_t4, style = color(cores(7)) );
    title('Frequência de amostragem do Arduino para a medição 4');
    ylabel("fs (Hz)");
    xlabel("Intervalo entre medidas (s)");
    
    subplot(4,1,3)
    plot2d(t4_trim,d4_trim, style = color(cores(7)) );
    title('Distância captada pelo ultrassom cortando outliers na medição 4');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(4,1,4)
    plot2d(t4,u4, style = color(cores(7)) );
    title('Tensão enviada ao motor na medição 4');
    ylabel("Tensão (V)");
    xlabel("tempo(s)");
    
    
fig5 = scf(5);
    subplot(3,1,1)
    plot2d('nl',f1, psd_d1, style = color(cores(1)) );
    title('Espectro de frequência da distância lida pelo Ultrassom na medição 1');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    subplot(3,1,2)
    plot2d('nl',f1_trim, psd_d1_trim, style = color(cores(1)) );
    title('Espectro de frequência da distância saturada do sensor na medição 1');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    subplot(3,1,3)
    plot2d('nl',f1, psd_u1, style = color(cores(1)) );
    title('Espectro de frequência da voltagem enviada ao motor na medição 1');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    
fig6 = scf(6);
    subplot(3,1,1)
    plot2d('nl',f2, psd_d2, style = color(cores(3)) );
    title('Espectro de frequência da distância bruta do sensor na medição 2');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    subplot(3,1,2)
    plot2d('nl',f2_trim, psd_d2_trim, style = color(cores(3)) );
    title('Espectro de frequência da distância saturada do sensor na medição 2');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    subplot(3,1,3)
    plot2d('nl',f2, psd_u2, style = color(cores(3)) );
    title('Espectro de frequência da voltagem enviada ao motor na medição 2');
    ylabel("PSD");
    xlabel("f(Hz)");

fig7 = scf(7);
    subplot(3,1,1)
    plot2d('nl',f3, psd_d3, style = color(cores(5)) );
    title('Espectro de frequência da distância bruta do sensor na medição 3');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    subplot(3,1,2)
    plot2d('nl',f3_trim, psd_d3_trim, style = color(cores(5)) );
    title('Espectro de frequência da distância saturada do sensor na medição 3');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    subplot(3,1,3)
    plot2d('nl',f3, psd_u3, style = color(cores(5)) );
    title('Espectro de frequência da voltagem enviada ao motor na medição 3');
    ylabel("PSD");
    xlabel("f(Hz)");

fig8 = scf(8);
    subplot(3,1,1)
    plot2d('nl',f4, psd_d4, style = color(cores(7)) );
    title('Espectro de frequência da distância bruta do sensor na medição 4');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    subplot(3,1,2)
    plot2d('nl',f4_trim, psd_d4_trim, style = color(cores(7)) );
    title('Espectro de frequência da distância saturada do sensor na medição 4');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    subplot(3,1,3)
    plot2d('nl',f4, psd_u4, style = color(cores(7)) );
    title('Espectro de frequência da voltagem enviada ao motor na medição 4');
    ylabel("PSD");
    xlabel("f(Hz)");
    


