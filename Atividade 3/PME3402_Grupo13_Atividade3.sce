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
2) Certifique-se de que os dados de medida estão na pasta "/Atividade 3/Dados"
dentro da pasta do programa
3) Pressione Executar (APENAS UMA VEZ) para rodar o programa
(devido aos arquivos de áudio, pode levar cerca de 1 minuto para rodar o programa.
Cuidado ao apertar "Executar" diversas vezes. Caso isso ocorra, o programa
irá fechar as janelas que ele acabou de plitar e rodar novamente)
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

/*
1.Introdução

    Nesta tarefa, o grupo decidiu fazer o experimento de filtros digitais utilizando instrumentos musicais.
Uma vez que a frequência natural de notas musicais é conhecida pela teoria, considerou-se que a avaliação
e filtragem de ruidos levando em conta frequências naturais conhecidas se mostra eficaz.
    Foram realizados ensaios com diferentes instrumentos musicais, tocando diferentes notas em diferentes oitavas, 
com diferentes métodos de gravação das notas, totalizando 22 ensaios.
    Os instrumentos utilizados foram flauta e violão, os métodos de gravação foram o celular e um microfone,
e as notas gravadas foram Do4 (quarta oitava), Do5 (quinta oitava), Sol2 (segunda oitava), Sol3 (terceira oitava).

    Os sinais com nomeação final Sol_2_2, Sol_2_3 e Sol_2_4 são repetições da nota "sol na segunda oitava", 
que será usado para avaliar a repetibilidade do experimento e se há mais variações usando o microfone ou o celular.

    Pela teoria, a frequência natural da nota "dó" é 132Hz, na primeira oitava. Para as demais oitavas, é necessário
multiplicar a frequência natural da primeira oitava pela oitava correspondente. No caso, para o "Do4", a frequência natural
é igual a 132*4, que iguala a 528 Hz. Fazendo este procedimento para todas as notas e oitavas estudadas, chegamos
às seguintes frequências naturais:
    - Do:  132 Hz
    - Do2: 264 Hz
    - Do4: 528 Hz
    - Do5: 660 Hz
    - Sol: 196 Hz
    - Sol2: 396 Hz
    - Sol3: 594 Hz
    
    É importante ter em conta estas frequências naturais na hora de aplicar a frequência de corte no filtro, uma vez que 
não se deve utilizar um filtro com uma frequência de corte muito baixa, já que isso cortaria o sinal que se quer evidenciar.
    
    Neste experimento, vamos filtrar os resultados encontrados, eliminando ruídos do ambientes e dos dispositivos e
avaliar se os resultados de frequências naturais condizem com a da literatura. Além disso, serão analisados os diferentes métodos 
(flauta x violão e microfone x celular), e será averiguado se há diferenças significativas entre o nível de ruído entre eles
(por exemplo, se há um instrumento que apresenta um ruído natural de sua estrutura mais significativo, ou se um dos métodos 
de gravação isola melhor os ruídos do ambiente).
     
 */
      

// Identificaç dos arquivos a serem lidos
file_names = [
    'Celular_Flauta_Do4.wav', //1
    'Celular_Flauta_Do5.wav', //2
    'Celular_Flauta_Sol3.wav', //3
    'Celular_Flauta_Sol4.wav', //4
    
    'Celular_Violao_Do1.wav', //5
    'Celular_Violao_Do2.wav', //6
    'Celular_Violao_Sol2.wav', //7
    'Celular_Violao_Sol3.wav', //8
    
    'Microfone_Flauta_Do4.wav', //9
    'Microfone_Flauta_Do5.wav', //10
    'Microfone_Flauta_Sol3.wav', //11
    'Microfone_Flauta_Sol4.wav', //12
    
    'Microfone_Violao_Do1.wav', //13
    'Microfone_Violao_Do2.wav', //14
    'Microfone_Violao_Sol2.wav', //15
    'Microfone_Violao_Sol3.wav', //16
    
    'Celular_flauta_sol3_2.wav',  //17
    'Celular_flauta_sol3_3.wav', //18
    'celular_flauta_sol3_4.wav', //19
    
    'Microfone_Flauta_Sol3_2.wav', //20
    'Microfone_Flauta_Sol3_3.wav', //21
    'Microfone_Flauta_Sol3_4.wav', //22
    
];

