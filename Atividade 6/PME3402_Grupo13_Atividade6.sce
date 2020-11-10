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
"/Atividade 6/Processing_save_serial" dentro da pasta do programa
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


Ts = 0.023;     // Período de amostragem do sinal (s) (média dos períodos de medição do exercício anterior)
fs = 1/Ts;      // Frequência de amostragem do sinal (Hz)
fc = 2;         // Frequência de corte do filtro (Hz)
wc = 2*%pi*fc;  // Frequência de corte do filtro (rad/s)

s=poly(0,'s');
H_filtro_c = syslin('c',wc/(s+wc));       // Função de transferência em tempo contínuo
SS_filtro_c = tf2ss(H_filtro_c);          // Transforma a função de transferência em espaço de estados
SS_filtro_d = cls2dls(SS_filtro_c, Ts);   // Transforma o sistema contínuo em discreto pelo método bilinear
H_filtro_d = ss2tf(SS_filtro_d);          // Função de transferência em tempo discreto

disp("Função de transferência em tempo discreto do filtro digital de 1ª ordem passa-baixa (aproximação bi-linear)")
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

disp("Diferença entre os coeficientes analíticos e os calculados pela função de transferência")
disp(err1,err2,err3)

/*
Verifica-se que os coeficientes obtidos pela função de transferência são coerentes
com a expressão analítica, já que:

err1 = abs(Ce_1 - kA(1)) == 1.665D-16
err2 = abs(Ce_0 - kA(2)) == 5.551D-17
err3 = abs(Cy_1 - kB(1)) == 5.551D-17
*/


// Lendo arquivos
data_folder = 'Processing_save_serial'

file_names = [
    'Leitura_Sensor_11_6_1_33_46_fc10.csv',
    'Leitura_Sensor_11_6_1_35_10_fc5.csv',
    'Leitura_Sensor_11_6_1_36_48_fc5.csv',
    'Leitura_Sensor_11_6_19_22_35_T15_fc2.csv',
    'Leitura_Sensor_11_6_19_23_14_T15_fc2.csv',
];

// =============================================================================
// FUNÇÃO DE CARREGAMENTO DOS DADOS
// =============================================================================

function [t,d,d_filt,u] = data_read(data_folder,filename, plot_signal)
    // Obtendo os caminhos de cada arquivo do experimento
    base_path = pwd(); // Diretório atual onde o Scilab está aberto
    s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)
    
    data_directory = base_path + s + data_folder;
    //Ordem de chamada: csvRead(filename, separator, decimal, conversion, substitute, regexpcomments, range, header)
    sensor   = csvRead(data_directory + s + filename, ',','.','double', [], [], [], 1 );
    
    t = sensor(:,1) / 1000; // Sinal está em ms, e passa-o para s
    d = sensor(:,2);        // Sinal do sensor ultrassom em cm
    d_filt = sensor(:,3);   // Sinal fitlrado do sensor ultrassom em cm
    u = sensor(:,4)*5/255;  // Sinal tem a tensão entre 0 e 255, e passa-a para 0V a 5V
    
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

// =============================================================================
// FUNÇÃO DE APLICAÇÃO DO FILTRO PELO SCILAB
// =============================================================================

function [y] = filtro_passa_baixa(e, fc, Ts)
    /*
    Realiza a filtragem numérica de um sinal discreto e[k] por meio da aproximação
    bilinear de um filtro digital passa baixa de 1º ordem 
    
    Inputs
        e --> sinal discretizado
        fc --> frequência de corte do filtro (Hz)
        Ts --> período de amostragem do sinal
    Output
        y --> sinal filtrado
    */
    
    wc = 2*%pi*fc;  // Frequência de corte do filtro (rad/s)
    // Cálculo dos coeficientes do filtro
    Cy_1 =  -(1 - (wc*Ts)/2) / (1 + (wc*Ts)/2);
    Ce_0 = ((wc*Ts)/2) / (1 + (wc*Ts)/2);
    Ce_1 = Ce_0;
    
    y = zeros(e); // Cria um vetor de zeros do tamanho do vetor e
    y(1) = e(1);  // Atribuindo o valor inicial
    
    // Loop da filtragem do sinal e[k]
    for k =2:length(e)
        y(k) = -Cy_1*y(k-1) + Ce_1*e(k-1) + Ce_0*e(k);
    end
