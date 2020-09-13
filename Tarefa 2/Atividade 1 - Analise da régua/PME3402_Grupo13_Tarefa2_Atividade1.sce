/*
==============================================================
                Escola Politécnica da USP
 PME3402 - Laboratório de Medição e Controle Discreto
--------------------------------------------------------------
                  TAREFA 2 ATIVIDADE 1
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
1) Certifique-se de que o Scilab está aberto na pasta "/Atividade 1 - Análise da régua/" em que o programa se encontra
2) Certifique-se de que os dados do acelerômetro estão na pasta "/Atividade 1 - Análise da régua/Dados" dentro da pasta do programa
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

norma_a20_calculada = norma_das_linhas(a20(:,2:4)); //Calcula as normas dos vetores [ax,ay,az]

diferenca_de_calculo = norma_a20_calculada - a20(:,5); 
modulo_diferenca = norm(diferenca_de_calculo);

/*
Performando a operação modulo_diferenca = norm(diferenca_de_calculo) obtêm-se que

modulo_diferenca  = 

   0.2511410

Isso se dá, pois a precisão do módulo da aceleração medida é de apenas duas casas
decimais, o que pode acarretar na perda de precisão do valor real da aceleração
medido.

Assim, iremos substituir os valores da coluna 5 pelos valores calculados, com maior precisão
*/

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

/*
Além disso, é possível verificar qual foi a frequência de amostragem das medidas
do acelerômetro. O cálculo dessa grandeaza é feito por meio da expressão:
1/( t(n+1) - t(n) )

A partir da figura 4, é visível que a frequência de amostragem do sinal possui
grande variação. Isso se dá, pois o próprio aparelho de celular possui uma
frequência de processamento que varia e pode até ser limitada, para evitar
o superaquecimento do aparelho.

Essa variação pode afetar os resultados da FFT, que considera a frequência de
amostragem do sinal um valor constante
*/

// Cálculo das frequências de amostragem para a20
// No Scilab , a variável "$" representa o fim do vetor
fa_a20 = 1.0 ./( a20(2:$ ,1) - a20(1:$-1 ,1) )



// ============================================================
// ANÁLISE ESPECTRAL




// ============================================================
// PLOTAGEM DOS GRÁFICOS

f1 = scf(1)
//Figura 1: Plot das acelerações medidas pelos acelerômetros no tempo
    subplot(2,2,1)
    plot(a20(:,1),[a20(:,2),a20(:,3),a20(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 1.1: Dados temporais medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az';'|a|'])
    
    subplot(2,2,2)
    plot(a25_a(:,1),[a25_a(:,2),a25_a(:,3),a25_a(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 1.2: Dados temporais medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(2,2,3)
    plot(a25_b(:,1),[a25_b(:,2),a25_b(:,3),a25_b(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 1.3: Dados temporais medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])

    subplot(2,2,4)
    plot(a25_c(:,1),[a25_c(:,2),a25_c(:,3),a25_c(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 1.4: Dados temporais medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])

f2 = scf(2)
    // Figura 2: Plot dos pulsos individuais da figura 1.1
    subplot(4,2,1)
    plot(a20_1(:,1),[a20_1(:,2),a20_1(:,3),a20_1(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 2.1: Pulso 1 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(4,2,2)
    plot(a20_2(:,1),[a20_2(:,2),a20_2(:,3),a20_2(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 2.2: Pulso 2 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(4,2,3)
    plot(a20_3(:,1),[a20_3(:,2),a20_3(:,3),a20_3(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 2.3: Pulso 3 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(4,2,4)
    plot(a20_4(:,1),[a20_4(:,2),a20_4(:,3),a20_4(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 2.4: Pulso 4 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(4,2,5)
    plot(a20_5(:,1),[a20_5(:,2),a20_5(:,3),a20_5(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 2.5: Pulso 5 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])

    subplot(4,2,6)
    plot(a20_6(:,1),[a20_6(:,2),a20_6(:,3),a20_6(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 2.6: Pulso 6 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
 
    subplot(4,1,4)
    plot(a20_7(:,1),[a20_7(:,2),a20_7(:,3),a20_7(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 2.7: Pulso 7 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])

f3 = scf(3)
    // Plot dos pulsos da figura 1.1 cortados em vetores individuais
    subplot(3,2,1)
    plot(a25_1(:,1),[a25_1(:,2),a25_1(:,3),a25_1(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 3.1: Pulso 1 da figura 1.2 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])

    subplot(3,2,2)
    plot(a25_2(:,1),[a25_2(:,2),a25_2(:,3),a25_2(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 3.2: Pulso 1 da figura 1.3 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(3,2,3)
    plot(a25_3(:,1),[a25_3(:,2),a25_3(:,3),a25_3(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 3.3: Pulso 1 da figura 1.4 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(3,2,4)
    plot(a25_4(:,1),[a25_4(:,2),a25_4(:,3),a25_4(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 3.4: Pulso 2 da figura 1.4 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(3,2,5)
    plot(a25_5(:,1),[a25_5(:,2),a25_5(:,3),a25_5(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 3.5: Pulso 3 da figura 1.4 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(3,2,6)
    plot(a25_6(:,1),[a25_6(:,2),a25_6(:,3),a25_6(:,4)]);       // Plotando [ax,ay,az] x t
    title('Figura 3.6: Pulso 4 da figura 1.4 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    
f4= scf(4)
    plot(fa_a20)
    title('Figura 4: Frequência de amostragem das medidas do acelerômetro para L=20')
    xlabel('Intervalo de medida')
    ylabel('fa [Hz]')