file_path = data_directory + s + file_names;

//Leitura dos arquivos de áudio e de sua frequência de amostragem

//Vê-se necessário cortar os áudios nos pontos em que o som é efetivamente emitido, visto que a gravação começa antes e termina depois da emissão do som e isso poderia afetar a precisão da FFT
//Tal processo foi feito visualmente, analisando o instante do sinal em que o som foi emitido

// Parâmetros de amostragem
fam = 44100; //[Hz] Frequência de amostragem do microfone
fac = 44000; //[Hz] Frequência de amostragem do celular


[y, Fs] = wavread(file_path(1), [int(4.04*fac),int(8.88*fac)]);
C_F_Do4 = y;

[y, Fs] = wavread(file_path(2), [int(4.85*fac),int(9.48*fac)]);
C_F_Do5 = y;

[y, Fs] = wavread(file_path(3), [int(5.53*fac),int(10.71*fac)]);
C_F_Sol3 = y;

[y, Fs] = wavread(file_path(4), [int(3.82*fac),int(8.4*fac)]);
C_F_Sol4 = y;

[y, Fs] = wavread(file_path(5), [int(1.23*fac),int(4.85*fac)]);
C_V_Do1 = y;

[y, Fs] = wavread(file_path(6), [int(2.18*fac),int(6.94*fac)]);
C_V_Do2 = y;

[y, Fs] = wavread(file_path(7), [int(2.2*fac),int(7*fac)]);
C_V_Sol2 = y;

[y, Fs] = wavread(file_path(8), [int(2.64*fac),int(7.55*fac)]);
C_V_Sol3 = y;

[y, Fs] = wavread(file_path(9), [int(0.04*fam),int(4.775*fam)]);
M_F_Do4 = y(1,:);   //Microfone possui dois canais de gravação, porém a gravação foi feita em Mono, por isso considerou-se a gravação dos canais iguais

[y, Fs] = wavread(file_path(10), [int(2.155*fam),int(6.45*fam)]);
M_F_Do5 = y(1,:);

[y, Fs] = wavread(file_path(11), [int(0.05*fam),int(5.2*fam)]);
M_F_Sol3 = y(1,:);

[y, Fs] = wavread(file_path(12), [int(3.1*fam),int(7.45*fam)]);
M_F_Sol4 = y(1,:);

[y, Fs] = wavread(file_path(13), [int(2.4*fam),int(4.95*fam)]);
M_V_Do1 = y(1,:);

[y, Fs] = wavread(file_path(14), [int(3.64*fam),int(4.75*fam)]);
M_V_Do2 = y(1,:);

[y, Fs] = wavread(file_path(15), [int(2.35*fam),int(3.55*fam)]);
M_V_Sol2 = y(1,:);

[y, Fs] = wavread(file_path(16), [int(3.93*fam),int(4.33*fam)]);
M_V_Sol3 = y(1,:);


[y, Fs] = wavread(file_path(17), [int(3.93*fac),int(4.33*fac)]);
C_F_Sol3_2 = y;
[y, Fs] = wavread(file_path(18), [int(3.93*fac),int(4.33*fac)]);
C_F_Sol3_3 = y;
[y, Fs] = wavread(file_path(19), [int(3.93*fac),int(4.33*fac)]);
C_F_Sol3_4 = y;

[y, Fs] = wavread(file_path(20), [int(3.93*fam),int(4.33*fam)]);
M_F_Sol3_2 = y(1,:);
[y, Fs] = wavread(file_path(21), [int(3.93*fam),int(4.33*fam)]);
M_F_Sol3_3 = y(1,:);
[y, Fs] = wavread(file_path(22), [int(3.93*fam),int(4.33*fam)]);
M_F_Sol3_4 = y(1,:);


function [y] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)
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
    sinal_t --> um vetor unidimensional sinal_t (1xN) que representa o valor de um
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

fc = 800;    //analisar qual a frequência do ruído a ser cortado

