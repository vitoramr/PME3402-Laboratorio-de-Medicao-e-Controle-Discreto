/*
=============================================================================
                        
                        Escola Politécnica da USP
         PME3402 - Laboratório de Medição e Controle Discreto
       --------------------------------------------------------------
      ATIVIDADE 6 - Medição e filtragem do sinal do sensor de distância
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
1) Certifique-se de que o Scilab está aberto na pasta "/Atividade 6/"
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
// PROJETO DO FILTRO DIGITAL
// =============================================================================
/*
A função de transferência em tempo contínuo de um filtro de 1ª ordem passa baixa
é dada por:
Y(s)      wc
---- = --------
E(s)    wc + s

Onde e --> sinal bruto
     y --> sinal filtrado
     wc --> frequência de corte do filtro
*/


Ts = 0.015;     // Período de amostragem do sinal (s) (média dos períodos de medição do exercício anterior)
fs = 1/Ts;      // Frequência de amostragem do sinal (Hz)
fc = 2;         // Frequência de corte do filtro (Hz)
wc = 2*%pi*fc;  // Frequência de corte do filtro (rad/s)

s=poly(0,'s');
z=poly(0,'z');
H_filtro_c = syslin('c',wc/(s+wc));       // Função de transferência em tempo contínuo
SS_filtro_c = tf2ss(H_filtro_c);         // Transforma a função de transferência em espaço de estados
SS_filtro_d = cls2dls(SS_filtro_c, Ts); // Transforma o sistema contínuo em discreto pelo método bilinear
H_filtro_d = ss2tf(SS_filtro_d);         // Função de transferência em tempo discreto

disp("Função de transferência em tempo discreto do filtro digital de 1ª ordem passa-baixa")
disp(H_filtro_d)

/*
Após a transformação bi-linear a função de transferência do Filtro Digital é dada por:

    Y(z)       Ce_1 +Ce_0*z       Ce_1*z^-1 + Ce_0
    ----  =   --------------  =  ------------------
    E(z)         Cy_1 + z           Cy_1*z^-1 + 1

E a equação de diferenças do filtro digital é dada por:
    y[k] = Ce_0*e[k] +Ce_1*e[k-1] - Cy_1*y[k-1]
    
Analiticamente, pelo "Tópico 04 – Filtros Digitais", os coeficientes da aproximação bilinear
para a função de transferência do filtro são dados por

Cy_1 =  -(1 - (wc*T)/2) / (1 + (wc*T)/2);
Ce_0 = Ce_1 = ((wc*T)/2) / (1 + (wc*T)/2);
*/

// Conferindo os coeficientes analíticos e calculados:
Cy_1 =  -(1 - (wc*Ts)/2) / (1 + (wc*Ts)/2);
Ce_0 = ((wc*Ts)/2) / (1 + (wc*Ts)/2);
Ce_1 = Ce_0;

[kA] =coeff(H_filtro_d.num);  // Coeficientes do numerador
[kB] =coeff(H_filtro_d.den);  // Coeficientes do denominador

kA = kA ./ kB($);          // Normaliza-se os coeficientes do polinômio
kB = kB ./ kB($);          // Normaliza-se os coeficientes do polinômio

err1 = abs(Ce_1 - kA(1))
err2 = abs(Ce_0 - kA(2))
err3 = abs(Cy_1 - kB(1))

disp("Diferença entre os coeficientes analíticos e os calculados")
disp(err1,err2,err3)

/*
Verifica-se que os coeficientes obtidos pela função de transferência são coerentes
com a expressão analítica, já que:

err1 = abs(Ce_1 - kA(1)) == 1.665D-16
err2 = abs(Ce_0 - kA(2)) == 5.551D-17
err3 = abs(Cy_1 - kB(1)) == 5.551D-17
*/


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
    base_path = pwd(); // Diretório atual onde o Scilab está aberto
    s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)
    
    data_directory = base_path + s + data_folder;
    sensor   = csvRead(data_directory + s + filename, ',','.','double', [], [], [], 1 );
    
    t = sensor(:,1) / 1000; // Sinal está em ms, e passa-o para s
    d = sensor(:,2);        // Sinal do sensor em cm
    u = sensor(:,3)*5/255;  // Sinal tem a tensão entre 0 e 255, e passa-a para 0V a 5V
    
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


