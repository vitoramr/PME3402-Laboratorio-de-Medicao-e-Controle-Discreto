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
1) Certifique-se de que o Scilab está aberto na pasta "/Atividade 1 - Análise da régua/"
em que o programa se encontra
2) Certifique-se de que os dados do acelerômetro estão na pasta "/Atividade 1 - Análise da régua/Dados"
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
Nas figuras 2 e 3, cada pulsos de L=20cm e L=25cm, respectivamente, 
são analisados de forma individual, de modo a se obter uma visão mais detalhada de cada pulso.
Para cada caso foi utilizado um vetor de corte visual, uma vez que para L=20cm o período
se mostrou menor do que o de L=25cm.

Além disso, é possível verificar pelo vetor de tempo qual foi a frequência de 
amostragem das medidas do acelerômetro. O cálculo dessa grandeaza é feito por
meio da expressão:

f(n) = 1/( t(n+1) - t(n) )

Apesar de o aplicativo do aparelho celular dizer que a frequência de amostragem
nominal é de 100Hz, a partir da figura 4, é visível que a frequência de amostragem
dos sinais possuem grande variação, possuindo a maioria dos valores ao redor de 100Hz,
mas esses valores estão intercalados por medições com intervalos de tempo muito próximos
ou muito espaçados. É possível notar, por exemplo, que o vetor de tempos da matriz
a20 possui 331 valores entre 0s e 1s, enquanto esse valor idealmente deveria ser em torno de 100.

Isso se dá, pois o próprio aparelho de celular possui uma frequência de processamento
de grande variação no tempo, que pode até ser limitada, para evitar o superaquecimento
do aparelho.

Uma hipótese da equipe para a grande variação na frequência de amostragem dos
dados era um possível erro na contagem de tempo pelo aplicativo.
Para validar a hipótese, nossa equipe utilizou dois aparelhos celulares para
fazer um experimento grosseiro: um iPhone, que foi o celular utilizado para
realizar as medições das acelerações, e um Android. No experimento (figura 5),
o tempo foi cronometrando por outro dispositivo e o mesmo aplicativo foi utilizado
para medir a aceleração dos celulares, nos quais dois impulsos foram realizados,
espaçados de aproximadamente 5s. Os gráficos temporais e os cálculos das frequências
amostrais do experimento estão presentes na figura 5.1 e 5.2.

Como visto na figura 5.1, os espaçamentos entre os impulsos foram de aproximadamente
de 5s para os dois aparelhos. Porém, na figura 5.2, a frequênciade amostragem
manteve-se ao redor dos 100Hz para o Android, enquanto teve grande variação no
iPhone que foi utlizado para as medições das acelerações. Sendo assim, nossa
hipótese não foi validada.

Dessa forma, é possivel ver que o iPhone possui uma baixa compatibilidade com o
o aplicativo utilizado, possuindo uma grande variação da sua frequência amostral.
Mesmo assim, para a sequência do trabalho, será adotada uma frequência de
amostragem de 100Hz. A variação pode afetar os resultados da FFT, que considera
a frequência de amostragem do sinal um valor constante
*/

// Cálculo das frequências de amostragem para a20
// No Scilab , a variável "$" representa o fim do vetor
fa_a20   = 1.0 ./( a20(2:$ ,1)   - a20(1:$-1 ,1)      )
fa_a25_a = 1.0 ./( a25_a(2:$ ,1) - a25_a(1:$-1 ,1) )
fa_a25_b = 1.0 ./( a25_b(2:$ ,1) - a25_b(1:$-1 ,1) )
fa_a25_c = 1.0 ./( a25_c(2:$ ,1) - a25_c(1:$-1 ,1) )

// Teste de impulsos
teste_freq_android = csvRead(data_directory + s + 'impulsos_5s_10s_Andoid.csv', ';',',','double', [], [], [], header );
teste_freq_iphone  = csvRead(data_directory + s + 'impulsos_5s_10s_iPhone.csv', ',','.','double', [], [], [], header );

fa_teste_android = 1.0 ./( teste_freq_android(2:$ ,1) - teste_freq_android(1:$-1 ,1) )
fa_teste_iphone  = 1.0 ./( teste_freq_iphone(2:$ ,1) - teste_freq_iphone(1:$-1 ,1) )

// ============================================================
// ANÁLISE ESPECTRAL