[C_F_Do4_filtrado, f_C_F_Do4, espectro_C_F_Do4, espectro_C_F_Do4_filtrado] = analise_espectral(C_F_Do4,'euler-foward', fac, fc)
[C_F_Do5_filtrado, f_C_F_Do5, espectro_C_F_Do5, espectro_C_F_Do5_filtrado] = analise_espectral(C_F_Do5,'euler-foward', fac, fc)
[C_F_Sol3_filtrado, f_C_F_Sol3, espectro_C_F_Sol3, espectro_C_F_Sol3_filtrado] = analise_espectral(C_F_Sol3,'euler-foward', fac, fc)
[C_F_Sol4_filtrado, f_C_F_Sol4, espectro_C_F_Sol4, espectro_C_F_Sol4_filtrado] = analise_espectral(C_F_Sol4,'euler-foward', fac, fc)

[C_V_Do1_filtrado, f_C_V_Do1, espectro_C_V_Do1, espectro_C_V_Do1_filtrado] = analise_espectral(C_V_Do1,'euler-foward', fac, fc)
[C_V_Do2_filtrado, f_C_V_Do2, espectro_C_V_Do2, espectro_C_V_Do2_filtrado] = analise_espectral(C_V_Do2,'euler-foward', fac, fc)
[C_V_Sol2_filtrado, f_C_V_Sol2, espectro_C_V_Sol2, espectro_C_V_Sol2_filtrado] = analise_espectral(C_V_Sol2,'euler-foward', fac, fc)
[C_V_Sol3_filtrado, f_C_V_Sol3, espectro_C_V_Sol3, espectro_C_V_Sol3_filtrado] = analise_espectral(C_V_Sol3,'euler-foward', fac, fc)

[M_F_Do4_filtrado, f_M_F_Do4, espectro_M_F_Do4, espectro_M_F_Do4_filtrado] = analise_espectral(M_F_Do4,'euler-foward', fam, fc)
[M_F_Do5_filtrado, f_M_F_Do5, espectro_M_F_Do5, espectro_M_F_Do5_filtrado] = analise_espectral(M_F_Do5,'euler-foward', fam, fc)
[M_F_Sol3_filtrado, f_M_F_Sol3, espectro_M_F_Sol3, espectro_M_F_Sol3_filtrado] = analise_espectral(M_F_Sol3,'euler-foward', fam, fc)
[M_F_Sol4_filtrado, f_M_F_Sol4, espectro_M_F_Sol4, espectro_M_F_Sol4_filtrado] = analise_espectral(M_F_Sol4,'euler-foward', fam, fc)

[M_V_Do1_filtrado, f_M_V_Do1, espectro_M_V_Do1, espectro_M_V_Do1_filtrado] = analise_espectral(M_V_Do1,'euler-foward', fam, fc)
[M_V_Do2_filtrado, f_M_V_Do2, espectro_M_V_Do2, espectro_M_V_Do2_filtrado] = analise_espectral(M_V_Do2,'euler-foward', fam, fc)
[M_V_Sol2_filtrado, f_M_V_Sol2, espectro_M_V_Sol2, espectro_M_V_Sol2_filtrado] = analise_espectral(M_V_Sol2,'euler-foward', fam, fc)
[M_V_Sol3_filtrado, f_M_V_Sol3, espectro_M_V_Sol3, espectro_M_V_Sol3_filtrado] = analise_espectral(M_V_Sol3,'euler-foward', fam, fc)

[C_F_Sol3_2_filtrado, f_C_F_Sol3_2, espectro_C_F_Sol3_2, espectro_C_F_Sol3_2_filtrado] = analise_espectral(C_F_Sol3_2,'euler-foward', fac, fc)
[C_F_Sol3_3_filtrado, f_C_F_Sol3_3, espectro_C_F_Sol3_3, espectro_C_F_Sol3_3_filtrado] = analise_espectral(C_F_Sol3_3,'euler-foward', fac, fc)
[C_F_Sol3_4_filtrado, f_C_F_Sol3_4, espectro_C_F_Sol3_4, espectro_C_F_Sol3_4_filtrado] = analise_espectral(C_F_Sol3_4,'euler-foward', fac, fc)