function [y] = filtro_passa_baixa(e)
        y = zeros(e);
        y(1) = e(1);
        
        for k =2:length(e)
            y(k) = -Cy_1*y(k-1) + Ce_1*e(k-1) + Ce_0*e(k);
        end
endfunction

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

d_1_filtrado = filtro_passa_baixa(d1);
d_2_filtrado = filtro_passa_baixa(d2);
d_3_filtrado = filtro_passa_baixa(d3);
d_4_filtrado = filtro_passa_baixa(d4);

// Analise espectral
// Medição 1
[f1,psd_d1] = spectral_treatment(d1,fa1);
[# ,psd_u1] = spectral_treatment(u1,fa1);
[# ,psd_d1_filtrado] = spectral_treatment(d_1_filtrado,fa1);
[f1_trim, psd_d1_trim] = spectral_treatment(d1_trim ,fa1); // PSD do vetor "Cortado"

// Medição 2
[f2,psd_d2] = spectral_treatment(d2,fa2);
[# ,psd_u2] = spectral_treatment(u2,fa2);
[# ,psd_d2_filtrado] = spectral_treatment(d_2_filtrado,fa2);
[f2_trim, psd_d2_trim] = spectral_treatment( d2_trim ,fa2); // PSD do vetor "Cortado"

// Medição 3
[f3,psd_d3] = spectral_treatment(d3,fa3);
[# ,psd_u3] = spectral_treatment(u3,fa3);
[# ,psd_d3_filtrado] = spectral_treatment(d_3_filtrado,fa3);
[f3_trim, psd_d3_trim] = spectral_treatment( d3_trim ,fa3); // PSD do vetor "Cortado"

// Medição 4
[f4,psd_d4] = spectral_treatment(d4,fa4);
[# ,psd_u4] = spectral_treatment(u4,fa4);
[# ,psd_d4_filtrado] = spectral_treatment(d_4_filtrado,fa4);
[f4_trim, psd_d4_trim] = spectral_treatment( d4_trim ,fa4); // PSD do vetor "Cortado"


// =============================================================================
//                         PLOTAGEM DOS GRÁFICOS
// =============================================================================

cores = [
'blue4',        // 1
'deepskyblue3', // 2
'aquamarine3',  // 3
'springgreen4', // 4
'gold3',        // 5
'firebrick1',   // 6
'magenta3',     // 7
]


fig1 = scf(1);
    plot2d(t1, d1, style = color(cores(2)) );
    plot2d(t1, d_1_filtrado , style = color(cores(7)) );
    title('Distância captada pelo ultrassom na medição 1');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    hl= legend(['Sinal medido';'Sinal filtrado']);

fig2 = scf(2);
    plot2d(t2, d2, style = color(cores(2)) );
    plot2d(t2, d_2_filtrado , style = color(cores(7)) );
    title('Distância captada pelo ultrassom na medição 2');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    hl= legend(['Sinal medido';'Sinal filtrado']);

fig3 = scf(3);
    plot2d(t3, d3, style = color(cores(2)) );
    plot2d(t3, d_3_filtrado , style = color('red') );
    title('Distância captada pelo ultrassom na medição 3');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    hl= legend(['Sinal medido';'Sinal filtrado']);
    
fig4 = scf(4);
    plot2d(t4, d4, style = color(cores(2)) );
    plot2d(t4, d_4_filtrado , style = color(cores(7)) );
    title('Distância captada pelo ultrassom na medição 4');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    hl= legend(['Sinal medido';'Sinal filtrado']);
/*
fig4 = scf(5);
    subplot(3,1,1)
    plot2d('nl',f3, psd_d3, style = color(cores(5)) );
    title('Espectro de frequência da distância bruta do sensor na medição 3');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    subplot(3,1,2)
    plot2d('nl',f3, psd_d3_filtrado, style = color(cores(5)) );
    title('Espectro de frequência da distância bruta do sensor na medição 3');
    ylabel("PSD");
    xlabel("f(Hz)");
    
    subplot(3,1,3)
    plot2d('nl',f3, psd_d3_filtrado, style = color(cores(5)) );
    title('Espectro de frequência da distância bruta do sensor na medição 3');
    ylabel("PSD");
    xlabel("f(Hz)");
