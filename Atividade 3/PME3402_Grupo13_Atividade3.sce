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

base_path = 'D:\Poli\8 semestre\Lab de medicoes\PME3402-Laboratorio-de-Medicao-e-Controle-Discreto-master\Atividade 3';
data_directory = base_path + s + 'Dados';

// Identificação dos arquivos a serem lidos
file_names = [
    'Celular_Flauta_Do4.wav',
    'Celular_Flauta_Do5.wav',
    'Celular_Flauta_Sol3.wav',
    'Celular_Flauta_Sol4.wav',
    'Celular_Violao_Do4.wav',
    'Celular_Violao_Do5.wav',
    'Celular_Violao_Sol3.wav',
    'Celular_Violao_Sol4.wav',
    'Microfone_Flauta_Do4.wav',
    'Microfone_Flauta_Do5.wav',
    'Microfone_Flauta_Sol3.wav',
    'Microfone_Flauta_Sol4.wav',
    'Microfone_Violao_Do4.wav',
    'Microfone_Violao_Do5.wav',
    'Microfone_Violao_Sol3.wav',
    'Microfone_Violao_Sol4.wav',
    
    'Celular_flauta_sol3_2.wav',
    'Celular_flauta_sol3_3.wav',
    'celular_flauta_sol3_4.wav',
    'Microfone_Flauta_Sol3_2.wav',
    'Microfone_Flauta_Sol3_3.wav',
    'Microfone_Flauta_Sol3_4.wav',
    
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
C_V_Do4 = y;

[y, Fs] = wavread(file_path(6), [int(2.18*fac),int(6.94*fac)]);
C_V_Do5 = y;

[y, Fs] = wavread(file_path(7), [int(2.2*fac),int(7*fac)]);
C_V_Sol3 = y;

[y, Fs] = wavread(file_path(8), [int(2.64*fac),int(7.55*fac)]);
C_V_Sol4 = y;

[y, Fs] = wavread(file_path(9), [int(0.04*fam),int(4.775*fam)]);
M_F_Do4 = y(1,:);   //Microfone possui dois canais de gravação, porém a gravação foi feita em Mono, por isso considerou-se a gravação dos canais iguais

[y, Fs] = wavread(file_path(10), [int(2.155*fam),int(6.45*fam)]);
M_F_Do5 = y(1,:);

[y, Fs] = wavread(file_path(11), [int(0.05*fam),int(5.2*fam)]);
M_F_Sol3 = y(1,:);

[y, Fs] = wavread(file_path(12), [int(3.1*fam),int(7.45*fam)]);
M_F_Sol4 = y(1,:);

[y, Fs] = wavread(file_path(13), [int(2.4*fam),int(4.95*fam)]);
M_V_Do4 = y(1,:);

[y, Fs] = wavread(file_path(14), [int(3.64*fam),int(4.75*fam)]);
M_V_Do5 = y(1,:);

[y, Fs] = wavread(file_path(15), [int(2.35*fam),int(3.55*fam)]);
M_V_Sol3 = y(1,:);

[y, Fs] = wavread(file_path(16), [int(3.93*fam),int(4.33*fam)]);
M_V_Sol4 = y(1,:);


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



// ============================================================
// ANÁLISE DOS DADOS


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
fc = 30;    //analisar qual a frequência do ruído a ser cortado
[C_F_Do4_filtrado, f_C_F_Do4, espectro_C_F_Do4, espectro_C_F_Do4_filtrado] = analise_espectral(C_F_Do4,'euler-foward', fac, fc)
[C_F_Do5_filtrado, f_C_F_Do5, espectro_C_F_Do5, espectro_C_F_Do5_filtrado] = analise_espectral(C_F_Do5,'euler-foward', fac, fc)
[C_F_Sol3_filtrado, f_C_F_Sol3, espectro_C_F_Sol3, espectro_C_F_Sol3_filtrado] = analise_espectral(C_F_Sol3,'euler-foward', fac, fc)
[C_F_Sol4_filtrado, f_C_F_Sol4, espectro_C_F_Sol4, espectro_C_F_Sol4_filtrado] = analise_espectral(C_F_Sol4,'euler-foward', fac, fc)
[C_V_Do4_filtrado, f_C_V_Do4, espectro_C_V_Do4, espectro_C_V_Do4_filtrado] = analise_espectral(C_V_Do4,'euler-foward', fac, fc)
[C_V_Do5_filtrado, f_C_V_Do5, espectro_C_V_Do5, espectro_C_V_Do5_filtrado] = analise_espectral(C_V_Do5,'euler-foward', fac, fc)
[C_V_Sol3_filtrado, f_C_V_Sol3, espectro_C_V_Sol3, espectro_C_V_Sol3_filtrado] = analise_espectral(C_V_Sol3,'euler-foward', fac, fc)
[C_V_Sol4_filtrado, f_C_V_Sol4, espectro_C_V_Sol4, espectro_C_V_Sol4_filtrado] = analise_espectral(C_V_Sol4,'euler-foward', fac, fc)
[M_F_Do4_filtrado, f_M_F_Do4, espectro_M_F_Do4, espectro_M_F_Do4_filtrado] = analise_espectral(M_F_Do4,'euler-foward', fam, fc)
[M_F_Do5_filtrado, f_M_F_Do5, espectro_M_F_Do5, espectro_M_F_Do5_filtrado] = analise_espectral(M_F_Do5,'euler-foward', fam, fc)
[M_F_Sol3_filtrado, f_M_F_Sol3, espectro_M_F_Sol3, espectro_M_F_Sol3_filtrado] = analise_espectral(M_F_Sol3,'euler-foward', fam, fc)
[M_F_Sol4_filtrado, f_M_F_Sol4, espectro_M_F_Sol4, espectro_M_F_Sol4_filtrado] = analise_espectral(M_F_Sol4,'euler-foward', fam, fc)
[M_V_Do4_filtrado, f_M_V_Do4, espectro_M_V_Do4, espectro_M_V_Do4_filtrado] = analise_espectral(M_V_Do4,'euler-foward', fam, fc)
[M_V_Do5_filtrado, f_M_V_Do5, espectro_M_V_Do5, espectro_M_V_Do5_filtrado] = analise_espectral(M_V_Do5,'euler-foward', fam, fc)
[M_V_Sol3_filtrado, f_M_V_Sol3, espectro_M_V_Sol3, espectro_M_V_Sol3_filtrado] = analise_espectral(M_V_Sol3,'euler-foward', fam, fc)
[M_V_Sol4_filtrado, f_M_V_Sol4, espectro_M_V_Sol4, espectro_M_V_Sol4_filtrado] = analise_espectral(M_V_Sol4,'euler-foward', fam, fc)

[C_F_Sol3_2_filtrado, f_C_F_Sol3_2, espectro_C_F_Sol3_2, espectro_C_F_Sol3_2_filtrado] = analise_espectral(C_F_Sol3_2,'euler-foward', fac, fc)
[C_F_Sol3_3_filtrado, f_C_F_Sol3_3, espectro_C_F_Sol3_3, espectro_C_F_Sol3_3_filtrado] = analise_espectral(C_F_Sol3_3,'euler-foward', fac, fc)
[C_F_Sol3_4_filtrado, f_C_F_Sol3_4, espectro_C_F_Sol3_4, espectro_C_F_Sol3_4_filtrado] = analise_espectral(C_F_Sol3_4,'euler-foward', fac, fc)

[M_F_Sol3_2_filtrado, f_M_F_Sol3_2, espectro_M_F_Sol3_2, espectro_M_F_Sol3_2_filtrado] = analise_espectral(M_F_Sol3_2,'euler-foward', fam, fc)
[M_F_Sol3_3_filtrado, f_M_F_Sol3_3, espectro_M_F_Sol3_3, espectro_M_F_Sol3_3_filtrado] = analise_espectral(M_F_Sol3_3,'euler-foward', fam, fc)
[M_F_Sol3_4_filtrado, f_M_F_Sol3_4, espectro_M_F_Sol3_4, espectro_M_F_Sol3_4_filtrado] = analise_espectral(M_F_Sol3_4,'euler-foward', fam, fc)


// ============================================================
// PLOTAGEM DOS GRÁFICOS

tempo_C_F_Do4 = linspace(0, size(C_F_Do4)(2)/fac, size(C_F_Do4)(2))
tempo_C_F_Do5 = linspace(0, size(C_F_Do5)(2)/fac, size(C_F_Do5)(2))
tempo_C_F_Sol3 = linspace(0, size(C_F_Sol3)(2)/fac, size(C_F_Sol3)(2))
tempo_C_F_Sol4 = linspace(0, size(C_F_Sol4)(2)/fac, size(C_F_Sol4)(2))
tempo_C_V_Do4 = linspace(0, size(C_V_Do4)(2)/fac, size(C_V_Do4)(2))
tempo_C_V_Do5 = linspace(0, size(C_V_Do5)(2)/fac, size(C_V_Do5)(2))
tempo_C_V_Sol3 = linspace(0, size(C_V_Sol3)(2)/fac, size(C_V_Sol3)(2))
tempo_C_V_Sol4 = linspace(0, size(C_V_Sol4)(2)/fac, size(C_V_Sol4)(2))
tempo_M_F_Do4 = linspace(0, size(M_F_Do4)(2)/fam, size(M_F_Do4)(2))
tempo_M_F_Do5 = linspace(0, size(M_F_Do5)(2)/fam, size(M_F_Do5)(2))
tempo_M_F_Sol3 = linspace(0, size(M_F_Sol3)(2)/fam, size(M_F_Sol3)(2))
tempo_M_F_Sol4 = linspace(0, size(M_F_Sol4)(2)/fam, size(M_F_Sol4)(2))
tempo_M_V_Do4 = linspace(0, size(M_V_Do4)(2)/fam, size(M_V_Do4)(2))
tempo_M_V_Do5 = linspace(0, size(M_V_Do5)(2)/fam, size(M_V_Do5)(2))
tempo_M_V_Sol3 = linspace(0, size(M_V_Sol3)(2)/fam, size(M_V_Sol3)(2))
tempo_M_V_Sol4 = linspace(0, size(M_V_Sol4)(2)/fam, size(M_V_Sol4)(2))

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

f1 = scf(1)
    subplot(4,1,1)
    plot2d(tempo_C_F_Do4, C_F_Do4, color(cores(1)) );
    title('Sinal temporal discretizado (Celular, Flauta, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_F_Do4, C_F_Do4_filtrado, color(cores(1)) );
    title('Sinal temporal discretizado filtrado (Celular, Flauta, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_C_F_Do4, espectro_C_F_Do4, color(cores(1)) );
    title('Espectro de frequência do sinal (Celular, Flauta, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_F_Do4, espectro_C_F_Do4_filtrado, color(cores(1)) );
    title('Espectro de frequência do sinal filtrado (Celular, Flauta, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

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
/*
f5 = scf(5)
    subplot(4,1,1)
    plot2d(tempo_C_V_Do4, C_V_Do4, color(cores(1)) );
    title('Sinal temporal discretizado (Celular, Violão, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_V_Do4, C_V_Do4_filtrado, color(cores(1)) );
    title('Sinal temporal discretizado filtrado (Celular, Violão, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_C_V_Do4, espectro_C_V_Do4, color(cores(1)) );
    title('Espectro de frequência do sinal (Celular, Violão, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_V_Do4, espectro_C_V_Do4_filtrado, color(cores(1)) );
    title('Espectro de frequência do sinal filtrado (Celular, Violão, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f6 = scf(6)
    subplot(4,1,1)
    plot2d(tempo_C_V_Do5, C_V_Do5, color(cores(2)) );
    title('Sinal temporal discretizado (Celular, Violão, Do5)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_V_Do5, C_V_Do5_filtrado, color(cores(2)) );
    title('Sinal temporal discretizado (Celular, Violão, Do5)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_C_V_Do5, espectro_C_V_Do5, color(cores(2)) );
    title('Espectro de frequência do sinal (Celular, Violão, Do5)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_V_Do5, espectro_C_V_Do5_filtrado, color(cores(2)) );
    title('Espectro de frequência do sinal filtrado (Celular, Violão, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f7 = scf(7)
    subplot(4,1,1)
    plot2d(tempo_C_V_Sol3, C_V_Sol3, color(cores(3)) );
    title('Sinal temporal discretizado (Celular, Violão, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_V_Sol3, C_V_Sol3_filtrado, color(cores(3)) );
    title('Sinal temporal discretizado (Celular, Violão, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_C_V_Sol3, espectro_C_V_Sol3, color(cores(3)) );
    title('Espectro de frequência do sinal (Celular, Violão, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_V_Sol3, espectro_C_V_Sol3_filtrado, color(cores(3)) );
    title('Espectro de frequência do sinal (Celular, Violão, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f8 = scf(8)
    subplot(4,1,1)
    plot2d(tempo_C_V_Sol4, C_V_Sol4, color(cores(4)) );
    title('Sinal temporal discretizado (Celular, Violão, Sol4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_C_V_Sol4, C_V_Sol4_filtrado, color(cores(4)) );
    title('Sinal temporal discretizado (Celular, Violão, Sol4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_C_V_Sol4, espectro_C_V_Sol4, color(cores(4)) );
    title('Espectro de frequência do sinal (Celular, Violão, Sol4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_C_V_Sol4, espectro_C_V_Sol4_filtrado, color(cores(4)) );
    title('Espectro de frequência do sinal (Celular, Violão, Sol4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    
f9 = scf(9)
    subplot(4,1,1)
    plot2d(tempo_M_F_Do4, M_F_Do4, color(cores(1)) );
    title('Sinal temporal discretizado (Microfone, Flauta, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_F_Do4, M_F_Do4_filtrado, color(cores(1)) );
    title('Sinal temporal discretizado filtrado (Microfone, Flauta, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_M_F_Do4, espectro_M_F_Do4, color(cores(1)) );
    title('Espectro de frequência do sinal (Microfone, Flauta, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_F_Do4, espectro_M_F_Do4_filtrado, color(cores(1)) );
    title('Espectro de frequência do sinal filtrado (Microfone, Flauta, Do4)')
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
    plot2d(tempo_M_V_Do4, M_V_Do4, color(cores(1)) );
    title('Sinal temporal discretizado (Microfone, Violão, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_V_Do4, M_V_Do4_filtrado, color(cores(1)) );
    title('Sinal temporal discretizado filtrado (Microfone, Violão, Do4)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_M_V_Do4, espectro_M_V_Do4, color(cores(1)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_V_Do4, espectro_M_V_Do4_filtrado, color(cores(1)) );
    title('Espectro de frequência do sinal filtrado (Microfone, Violão, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');

f14 = scf(14)
    subplot(4,1,1)
    plot2d(tempo_M_V_Do5, M_V_Do5, color(cores(2)) );
    title('Sinal temporal discretizado (Microfone, Violão, Do5)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_V_Do5, M_V_Do5_filtrado, color(cores(2)) );
    title('Sinal temporal discretizado (Microfone, Violão, Do5)')
    xlabel('t (s)');
    ylabel('Amplitude');

    subplot(4,1,3)
    plot2d(f_M_V_Do5, espectro_M_V_Do5, color(cores(2)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Do5)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_V_Do5, espectro_M_V_Do5_filtrado, color(cores(2)) );
    title('Espectro de frequência do sinal filtrado (Microfone, Violão, Do4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f15 = scf(15)
    subplot(4,1,1)
    plot2d(tempo_M_V_Sol3, M_V_Sol3, color(cores(3)) );
    title('Sinal temporal discretizado (Microfone, Violão, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_V_Sol3, M_V_Sol3_filtrado, color(cores(3)) );
    title('Sinal temporal discretizado (Microfone, Violão, Sol3)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_M_V_Sol3, espectro_M_V_Sol3, color(cores(3)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_V_Sol3, espectro_M_V_Sol3_filtrado, color(cores(3)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Sol3)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
f16 = scf(16)
    subplot(4,1,1)
    plot2d(tempo_M_V_Sol4, M_V_Sol4, color(cores(4)) );
    title('Sinal temporal discretizado (Microfone, Violão, Sol4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,2)
    plot2d(tempo_M_V_Sol4, M_V_Sol4_filtrado, color(cores(4)) );
    title('Sinal temporal discretizado (Microfone, Violão, Sol4)')
    xlabel('t (s)');
    ylabel('Amplitude');
    
    subplot(4,1,3)
    plot2d(f_M_V_Sol4, espectro_M_V_Sol4, color(cores(4)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Sol4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
    
    subplot(4,1,4)
    plot2d(f_M_V_Sol4, espectro_M_V_Sol4_filtrado, color(cores(4)) );
    title('Espectro de frequência do sinal (Microfone, Violão, Sol4)')
    xlabel('f (Hz)');
    ylabel('|A(f)|');
*/
