/*
==============================================================
                Escola Politécnica da USP
 PME3402 - Laboratório de Medição e Controle Discreto
--------------------------------------------------------------
                       ATIVIDADE 3
--------------------------------------------------------------
                        GRUPO 13
                        Membros:
              Tiago Vieira de Campos Krause
                Vinicius Rosario Dyonisio
            Vítor Albuquerque Maranhao Ribeiro
                  Vitória Garcia Bittar
               
---------------------------------------------------------------
                Professores responsáveis:
                 Edilson Hiroshi Tamai
                      Flávio Trigo
                      
===============================================================

INSTRUÇÕES PARA RODAR O PROGRAMA
Antes de rodar o programa, siga os seguintes passos
1) Certifique-se de que o Scilab está aberto na pasta "/Atividade 3/"
em que o programa se encontra
2) Certifique-se de que os dados do acelerômetro estão na pasta "/Atividade 3/Dados"
dentro da pasta do programa
3) Rode o programa
*/

//LIMPEZA DE MEMÓRIA
clear;
clc;    // Limpeza de variáveis e do console
xdel(winsid()) // Fecha as janelas abertas


// ============================================================
// CARREGAMENTO DOS DADOS

// Obtendo os caminhos de cada arquivo do experimento
base_path = pwd(); // Diretório atual onde o programa está
s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)

data_directory = base_path + s + 'Dados';

// Lendo arquivos
file_names = [
    'acelerometro_20cm.csv',
    'acelerometro_25cm_1.csv',
    'acelerometro_25cm_2.csv',
    'acelerometro_25cm_3.csv'
];

file_path = data_directory + s + file_names;

//Ordem de chamada: csvRead(filename, separator, decimal, conversion, substitute, regexpcomments, range, header)

header = 1; // Pulando a primeira linha do arquivo (header)
a20   = csvRead(data_directory + s + file_names(1), ',','.','double', [], [], [], header );
a25_a = csvRead(data_directory + s + file_names(2), ',','.','double', [], [], [], header );
a25_b = csvRead(data_directory + s + file_names(3), ',','.','double', [], [], [], header );
a25_c = csvRead(data_directory + s + file_names(4), ',','.','double', [], [], [], header );

// Parâmetro
fa = 100; //[Hz] Frequência de amostragem do sensor do acelerômetro

// ============================================================
// ANÁLISE DOS DADOS
/*
Primeiramente, analisamos os dados temporais dos dados para compreender os
sinais com que estamos trabalhando.

Cada matriz de sinais possui as colunas no formato:
Coluna 1: Tempo (s)
Coluna 2: Aceleração X         ax (m/s^2)
Coluna 3: Aceleração Y         ay (m/s^2)
Coluna 4: Aceleração Z         az (m/s^2)
Coluna 5: Módulo da aceleração |a|(m/s^2)
*/

/*
A partir dos dados, é possível verificar a precisão do valor do módulo das
acelerações - presente nas colunas 5 das matrizes.
*/

function norma_linhas = norma_das_linhas(matriz_de_aceleracoes)
    /*
    Recebe uma matriz de tamanho (mxn)
    retorna um vetor de tamanho (mx1) com os valores da norma em L2 de cada linha da matriz
    */
    
    norma_linhas = zeros(size(matriz_de_aceleracoes,1) ,1); //Tamanho
    for i = 1:size(norma_linhas,1) //Para cada linha da matriz
        norma_linhas(i) = norm(matriz_de_aceleracoes(i,:)); //Calcula-se a norma do vetor da linha
    end
endfunction

// Substituição dos valores da coluna 5 dos vetores, com a norma das acelerações
a20  (:,5) = norma_das_linhas(a20(:,2:4))  ; // Calcula as normas dos vetores [ax,ay,az]
a25_a(:,5) = norma_das_linhas(a25_a(:,2:4));
a25_b(:,5) = norma_das_linhas(a25_b(:,2:4));
a25_c(:,5) = norma_das_linhas(a25_c(:,2:4));