endfunction

// =============================================================================
// FUNÇÃO DE ANÁLISE ESPECTRAL DO SINAL
// =============================================================================

function [psd] = spectral_calculation(signal_t,fs)
    /*
    Inputs:
    sinat_t --> um vetor unidimensional sinal_t (Nx1) que representa o valor de um
    sinal temporal
    fs      --> um valor real que representa a frequência de amostragem do sinal em Hz
    
    Outputs:
    psd  --> vetor (N/2 x 1) de números reais com a densidade espectral de potência do sinal temporal
    */
    
    N = length(signal_t);
    
    //spectrum_f = fft(signal_t - mean(signal_t)); // Retira o viés do sinal (pico na frequência zero)
    spectrum_f = fft(signal_t); 
    
    spectrum_f = spectrum_f(1:N/2+1); // Como a fft é simétrica, pega-se metade do vetor
    
    psd = (1/(fs*N)) * ( abs(spectrum_f) ).^2 ; // PSD --> densidade espectral de potência
    psd(2:$-1) = 2*psd(2:$-1);
    
endfunction

// Carregamento dos dados
plot_na_funcao = %F; // %T para True ou %F para False

[t1,d1,d1_filt_Arduino,u1] = data_read(data_folder, file_names(1), plot_na_funcao);
[t2,d2,d2_filt_Arduino,u2] = data_read(data_folder, file_names(2), plot_na_funcao);
[t3,d3,d3_filt_Arduino,u3] = data_read(data_folder, file_names(3), plot_na_funcao);
[t4,d4,d4_filt_Arduino,u4] = data_read(data_folder, file_names(4), plot_na_funcao);
[t5,d5,d5_filt_Arduino,u5] = data_read(data_folder, file_names(5), plot_na_funcao);

// Analisando o período e frequência de amostragem do Arduino
function [Ts_vec, Ts, fs] = sampling_time_step(t)
    // Input: t --> vetor discreto de tempos
    Ts_vec = ( t(2:$,1) - t(1:$-1,1) ) // Intervalos de tempo entre uma medição e outra
    Ts = mean(Ts_vec);                 // Período de amostragem médio do sinal
    fs = 1/Ts;                         // Frequência de amostragem média do sinal
endfunction

[Ta_t1, Ta1, fa1] = sampling_time_step(t1);
[Ta_t2, Ta2, fa2] = sampling_time_step(t1);
[Ta_t3, Ta3, fa3] = sampling_time_step(t1);
[Ta_t4, Ta4, fa4] = sampling_time_step(t1);
[Ta_t5, Ta5, fa5] = sampling_time_step(t1);

// Filtragem numérica do sinal pelo Scilab
d1_filt_Scilab = filtro_passa_baixa(d1, 10, Ts);
d2_filt_Scilab = filtro_passa_baixa(d2, 5 , Ts);
d3_filt_Scilab = filtro_passa_baixa(d3, 5 , Ts);
d4_filt_Scilab = filtro_passa_baixa(d4, 2 , Ts);
d5_filt_Scilab = filtro_passa_baixa(d5, 2 , Ts);

// Analise espectral dos sinais

function [f, psd_d, psd_d_filt_Arduino, psd_d_filt_Scilab, psd_u] = data_spectral_treatment(fs,d,d_filt_Arduino,d_filt_Scilab, u)
    /*
    Para evitar repetições de código, essa função aplica os calculos espectrais para todos os dados que temos 
    */
    N = length(d);
    f = (fs /N)*(0:N/2)'                    // Escala de frequências
    psd_d              = spectral_calculation(d,fs);
    psd_d_filt_Arduino = spectral_calculation(d_filt_Arduino,fs);
    psd_d_filt_Scilab  = spectral_calculation(d_filt_Scilab,fs);
    psd_u              = spectral_calculation(u,fs);