function [f, espectro, espectro_unbias, espectro_passaalta] = analise_espectral(sinal_t,fa)
    /*
    Recebe:
    sinat_t --> um vetor unidimensional sinal_t (1xN) que representa o valor de um
    sinal temporal
    fa --> um valor real que representa a frequência de amostragem do sinal em Hz
    
    Retorna:
    espectro --> o módulo da sua fft
    f        --> a escala de frequência do sinal em Hz
    */
    N = length(sinal_t);
    N_f = round(N/2); // Como a FFT é simétrica, pega-se apenas metade dos valores do vetor

     
    espectro = abs(fft(sinal_t,-1))((1:N_f)); // Módulo da FFT do sinal temporal
    
    // Retirando o enviesamento do sinal
    sinal_t_unbias = sinal_t - mean(sinal_t)
    espectro_unbias = abs(fft(sinal_t_unbias,-1))((1:N_f)) // Módulo da FFT desenviesada
    
    // Filtro passa alta na frequência de corte de 3 Hz
    f_low = 3;      //Frequencia de corte baixa
    f_high = []; //Frequência de corte alta é a frequência final
    

    //filtro = ffilt('hp', N , f_low , [])
    
    f_cut = 3;
    fc = f_cut/fa;
    
    filtro = iir (3 ,'hp','butt', fc ,[]) ; //Filtro passa alta
    sinal_filtrado = flts(sinal_t', filtro) ;

    espectro_passaalta = abs(fft(sinal_filtrado,-1))((1:N_f))
    
    f = (fa /N) * (0:N_f-1)'                  // Escala de frequências
endfunction

// Obtenção dos espectros de frequência do módulo da aceleração de cada impulso
// Para L=20cm
[f_a20_1, espectro_a20_1, espectro_a20_1_unbias, espectro_a20_1_filt] = analise_espectral(a20_1(:,5),fa) //Espectro do módulo da aceleração
[f_a20_2, espectro_a20_2, espectro_a20_2_unbias, espectro_a20_2_filt] = analise_espectral(a20_2(:,5),fa)
[f_a20_3, espectro_a20_3, espectro_a20_3_unbias, espectro_a20_3_filt] = analise_espectral(a20_3(:,5),fa)
[f_a20_4, espectro_a20_4, espectro_a20_4_unbias, espectro_a20_4_filt] = analise_espectral(a20_4(:,5),fa)
[f_a20_5, espectro_a20_5, espectro_a20_5_unbias, espectro_a20_5_filt] = analise_espectral(a20_5(:,5),fa)
[f_a20_6, espectro_a20_6, espectro_a20_6_unbias, espectro_a20_6_filt] = analise_espectral(a20_6(:,5),fa)
[f_a20_7, espectro_a20_7, espectro_a20_7_unbias, espectro_a20_7_filt] = analise_espectral(a20_7(:,5),fa)

// Para L=25cm
[f_a25_1, espectro_a25_1, espectro_a25_1_unbias, espectro_a25_1_filt] = analise_espectral(a25_1(:,5),fa)
[f_a25_2, espectro_a25_2, espectro_a25_2_unbias, espectro_a25_2_filt] = analise_espectral(a25_2(:,5),fa)
[f_a25_3, espectro_a25_3, espectro_a25_3_unbias, espectro_a25_3_filt] = analise_espectral(a25_3(:,5),fa)
[f_a25_4, espectro_a25_4, espectro_a25_4_unbias, espectro_a25_4_filt] = analise_espectral(a25_4(:,5),fa)
[f_a25_5, espectro_a25_5, espectro_a25_5_unbias, espectro_a25_5_filt] = analise_espectral(a25_5(:,5),fa)
[f_a25_6, espectro_a25_6, espectro_a25_6_unbias, espectro_a25_6_filt] = analise_espectral(a25_6(:,5),fa)


// ============================================================
// ANÁLISE DOS RESULTADOS
/*
Analisando o espectro de frequência dos sinais na figura 6, é visível
que todos possuem um grande pico na frequência 0Hz. Isso ocorre devido ao
fenômeno de polarização CC (ou "DC bias" em inglês). Esse fenômeno ocorre quando
a média do sinal no tempo é diferente de zero, e diz-se, então, que o sinal
está "enviesado". Em geral, este fenômeno está presente quando o dispositivo
captura medidas mesmo quando a posição do dispositivo é estática.

Esse problema é reduzido aplicando um offset no sinal temporal, ou seja,
subtraindo-o pela sua média. Realizando essa operação, obtemos a figura 7, onde
o pico em zero dos espectros foi reduzido, mas ainda assim, existem grandes
valores para baixas frequências, o que provavelmente é proveniente do ruído
presente na medição. Uma maneira de reduzir esse problema é aplicar um filtro passa alta, que reduzi-
ria o valor das baixas frequências.

Assim chegamos à figura 8, onde podemos analisar os valores que provém do estímulo à regua, e que 
excluem os ruidos.
Nesta figura, se pode analisar melhor os efeitos da aceleração produzida, tendo um isolamento dos ruidos.
No entanto, é 

*/



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
//Figura 1: plot2d das acelerações medidas pelos acelerômetros no tempo
    f=gcf();
    f.color_map=hsvcolormap(3); // Setando a escala de cores do gráfico
    
    subplot(2,2,1)
    plot2d(a20(:,1),[a20(:,2),a20(:,3),a20(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 1.1: Dados temporais medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az';'|a|'])
    
    subplot(2,2,2)
    plot2d(a25_a(:,1),[a25_a(:,2),a25_a(:,3),a25_a(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 1.2: Dados temporais medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(2,2,3)
    plot2d(a25_b(:,1),[a25_b(:,2),a25_b(:,3),a25_b(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 1.3: Dados temporais medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])

    subplot(2,2,4)
    plot2d(a25_c(:,1),[a25_c(:,2),a25_c(:,3),a25_c(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 1.4: Dados temporais medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])

f2 = scf(2)
    // Figura 2: plot2d dos pulsos individuais da figura 1.1
    f=gcf();
    f.color_map=hsvcolormap(3); // Setando a escala de cores do gráfico
    
    subplot(4,2,1)
    plot2d(a20_1(:,1),[a20_1(:,2),a20_1(:,3),a20_1(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 2.1: Pulso 1 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(4,2,2)
    plot2d(a20_2(:,1),[a20_2(:,2),a20_2(:,3),a20_2(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 2.2: Pulso 2 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(4,2,3)
    plot2d(a20_3(:,1),[a20_3(:,2),a20_3(:,3),a20_3(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 2.3: Pulso 3 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(4,2,4)
    plot2d(a20_4(:,1),[a20_4(:,2),a20_4(:,3),a20_4(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 2.4: Pulso 4 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(4,2,5)
    plot2d(a20_5(:,1),[a20_5(:,2),a20_5(:,3),a20_5(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 2.5: Pulso 5 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])

    subplot(4,2,6)
    plot2d(a20_6(:,1),[a20_6(:,2),a20_6(:,3),a20_6(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 2.6: Pulso 6 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
 
    subplot(4,1,4)
    plot2d(a20_7(:,1),[a20_7(:,2),a20_7(:,3),a20_7(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 2.7: Pulso 7 da figura 1.1 medidos pelo acelerômetro em L=20cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])

f3 = scf(3)
    // plot2d dos pulsos da figura 1.1 cortados em vetores individuais
    f=gcf();
    f.color_map=hsvcolormap(3); // Setando a escala de cores do gráfico
    
    subplot(3,2,1)
    plot2d(a25_1(:,1),[a25_1(:,2),a25_1(:,3),a25_1(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 3.1: Pulso 1 da figura 1.2 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])

    subplot(3,2,2)
    plot2d(a25_2(:,1),[a25_2(:,2),a25_2(:,3),a25_2(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 3.2: Pulso 1 da figura 1.3 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(3,2,3)
    plot2d(a25_3(:,1),[a25_3(:,2),a25_3(:,3),a25_3(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 3.3: Pulso 1 da figura 1.4 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(3,2,4)
    plot2d(a25_4(:,1),[a25_4(:,2),a25_4(:,3),a25_4(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 3.4: Pulso 2 da figura 1.4 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(3,2,5)
    plot2d(a25_5(:,1),[a25_5(:,2),a25_5(:,3),a25_5(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 3.5: Pulso 3 da figura 1.4 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    subplot(3,2,6)
    plot2d(a25_6(:,1),[a25_6(:,2),a25_6(:,3),a25_6(:,4)]);       // plot2dando [ax,ay,az] x t
    title('Figura 3.6: Pulso 4 da figura 1.4 medidos pelo acelerômetro em L=25cm')
    xlabel('t (s)');
    ylabel('a (m/s^2)');
    legend(['ax';'ay';'az'])
    
    
f4= scf(4)
    //plot2d(1:length(fa_a20),fa_a20')
    plot2d(1:length(fa_a25_a),fa_a25_a',style=color('scilabgreen4') )
    //plot2d(1:length(fa_a25_b),fa_a25_b')
    //plot2d(1:length(fa_a25_c),fa_a25_c')

    title('Figura 4: Frequência de amostragem das medidas do acelerômetro para o sinal 1 de L=25cm')
    xlabel('Intervalo de medida')
    ylabel('fa [Hz]')    
    
f5= scf(5)
    subplot(2,1,1)
    // plot2da-se os valores entre 5s e 11s
    plot2d(teste_freq_iphone(:,1), teste_freq_iphone(:,5), style = color('cyan'))
    plot2d(teste_freq_android(:,1), teste_freq_android(:,5), style = color('dark blue'))

    title('Figura 5.1: Acelerações de impulsos aplicados espaçados de 5s')
    xlabel('t(s)')
    ylabel('|a| (m/s^2)')
    legend(['iPhone';'Android'])
    
    subplot(2,1,2)
    plot2d(1:length(fa_teste_iphone),fa_teste_iphone, style = color('cyan'))
    plot2d(1:length(fa_teste_android),fa_teste_android, style = color('dark blue'))
    
    title('Figura 5.2: Frequência de amostragem das medidas do acelerômetro para o experimento teste')
    xlabel('Intervalo de medida')
    ylabel('fa [Hz]')
    legend(['iPhone';'Android'])
    
f6 = scf(6)
    // Figura 6: plot2d dos espectros de pulsos para L=20cm e para L=25
    subplot(2,1,1)
    plot2d(f_a20_1, espectro_a20_1, style = color(cores(1)));
    plot2d(f_a20_2, espectro_a20_2, style = color(cores(2)));
    plot2d(f_a20_3, espectro_a20_3, style = color(cores(3)));
    plot2d(f_a20_4, espectro_a20_4, style = color(cores(4)));
    plot2d(f_a20_5, espectro_a20_5, style = color(cores(5)));
    plot2d(f_a20_6, espectro_a20_6, style = color(cores(6)));
    plot2d(f_a20_7, espectro_a20_7, style = color(cores(7)));
    title('Figura 6.1: Espectro do módulo da aceleração dos pulsos medidos pelo acelerômetro em L=20cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

    subplot(2,1,2)
    plot2d(f_a25_1, espectro_a25_1, style = color(cores(1)));
    plot2d(f_a25_2, espectro_a25_2, style = color(cores(2)));
    plot2d(f_a25_3, espectro_a25_3, style = color(cores(3)));
    plot2d(f_a25_4, espectro_a25_4, style = color(cores(4)));
    plot2d(f_a25_5, espectro_a25_5, style = color(cores(5)));
    plot2d(f_a25_6, espectro_a25_6, style = color(cores(6)));

    title('Figura 6.2: Espectro do módulo da aceleração dos pulsos medidos pelo acelerômetro em L=25cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f7 = scf(7)
    // Figura 7: plot2d dos espectros de pulsos para L=20cm e para L=25
    subplot(2,1,1)
    plot2d(f_a20_1, espectro_a20_1_unbias, style = color(cores(1)));
    plot2d(f_a20_2, espectro_a20_2_unbias, style = color(cores(2)));
    plot2d(f_a20_3, espectro_a20_3_unbias, style = color(cores(3)));
    plot2d(f_a20_4, espectro_a20_4_unbias, style = color(cores(4)));
    plot2d(f_a20_5, espectro_a20_5_unbias, style = color(cores(5)));
    plot2d(f_a20_6, espectro_a20_6_unbias, style = color(cores(6)));
    plot2d(f_a20_7, espectro_a20_7_unbias, style = color(cores(7)));
    title('Figura 7.1: Espectro da aceleração desenviesada dos pulsos medidos pelo acelerômetro em L=20cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

    subplot(2,1,2)
    plot2d(f_a25_1, espectro_a25_1_unbias, style = color(cores(1)));
    plot2d(f_a25_2, espectro_a25_2_unbias, style = color(cores(2)));
    plot2d(f_a25_3, espectro_a25_3_unbias, style = color(cores(3)));
    plot2d(f_a25_4, espectro_a25_4_unbias, style = color(cores(4)));
    plot2d(f_a25_5, espectro_a25_5_unbias, style = color(cores(5)));
    plot2d(f_a25_6, espectro_a25_6_unbias, style = color(cores(6)));

    title('Figura 7.2: Espectro da aceleração desenviesada dos pulsos medidos pelo acelerômetro em L=25cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

//_filt


f8 = scf(8)
    // Figura 8: plot2d dos espectros de pulsos para L=20cm e para L=25
    subplot(2,1,1)
    plot2d(f_a20_1, espectro_a20_1_filt, style = color(cores(1)));
    plot2d(f_a20_2, espectro_a20_2_filt, style = color(cores(2)));
    plot2d(f_a20_3, espectro_a20_3_filt, style = color(cores(3)));
    plot2d(f_a20_4, espectro_a20_4_filt, style = color(cores(4)));
    plot2d(f_a20_5, espectro_a20_5_filt, style = color(cores(5)));
    plot2d(f_a20_6, espectro_a20_6_filt, style = color(cores(6)));
    plot2d(f_a20_7, espectro_a20_7_filt, style = color(cores(7)));
    title('Figura 8.1: Espectro do módulo da aceleração dos pulsos medidos pelo acelerômetro em L=20cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

    subplot(2,1,2)
    plot2d(f_a25_1, espectro_a25_1_filt, style = color(cores(1)));
    plot2d(f_a25_2, espectro_a25_2_filt, style = color(cores(2)));
    plot2d(f_a25_3, espectro_a25_3_filt, style = color(cores(3)));
    plot2d(f_a25_4, espectro_a25_4_filt, style = color(cores(4)));
    plot2d(f_a25_5, espectro_a25_5_filt, style = color(cores(5)));
    plot2d(f_a25_6, espectro_a25_6_filt, style = color(cores(6)));

    title('Figura 8.2: Espectro do módulo da aceleração dos pulsos medidos pelo acelerômetro em L=25cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f9 = scf(9)
    // Figura 9: plot2d individuais dos espectros de pulsos para L=20cm
    //[espectro_a20_1, f_a20_1]
    subplot(4,2,1)
    plot2d(f_a20_1, espectro_a20_1_filt, style = color(cores(1)));
    title('Figura 9.1: Espectro filtrado da aceleração do pulso 1 medidos pelo acelerômetro em L=20cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,2,2)
    plot2d(f_a20_2, espectro_a20_2_filt, style = color(cores(2)));
    title('Figura 9.2: Espectro filtrado da aceleração do pulso 2 medidos pelo acelerômetro em L=20cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,2,3)
    plot2d(f_a20_3, espectro_a20_3_filt, style = color(cores(3)));
    title('Figura 9.3: Espectro filtrado da aceleração do pulso 3 medidos pelo acelerômetro em L=20cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,2,4)
    plot2d(f_a20_4, espectro_a20_4_filt, style = color(cores(4)));
    title('Figura 9.4: Espectro filtrado da aceleração do pulso 4 medidos pelo acelerômetro em L=20cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,2,5)
    plot2d(f_a20_5, espectro_a20_5_filt, style = color(cores(5)));
    title('Figura 9.5: Espectro filtrado da aceleração do pulso 5 medidos pelo acelerômetro em L=20cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,2,6)
    plot2d(f_a20_6, espectro_a20_6_filt, style = color(cores(6)));
    title('Figura 9.6: Espectro filtrado da aceleração do pulso 6 medidos pelo acelerômetro em L=20cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_a20_7, espectro_a20_7_filt, style = color(cores(7)));
    title('Figura 9.7: Espectro filtrado da aceleração do pulso 7 medidos pelo acelerômetro em L=20cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f10= scf(10)
    // Figura 10: plot2d individuais dos espectros de pulsos para L=25cm
    //[espectro_a20_1, f_a20_1]
    subplot(3,2,1)
    plot2d(f_a25_1, espectro_a25_1_filt, style = color(cores(1)));
    title('Figura 10.1: Espectro filtrado da aceleração do pulso 1 medidos pelo acelerômetro em L=25cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(3,2,2)
    plot2d(f_a25_2, espectro_a25_2_filt, style = color(cores(2)));
    title('Figura 10.2: Espectro filtrado da aceleração do pulso 2 medidos pelo acelerômetro em L=25cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(3,2,3)
    plot2d(f_a25_3, espectro_a25_3_filt, style = color(cores(3)));
    title('Figura 10.3: Espectro filtrado da aceleração do pulso 3 medidos pelo acelerômetro em L=25cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(3,2,4)
    plot2d(f_a25_4, espectro_a25_4_filt, style = color(cores(4)));
    title('Figura 10.4: Espectro filtrado da aceleração do pulso 4 medidos pelo acelerômetro em L=25cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(3,2,5)
    plot2d(f_a25_5, espectro_a25_5_filt, style = color(cores(5)));
    title('Figura 10.5: Espectro filtrado da aceleração do pulso 5 medidos pelo acelerômetro em L=25cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(3,2,6)
    plot2d(f_a25_6, espectro_a25_6_filt, style = color(cores(6)));
    title('Figura 10.6: Espectro filtrado da aceleração do pulso 6 medidos pelo acelerômetro em L=25cm')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