/*
A partir da figura 1, pode-se ver que será necessária a separação dos vetores
temporais, já que um vetor possui mais de um ensaio de impacto da régua,
além de alguns dos vetores possuirem medidas em tempos neutro (régua em
posição estática), o que pode afetar na precisão da FFT.

A obtenção dos intervalos de corte foi feita visualmente analisando os intervalos
de tempo em que os picos de aceleração ocorriam
*/

// Separação dos vetores de impulsos
a20_1 = a20( a20(:,1)> 1.95  & a20(:,1) <3.0  , :); // Pega o vetor a20 entre os tempos 1.95s e 2.8s
a20_2 = a20( a20(:,1)> 4.95  & a20(:,1)< 6.2  , :);
a20_3 = a20( a20(:,1)> 8.4   & a20(:,1)< 9.25 , :);
a20_4 = a20( a20(:,1)>11.1   & a20(:,1)<12.2  , :);
a20_5 = a20( a20(:,1)>13.75  & a20(:,1)<14.8  , :);
a20_6 = a20( a20(:,1)>15.8   & a20(:,1)<16.8  , :);
a20_7 = a20( a20(:,1)>17.8   & a20(:,1)<19.0  , :);


a25_1 = a25_a( a25_a(:,1)>1.95  & a25_a(:,1)< 4.7  , :);

a25_2 = a25_b( a25_b(:,1)>1.6   & a25_b(:,1)< 3.6  , :);

a25_3 = a25_c( a25_c(:,1)> 4.1  & a25_c(:,1)< 6.0  , :);
a25_4 = a25_c( a25_c(:,1)> 6.85 & a25_c(:,1)< 9.1  , :);
a25_5 = a25_c( a25_c(:,1)> 9.8  & a25_c(:,1)<12.1  , :);
a25_6 = a25_c( a25_c(:,1)>12.5  & a25_c(:,1)<14.4  , :);

function y = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)
    /*
    Recebe um sinal temporal discretizado e aplica um filtro digital de 1ª ordem
    a partir de um filtro no tempo contínuo por meio de equações de diferenças.
    É preciso, também, identificar qual o tipo de método de integração numérica
    deseja-se utilizar ('euler-foward','euler-backward', 'trapezoid')
    
    Inputs:
    e       --> Vetor de tamanho 1xN com os valores do sinal temporal de entrada
    metodo  --> Método de integração numérica desejado para o cálculo do filtro
                Possíveis: metodo = ['euler-foward','euler-backward', 'trapezoid']
    fa      --> Valor real (Hz). Frequência de amostragem do sinal
    fc      --> Valor real (Hz). Frequência de corte passa-baixo para o sinal
    
    Output:
    y       --> Vetor de tamanho 1xN com o valor temporal do sinal de saída (filtrado)
    */
    
    T = 1/fa ;     // Período de amostragem do sinal (s)
    wc = 2*%pi*fc; // Frequência de corte (rad/s)
    
    N = length(sinal_t);
    y = zeros(N,1);
    
    y(1) = e(1);

    select metodo // Seleciona o tratamento para cada tipo de método
    case 'euler-foward'
        K1 = (1-wc*T);
        K2 = wc*T;
        
        for k =2:N
            y(k) = K1*y(k-1) + K2*e(k-1)
        end
     
    case 'euler-backward'
        K1 = (1/(1+wc*T))
        K2 = wc*T
        
        for k =2:N
            y(k) = K1*y(k-1) + K2*e(k-1)
        end

    case 'trapezoid'    
        K1 = (1 - (wc*T)/2) / (1 + (wc*T)/2);
        K2 = ((wc*T)/2) / (1 + (wc*T)/2);
        
        for k =2:N
            y(k) = K1*y(k-1) + K2*(e(k-1) + e(k))
        end
    end

endfunction

// ============================================================
// ANÁLISE ESPECTRAL