[M_F_Sol3_2_filtrado, f_M_F_Sol3_2, espectro_M_F_Sol3_2, espectro_M_F_Sol3_2_filtrado] = analise_espectral(M_F_Sol3_2,'euler-foward', fam, fc)
[M_F_Sol3_3_filtrado, f_M_F_Sol3_3, espectro_M_F_Sol3_3, espectro_M_F_Sol3_3_filtrado] = analise_espectral(M_F_Sol3_3,'euler-foward', fam, fc)
[M_F_Sol3_4_filtrado, f_M_F_Sol3_4, espectro_M_F_Sol3_4, espectro_M_F_Sol3_4_filtrado] = analise_espectral(M_F_Sol3_4,'euler-foward', fam, fc)

// ============================================================
// ANÁLISE DOS RESULTADOS
/*
A partir do tratamento de dados, foi possível obter os espectros de
frequência de cada uma das notas musicais gravadas (Dó4, Dó5, Sol4, Sol5)
tocadas na Flauta e no Violão e gravadas tanto por meio de um microfone
quanto por meio de um aparelho celular. Além disso, um filtro digital
foi aplicado no sinal temporal e foi possível obter o espectro de frequência
do som filtrado.

O filtro digital utilizado foi um filtro de primeira ordem e que utiliza
o método de Euler para integração numérica. Como as notas gravadas
possuem frequências naturais entre 528 e 792 Hz, o filtro passa-baixa foi
aplicado no sinal temporal para uma frequência de corte de 800Hz.
 
Como pode-se perceber pela análise espectral dos sinais originais, as
frequências que apresentam um pico máximo no espectro são próximas às
frequências da nota tocada tanto para os sinais gravados pelo Microfone
quanto para o Celular. O sinal também apresenta harmônicos,
ou picos de amplitudes de espectro cada vez menores nas frequências que
são múltiplas inteiras da frequência natural da nota original. Esse
resultado era esperado de acordo com a teoria de acústica para instrumentos
de sopro e corda, uma vez que o som produzido por esses instrumentos
não é composto apenas da frequência da nota, mas também de seus harmônicos.

Para uma análise mais detalhada, primeiramente analizaremos as medições
para a nota Dó4, que possui frequência 528 Hz, produzidas pelo Violão


*/

// ============================================================
// PLOTAGEM DOS GRÁFICOS

tempo_C_F_Do4 = linspace(0, size(C_F_Do4)(2)/fac, size(C_F_Do4)(2))
tempo_C_F_Do5 = linspace(0, size(C_F_Do5)(2)/fac, size(C_F_Do5)(2))
tempo_C_F_Sol3 = linspace(0, size(C_F_Sol3)(2)/fac, size(C_F_Sol3)(2))
tempo_C_F_Sol4 = linspace(0, size(C_F_Sol4)(2)/fac, size(C_F_Sol4)(2))

tempo_C_V_Do1 = linspace(0, size(C_V_Do1)(2)/fac, size(C_V_Do1)(2))
tempo_C_V_Do2 = linspace(0, size(C_V_Do2)(2)/fac, size(C_V_Do2)(2))
tempo_C_V_Sol2 = linspace(0, size(C_V_Sol2)(2)/fac, size(C_V_Sol2)(2))
tempo_C_V_Sol3 = linspace(0, size(C_V_Sol3)(2)/fac, size(C_V_Sol3)(2))

tempo_M_F_Do4 = linspace(0, size(M_F_Do4)(2)/fam, size(M_F_Do4)(2))
tempo_M_F_Do5 = linspace(0, size(M_F_Do5)(2)/fam, size(M_F_Do5)(2))
tempo_M_F_Sol3 = linspace(0, size(M_F_Sol3)(2)/fam, size(M_F_Sol3)(2))
tempo_M_F_Sol4 = linspace(0, size(M_F_Sol4)(2)/fam, size(M_F_Sol4)(2))