endfunction

[f1,psd_d1, psd_d1_filt_Arduino, psd_d1_filt_Scilab, psd_u1] = data_spectral_treatment(fa1,d1,d1_filt_Arduino, d1_filt_Scilab, u1);
[f2,psd_d2, psd_d2_filt_Arduino, psd_d2_filt_Scilab, psd_u2] = data_spectral_treatment(fa2,d2,d2_filt_Arduino, d2_filt_Scilab, u2);
[f3,psd_d3, psd_d3_filt_Arduino, psd_d3_filt_Scilab, psd_u3] = data_spectral_treatment(fa3,d3,d3_filt_Arduino, d3_filt_Scilab, u3);
[f4,psd_d4, psd_d4_filt_Arduino, psd_d4_filt_Scilab, psd_u4] = data_spectral_treatment(fa4,d4,d4_filt_Arduino, d4_filt_Scilab, u4);
[f5,psd_d5, psd_d5_filt_Arduino, psd_d5_filt_Scilab, psd_u5] = data_spectral_treatment(fa5,d5,d5_filt_Arduino, d5_filt_Scilab, u5);


// =============================================================================
// ANÁLISE DOS RESULTADOS
// =============================================================================
/*
Parâmetros de cada medição:
Sinal enviado ao motor:
- T_sinal: período de oscilação do sinal enviado
- voltMax: valor máximo do sinal oscilatório (máx = 255)
- voltMin: valor mínimo do sinal oscilatório (mín = 0)

Medição 1: fc filtro = 10Hz | T_sinal = 1  s | voltMax = 130 | voltMin = 80
Medição 2: fc filtro =  5Hz | T_sinal = 1  s | voltMax = 140 | voltMin = 70
Medição 3: fc filtro =  5Hz | T_sinal = 1  s | voltMax = 170 | voltMin = 50
Medição 4: fc filtro =  2Hz | T_sinal = 1.5s | voltMax = 200 | voltMin = 30
Medição 5: fc filtro =  2Hz | T_sinal = 1.5s | voltMax = 200 | voltMin = 30

Como pode-se ver, foram realizados testes com diferentes frequências de corte, períodos do sinal enviado ao motor e voltagens.

O picos na frequência zero do espectro de frequências de todos os sinais era esperado e ele ocorre devido ao viés dos sinais, ou seja, quando estes possuem uma média diferente de zero. Isso ocorre, pois os sinais oscilam ao redor de um ponto acima de zero, o que faz com que a integral do vetor ao longo do tempo seja não nula e gera o pico na frequência zero.

Comparando os diferentes filtros a partir dos sinais medidos plotados em função do tempo (d x t) é possível observar que ambos os filtros reduzem efetivamente os ruídos o que é perceptível pelo pelo desaparecimento de picos de medição, esse fenômeno é muito evidente nos gráficos da medição 2. Dando um zoom nos gráficos é possível observar que os pequenos picos locais são também filtrados, de forma que a curva do sinal fique com menos oscilações.

É possível observar observar um deslocamento das curvas do sinal filtrado para a direita, gerando um tipo de delay pelo filtro. Isso é mais acentuado para as medições 4 e 5 e pode portanto estar associado a uma menor frequência de corte ou maior período de oscilação do sinal enviado.

Para essses casos também, o filtro do arduíno teve o mesmo comportamento do filtro do scilab, gerando ambos a mesma curva, porém nas mediições 1, 2 e 3 é possivel, através de um zoom, comparar os dois filtros, e observa-se que o filtro do arduino tende a reduzir mais o sinal, tanto para as altas quanto para as baixas, para um pico no sinal medido o filtro do scilab devolverá um sinal maior que o do arduíno e para um vale o filtro do scilab gerará um sinal menor que o do arduíno. É interessante observar como esse fenômeno desaparece para menores frequências de corte e maiores períodos de oscilação do sinal enviado.

Realizou-se, também, a análise espectral para os sinais medidos e filtrados pelo scilab e pelo Arduino, para cada medição. Em linha com as análises feitas anteriormente, nota-se que tanto o filtro do Arduino como do Scilab reduziram o ruído. Na medição 1, nota-se que os sinais filtrados se mostram muito mais próximos ao sinal medido e com uma filtragem menor, devido à maior frequência de corte. Conforme se diminui a frequência de corte, nota-se que a filtragem é melhorada. 

Do mesmo modo que nas análises anteriores, se nota um delay em ambos os filtros, especialmente nas medições 3, 4 e 5. Também nota-se diferenças entre os filtros, uma vez que o do Scilab reduz o ruído mais do que o do Arduino. Nota-se isto com maior facilidade no gráfico 4 

Também é possível notar que, com os filtros, o sinal medido se aproxima do enviado pelo motor, o que comprova a eficâcia do filtro. No gráfico 1, com a frequência de corte menor, os filtros não se aproximam tanto do sinal que sai do motor, mostrando que a filtragem é pior nestes casos. Conforme a frequência de corte diminui, a filtragem é melhorada, mas sempre se mostrando melhor no Scilab.

*/

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
'red',          // 8
]