function [sinal_filtrado, f, espectro, espectro_filtrado] = analise_espectral(sinal_t, metodo , fa, fc)
    /*
    Inputs:
    sinat_t --> um vetor unidimensional sinal_t (1xN) que representa o valor de um
    sinal temporal
    metodo  --> Método de integração numérica desejado para o cálculo do filtro
                Possíveis: metodo = ['euler-foward','euler-backward', 'trapezoid']
    fa      --> Valor real (Hz). Frequência de amostragem do sinal
    fc      --> Valor real (Hz). Frequência de corte passa-baixo para o sinal
    
    Outputs:
    sinal_filtrado --> vetor 1xN com o sinal temporal filtrado
    espectro --> vetor (1xN/2) o módulo da fft do sinal de entrada
    espectro_fitlrado --> vetor (1xN/2) o módulo da fft do sinal de saída
    f        --> vetor (1xN/2) com a escala de frequência dos sinais em Hz
    */
    
    N = length(sinal_t);
    N_f = round(N/2); // Como a FFT é simétrica, pega-se apenas metade dos valores do vetor de saída da fft

     
    espectro = abs(fft(sinal_t,-1))((1:N_f)); // Módulo da FFT do sinal temporal
    
    // Sinal filtrado passa baixa na frequência de corte
    sinal_filtrado = filtro_passa_baixa_1a_ordem(sinal_t, metodo , fa, fc)

    espectro_filtrado = abs(fft(sinal_filtrado,-1))((1:N_f))
    
    f = (fa /N) * (0:N_f-1)'                  // Escala de frequências
endfunction

// Obtenção dos espectros de frequência
metodos = ['euler-foward','euler-backward', 'trapezoid'];
fc = 30;
[a25_4_filt_1, f_a25_4, espectro_a25_4, espectro_a25_4_filt_1] = analise_espectral(a25_4(:,5),'euler-foward', fa, 1)
[a25_4_filt_5,    #   ,        #      , espectro_a25_4_filt_5] = analise_espectral(a25_4(:,5),'euler-foward', fa, 5)
[a25_4_filt_30,    #   ,        #      , espectro_a25_4_filt_30] = analise_espectral(a25_4(:,5),'euler-foward', fa, 30)

// ============================================================
// PLOTAGEM DOS GRÁFICOS

cores = [
'blue4',
'deepskyblue3',
'aquamarine3',
'springgreen4',
'gold3',
'firebrick1',
'magenta3',
]

f1 = scf(1)
    subplot(4,1,1)
    plot2d(a25_4(:,1),a25_4(:,5), color(cores(1)) );
    title('Pulso 4 a L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    
    subplot(4,1,2)
    plot2d(a25_4(:,1),a25_4_filt_30, color(cores(2)));
    title('Pulso 4 a L=25cm e fc= 30Hz, método: Euler-Foward')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    
    subplot(4,1,3)
    plot2d(a25_4(:,1),a25_4_filt_5, color(cores(3)));
    title('Pulso 4 a L=25cm e fc= 5Hz, método: Euler-Foward')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    
    subplot(4,1,4)
    plot2d(a25_4(:,1),a25_4_filt_1, color(cores(4)));
    title('Pulso 4 a L=25cm e fc= 1Hz, método: Euler-Foward')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    
f2= scf(2)
    // Figura 8: plot2d individuais dos espectros de pulsos para L=25cm
    //[espectro_a20_1, f_a20_1]
    subplot(4,1,1)
    plot2d(f_a25_4, espectro_a25_4, style = color(cores(1)));
    title('Espectro da aceleração do pulso 4 em L=25cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,2)
    plot2d(f_a25_4, espectro_a25_4_filt_30, style = color(cores(2)));
    title('Espectro da aceleração do pulso 4 em L=25cm, fc = 30Hz, método: Euler-Foward')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,3)
    plot2d(f_a25_4, espectro_a25_4_filt_5, style = color(cores(3)));
    title('Espectro da aceleração do pulso 4 em L=25cm, fc = 5Hz, método: Euler-Foward')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_a25_4, espectro_a25_4_filt_1, style = color(cores(4)));
    title('Espectro da aceleração do pulso 4 em L=25cm, fc = 1Hz, método: Euler-Foward')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