tempo_M_V_Do1 = linspace(0, size(M_V_Do1)(2)/fam, size(M_V_Do1)(2))
tempo_M_V_Do2 = linspace(0, size(M_V_Do2)(2)/fam, size(M_V_Do2)(2))
tempo_M_V_Sol2 = linspace(0, size(M_V_Sol2)(2)/fam, size(M_V_Sol2)(2))
tempo_M_V_Sol3 = linspace(0, size(M_V_Sol3)(2)/fam, size(M_V_Sol3)(2))

/*
tempo_C_F_Sol3_2 = linspace(0, size(C_F_Sol3_2)(2)/fac, size(C_F_Sol3_2)(2))
tempo_C_F_Sol3_3 = linspace(0, size(C_F_Sol3_3)(2)/fac, size(C_F_Sol3_3)(2))
tempo_C_F_Sol3_4 = linspace(0, size(C_F_Sol3_4)(2)/fac, size(C_F_Sol3_4)(2))

tempo_M_F_Sol3_2 = linspace(0, size(M_F_Sol3_2)(2)/fac, size(M_F_Sol3_2)(2))
tempo_M_F_Sol3_3 = linspace(0, size(M_F_Sol3_3)(2)/fac, size(M_F_Sol3_3)(2))
tempo_M_F_Sol3_4 = linspace(0, size(M_F_Sol3_4)(2)/fac, size(M_F_Sol3_4)(2))
*/

cores = [
'blue4',
'springgreen4',
'firebrick1',
'magenta3',
]

/*
Plotagem dos gráficos, para cada nota, instrumento e método de medição, dos sinais temporais originais e filtrados
e dos espectro de frequência do sinal originais e filtrados. 
*/