// Plot das distâncias
function plot_dist(t,d,d_filt_Arduino,d_filt_Scilab, medicao)
    fig = scf();
    plot2d(t, d, style = color(cores(2)) );
    plot2d(t, d_filt_Scilab , style = color(cores(4)) );
    plot2d(t, d_filt_Arduino , style = color(cores(8)) );
    title('Distância captada pelo ultrassom na medição ' + string(medicao));
    ylabel("d (cm)");
    xlabel("tempo(s)");
    h= legend(['Sinal medido';'Filtrado pelo Scilab'; 'Filtrado pelo Arduino']);
endfunction

plot_dist(t1,d1,d1_filt_Arduino, d1_filt_Scilab, 1);
plot_dist(t2,d2,d2_filt_Arduino, d2_filt_Scilab, 2);
plot_dist(t3,d3,d3_filt_Arduino, d3_filt_Scilab, 3);
plot_dist(t4,d4,d4_filt_Arduino, d4_filt_Scilab, 4);
plot_dist(t5,d5,d5_filt_Arduino, d5_filt_Scilab, 5);

function plot_freq(f,psd_d,psd_d_filt_Arduino,psd_d_filt_Scilab, psd_u, medicao)
    fig = scf();
    plot2d('nl',f, psd_u, style = color(cores(3)) );
    plot2d('nl',f, psd_d, style = color(cores(1)) );
    plot2d('nl',f, psd_d_filt_Arduino, style = color(cores(4)) );
    plot2d('nl',f, psd_d_filt_Scilab, style = color(cores(8)) );
    title('Espectro de frequência da distância lida pelo Ultrassom na medição ' + string(medicao));
    ylabel("PSD");
    xlabel("f(Hz)");
    h= legend(['Sinal enviado ao motor';'Sinal medido';'Filtrado pelo Arduino'; 'Filtrado pelo Scilab']);
endfunction

plot_freq(f1,psd_d1,psd_d1_filt_Arduino,psd_d1_filt_Scilab, psd_u1, 1);
plot_freq(f2,psd_d2,psd_d2_filt_Arduino,psd_d2_filt_Scilab, psd_u2, 2);
plot_freq(f3,psd_d3,psd_d3_filt_Arduino,psd_d3_filt_Scilab, psd_u3, 3);
plot_freq(f4,psd_d4,psd_d4_filt_Arduino,psd_d4_filt_Scilab, psd_u4, 4);
plot_freq(f5,psd_d5,psd_d5_filt_Arduino,psd_d5_filt_Scilab, psd_u5, 5);