f1 = scf(1)
    subplot(4,1,1)
    plot2d(tempo_C_F_Do4, C_F_Do4, color(cores(1)) );
    title('Figura 1.1: Sinal temporal discretizado (Celular, Flauta, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_F_Do4, C_F_Do4_filtrado, color(cores(1)) );
    title('Figura 1.2: Sinal temporal discretizado filtrado (Celular, Flauta, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_C_F_Do4, espectro_C_F_Do4, color(cores(1)) );
    title('Figura 1.3: Espectro de frequência do sinal (Celular, Flauta, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_F_Do4, espectro_C_F_Do4_filtrado, color(cores(1)) );
    title('Figura 1.4: Espectro de frequência do sinal filtrado (Celular, Flauta, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    
f9 = scf(9)
    subplot(4,1,1)
    plot2d(tempo_M_F_Do4, M_F_Do4, color(cores(1)) );
    title('Figura 3.1: Sinal temporal discretizado (Microfone, Flauta, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_F_Do4, M_F_Do4_filtrado, color(cores(1)) );
    title('Figura 3.2: Sinal temporal discretizado filtrado (Microfone, Flauta, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_M_F_Do4, espectro_M_F_Do4, color(cores(1)) );
    title('Figura 3.3: Espectro de frequência do sinal (Microfone, Flauta, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_F_Do4, espectro_M_F_Do4_filtrado, color(cores(1)) );
    title('Figura 3.4: Espectro de frequência do sinal filtrado (Microfone, Flauta, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f6 = scf(6)
    subplot(4,1,1)
    plot2d(tempo_C_V_Do2, C_V_Do2, color(cores(2)) );
    title('Sinal temporal discretizado (Celular, Violão, Do2)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_V_Do2, C_V_Do2_filtrado, color(cores(2)) );
    title('Sinal temporal discretizado (Celular, Violão, Do2)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_C_V_Do2, espectro_C_V_Do2, color(cores(2)) );
    title('Espectro de frequência do sinal (Celular, Violão, Do2)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_V_Do2, espectro_C_V_Do2_filtrado, color(cores(2)) );
    title('Espectro de frequência do sinal filtrado (Celular, Violão, Do2)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f14 = scf(14)
    subplot(4,1,1)
    plot2d(tempo_M_V_Do2, M_V_Do2, color(cores(2)) );
    title('Sinal temporal discretizado (Microfone, Violão, Do2)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_V_Do2, M_V_Do2_filtrado, color(cores(2)) );
    title('Sinal temporal discretizado (Microfone, Violão, Do2)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_M_V_Do2, espectro_M_V_Do2, color(cores(2)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Do2)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_V_Do2, espectro_M_V_Do2_filtrado, color(cores(2)) );
    title('Espectro de frequência do sinal filtrado (Microfone, Violão, Do2)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');


/*
// Demais comparações entre espectros de sinais originais e filtrados
f2 = scf(2)
    subplot(4,1,1)
    plot2d(tempo_C_F_Do5, C_F_Do5, color(cores(2)) );
    title('Sinal temporal discretizado (Celular, Flauta, Do5)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_F_Do5, C_F_Do5_filtrado, color(cores(2)) );
    title('Sinal temporal discretizado (Celular, Flauta, Do5)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_C_F_Do5, espectro_C_F_Do5, color(cores(2)) );
    title('Espectro de frequência do sinal (Celular, Flauta, Do5)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_F_Do5, espectro_C_F_Do5_filtrado, color(cores(2)) );
    title('Espectro de frequência do sinal filtrado (Celular, Flauta, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f3 = scf(3)
    subplot(4,1,1)
    plot2d(tempo_C_F_Sol3, C_F_Sol3, color(cores(3)) );
    title('Sinal temporal discretizado (Celular, Flauta, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_F_Sol3, C_F_Sol3_filtrado, color(cores(3)) );
    title('Sinal temporal discretizado (Celular, Flauta, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_C_F_Sol3, espectro_C_F_Sol3, color(cores(3)) );
    title('Espectro de frequência do sinal (Celular, Flauta, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_F_Sol3, espectro_C_F_Sol3_filtrado, color(cores(3)) );
    title('Espectro de frequência do sinal (Celular, Flauta, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f4 = scf(4)
    subplot(4,1,1)
    plot2d(tempo_C_F_Sol4, C_F_Sol4, color(cores(4)) );
    title('Sinal temporal discretizado (Celular, Flauta, Sol4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_F_Sol4, C_F_Sol4_filtrado, color(cores(4)) );
    title('Sinal temporal discretizado (Celular, Flauta, Sol4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_C_F_Sol4, espectro_C_F_Sol4, color(cores(4)) );
    title('Espectro de frequência do sinal (Celular, Flauta, Sol4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_F_Sol4, espectro_C_F_Sol4_filtrado, color(cores(4)) );
    title('Espectro de frequência do sinal (Celular, Flauta, Sol4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    
f5 = scf(5)
    subplot(4,1,1)
    plot2d(tempo_C_V_Do1, C_V_Do1, color(cores(1)) );
    title('Figura 2.1: Sinal temporal discretizado (Celular, Violão, Do1)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_V_Do1, C_V_Do1_filtrado, color(cores(1)) );
    title('Figura 2.2: Sinal temporal discretizado filtrado (Celular, Violão, Do1)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_C_V_Do1, espectro_C_V_Do1, color(cores(1)) );
    title('Figura 2.3: Espectro de frequência do sinal (Celular, Violão, Do1)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_V_Do1, espectro_C_V_Do1_filtrado, color(cores(1)) );
    title('Figura 2.4: Espectro de frequência do sinal filtrado (Celular, Violão, Do1)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f7 = scf(7)
    subplot(4,1,1)
    plot2d(tempo_C_V_Sol2, C_V_Sol2, color(cores(3)) );
    title('Sinal temporal discretizado (Celular, Violão, Sol2)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_V_Sol2, C_V_Sol2_filtrado, color(cores(3)) );
    title('Sinal temporal discretizado (Celular, Violão, Sol2)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_C_V_Sol2, espectro_C_V_Sol2, color(cores(3)) );
    title('Espectro de frequência do sinal (Celular, Violão, Sol2)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_V_Sol2, espectro_C_V_Sol2_filtrado, color(cores(3)) );
    title('Espectro de frequência do sinal (Celular, Violão, Sol2)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f8 = scf(8)
    subplot(4,1,1)
    plot2d(tempo_C_V_Sol3, C_V_Sol3, color(cores(4)) );
    title('Sinal temporal discretizado (Celular, Violão, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_V_Sol3, C_V_Sol3_filtrado, color(cores(4)) );
    title('Sinal temporal discretizado (Celular, Violão, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_C_V_Sol3, espectro_C_V_Sol3, color(cores(4)) );
    title('Espectro de frequência do sinal (Celular, Violão, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_V_Sol3, espectro_C_V_Sol3_filtrado, color(cores(4)) );
    title('Espectro de frequência do sinal (Celular, Violão, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    

f10 = scf(10)
    subplot(4,1,1)
    plot2d(tempo_M_F_Do5, M_F_Do5, color(cores(2)) );
    title('Sinal temporal discretizado (Microfone, Flauta, Do5)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_F_Do5, M_F_Do5_filtrado, color(cores(2)) );
    title('Sinal temporal discretizado (Microfone, Flauta, Do5)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_M_F_Do5, espectro_M_F_Do5, color(cores(2)) );
    title('Espectro de frequência do sinal (Microfone, Flauta, Do5)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_F_Do5, espectro_M_F_Do5_filtrado, color(cores(2)) );
    title('Espectro de frequência do sinal filtrado (Microfone, Flauta, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f11 = scf(11)
    subplot(4,1,1)
    plot2d(tempo_M_F_Sol3, M_F_Sol3, color(cores(3)) );
    title('Sinal temporal discretizado (Microfone, Flauta, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_F_Sol3, M_F_Sol3_filtrado, color(cores(3)) );
    title('Sinal temporal discretizado (Microfone, Flauta, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_M_F_Sol3, espectro_M_F_Sol3, color(cores(3)) );
    title('Espectro de frequência do sinal (Microfone, Flauta, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_F_Sol3, espectro_M_F_Sol3_filtrado, color(cores(3)) );
    title('Espectro de frequência do sinal (Microfone, Flauta, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f12 = scf(12)
    subplot(4,1,1)
    plot2d(tempo_M_F_Sol4, M_F_Sol4, color(cores(4)) );
    title('Sinal temporal discretizado (Microfone, Flauta, Sol4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_F_Sol4, M_F_Sol4_filtrado, color(cores(4)) );
    title('Sinal temporal discretizado (Microfone, Flauta, Sol4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_M_F_Sol4, espectro_M_F_Sol4, color(cores(4)) );
    title('Espectro de frequência do sinal (Microfone, Flauta, Sol4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_F_Sol4, espectro_M_F_Sol4_filtrado, color(cores(4)) );
    title('Espectro de frequência do sinal (Microfone, Flauta, Sol4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f13 = scf(13)
    subplot(4,1,1)
    plot2d(tempo_M_V_Do1, M_V_Do1, color(cores(1)) );
    title('Figura 4.1: Sinal temporal discretizado (Microfone, Violão, Do1)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_V_Do1, M_V_Do1_filtrado, color(cores(1)) );
    title('Figura 4.2: Sinal temporal discretizado filtrado (Microfone, Violão, Do1)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_M_V_Do1, espectro_M_V_Do1, color(cores(1)) );
    title('Figura 4.3: Espectro de frequência do sinal (Microfone, Violão, Do1)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_V_Do1, espectro_M_V_Do1_filtrado, color(cores(1)) );
    title('Figura 4.4: Espectro de frequência do sinal filtrado (Microfone, Violão, Do1)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f15 = scf(15)
    subplot(4,1,1)
    plot2d(tempo_M_V_Sol2, M_V_Sol2, color(cores(3)) );
    title('Sinal temporal discretizado (Microfone, Violão, Sol2)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_V_Sol2, M_V_Sol2_filtrado, color(cores(3)) );
    title('Sinal temporal discretizado (Microfone, Violão, Sol2)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_M_V_Sol2, espectro_M_V_Sol2, color(cores(3)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Sol2)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_V_Sol2, espectro_M_V_Sol2_filtrado, color(cores(3)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Sol2)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f16 = scf(16)
    subplot(4,1,1)
    plot2d(tempo_M_V_Sol3, M_V_Sol3, color(cores(4)) );
    title('Sinal temporal discretizado (Microfone, Violão, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_V_Sol3, M_V_Sol3_filtrado, color(cores(4)) );
    title('Sinal temporal discretizado (Microfone, Violão, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_M_V_Sol3, espectro_M_V_Sol3, color(cores(4)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_V_Sol3, espectro_M_V_Sol3_filtrado, color(cores(4)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
*/

/*
Plotagem dos gráficos, para fins de comparação e avaliação da qualidade dos áudios. Na figura 18, são comparados os sinais 
gerados para o celular e o microfone, para a flauta tocando Do4, e analogamente para os demais gráficos.
*/


f18= scf (18)
    subplot(1,1,1)
    plot2d(f_C_F_Do4, espectro_C_F_Do4_filtrado, color(cores(1)) );
    plot2d(f_M_F_Do4, espectro_M_F_Do4_filtrado, color(cores(3)) );
    hl=legend(['Celular';'Microfone']);
    
    zoom_rect([500,0,540,6000]);
    title('Espectro de frequência do sinal filtrado (Celular e microfone, Flauta, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f19= scf (19)
    subplot(1,1,1)
    plot2d(f_C_V_Do1, espectro_C_V_Do1_filtrado, color(cores(2)) );
    plot2d(f_M_V_Do1, espectro_M_V_Do1_filtrado, color(cores(4)) );
    hl=legend(['Celular';'Microfone']);
    
    zoom_rect([100,0,540,6000]);
    title('Espectro de frequência do sinal filtrado (Celular e microfone, Violão, Do1)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f20= scf (20)
    subplot(1,1,1)
    plot2d(f_C_F_Do5, espectro_C_F_Do5_filtrado, color(cores(1)) );
    plot2d(f_M_F_Do5, espectro_M_F_Do5_filtrado, color(cores(3)) );
    hl=legend(['Celular';'Microfone']);
    
    zoom_rect([0,0,2200,6000]);
    title('Espectro de frequência do sinal filtrado (Celular e microfone, Flauta, Do5)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f21= scf (21)
    subplot(1,1,1)
    plot2d(f_C_V_Do2, espectro_C_V_Do2_filtrado, color(cores(2)) );
    plot2d(f_M_V_Do2, espectro_M_V_Do2_filtrado, color(cores(4)) );
    hl=legend(['Celular';'Microfone']);
    
    zoom_rect([000,0,800,1500]);
    title('Espectro de frequência do sinal filtrado (Celular e microfone, Violão, Do2)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f22= scf (22)
    subplot(1,1,1)
    plot2d(f_C_V_Do2, espectro_C_V_Do2_filtrado, color(cores(2)) );
    plot2d(f_M_V_Do2, espectro_M_V_Do2_filtrado, color(cores(4)) );
    hl=legend(['Celular';'Microfone']);
    
    zoom_rect([000,0,350,1500]);
    title('Espectro de frequência do sinal filtrado (Celular e microfone, Violão, Do2), com enfoque no segundo harmônico')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f23= scf (23)

    subplot(1,1,1)
    plot2d(f_C_F_Sol3_2, espectro_C_F_Sol3_2_filtrado, color(cores(1)) );
    plot2d(f_C_F_Sol3_3, espectro_C_F_Sol3_3_filtrado, color(cores(2)) );
    plot2d(f_C_F_Sol3_4, espectro_C_F_Sol3_4_filtrado, color(cores(3)) );
    hl=legend(['Medição 1';'Medição 2';'Medição 3']);
    
    zoom_rect([100,0,900,2000]);
    title('Espectro de frequência do sinal filtrado (Celular, Flauta, Sol3, 3 medições da mesma nota)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f24= scf (24)

    subplot(1,1,1)
    plot2d(f_M_F_Sol3_2, espectro_M_F_Sol3_2_filtrado, color(cores(1)) );
    plot2d(f_M_F_Sol3_3, espectro_M_F_Sol3_3_filtrado, color(cores(2)) );
    plot2d(f_M_F_Sol3_4, espectro_M_F_Sol3_4_filtrado, color(cores(3)) );
    hl=legend(['Medição 1';'Medição 2';'Medição 3']);
    
    zoom_rect([100,0,900,2000]);
    title('Espectro de frequência do sinal filtrado (Microfone, Flauta, Sol3, 3 medições da mesma nota)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
