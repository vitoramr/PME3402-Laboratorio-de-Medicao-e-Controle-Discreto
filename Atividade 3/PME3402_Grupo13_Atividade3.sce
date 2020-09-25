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
    'Microfone_Violao_Sol4.wav'
];

file_path = data_directory + s + file_names;

//Leitura dos arquivos de áudio e de sua frequência de amostragem

//Vê-se necessário cortar os áudios nos pontos em que o som é efetivamente emitido, visto que a gravação começa antes e termina depois da emissão do som e isso poderia afetar a precisão da FFT
//Tal processo foi feito visualmente, analisando o instante do sinal em que o som foi emitido

[y, Fs] = wavread(file_path(1), [int(4.04*44000),int(8.88*44000)]);
C_F_Do4 = y;
C_F_Do4_Fs = Fs;
[y, Fs] = wavread(file_path(2), [int(4.85*44000),int(9.48*44000)]);
C_F_Do5 = y;
C_F_Do5_Fs = Fs;
[y, Fs] = wavread(file_path(3), [int(5.53*44000),int(10.71*44000)]);
C_F_Sol3 = y;
C_F_Sol3_Fs = Fs;
[y, Fs] = wavread(file_path(4), [int(3.82*44000),int(8.4*44000)]);
C_F_Sol4 = y;
C_F_Sol4_Fs = Fs;
[y, Fs] = wavread(file_path(5), [int(1.23*44000),int(4.85*44000)]);
C_V_Do4 = y;
C_V_Do4_Fs = Fs;
[y, Fs] = wavread(file_path(6), [int(2.18*44000),int(6.94*44000)]);
C_V_Do5 = y;
C_V_Do5_Fs = Fs;
[y, Fs] = wavread(file_path(7), [int(2.2*44000),int(7*44000)]);
C_V_Sol3 = y;
C_V_Sol3_Fs = Fs;
[y, Fs] = wavread(file_path(8), [int(2.64*44000),int(7.55*44000)]);
C_V_Sol4 = y;
C_V_Sol4_Fs = Fs;
[y, Fs] = wavread(file_path(9), [int(0.04*44100),int(4.775*44100)]);
M_F_Do4 = y(1,:);
M_F_Do4_Fs = Fs;
[y, Fs] = wavread(file_path(10), [int(2.155*44100),int(6.45*44100)]);
M_F_Do5 = y(1,:);
M_F_Do5_Fs = Fs;
[y, Fs] = wavread(file_path(11), [int(0.05*44100),int(5.2*44100)]);
M_F_Sol3 = y(1,:);
M_F_Sol3_Fs = Fs;
[y, Fs] = wavread(file_path(12), [int(3.1*44100),int(7.45*44100)]);
M_F_Sol4 = y(1,:);
M_F_Sol4_Fs = Fs;
[y, Fs] = wavread(file_path(13), [int(2.4*44100),int(4.95*44100)]);
M_V_Do4 = y(1,:);
M_V_Do4_Fs = Fs;
[y, Fs] = wavread(file_path(14), [int(3.64*44100),int(4.75*44100)]);
M_V_Do5 = y(1,:);
M_V_Do5_Fs = Fs;
[y, Fs] = wavread(file_path(15), [int(2.35*44100),int(3.55*44100)]);
M_V_Sol3 = y(1,:);
M_V_Sol3_Fs = Fs;
[y, Fs] = wavread(file_path(16), [int(3.93*44100),int(4.33*44100)]);
M_V_Sol4 = y(1,:);
M_V_Sol4_Fs = Fs;


// Parâmetro
fam = 44100; //[Hz] Frequência de amostragem do microfone
fac = 44000; //[Hz] Frequência de amostragem do celular

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

[C_F_Do4] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc) //Sinal filtrado para Do4 da Flauta do Celular
[C_F_Do5] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)
[C_F_Sol3] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)
[C_F_Sol4] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)

[C_V_Do4] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc) //Sinal filtrado para Do4 do Violao no Celular
[C_V_Do5] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)
[C_V_Sol3] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)
[C_V_Sol4] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)

[M_F_Do4] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc) //Sinal filtrado para Do4 da Flauta do Microfone
[M_F_Do5] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)
[M_F_Sol3] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)
[M_F_Sol4] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)

[M_V_Do4] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc) //Sinal filtrado para Do4 do Violao no Microfone
[M_V_Do5] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)
[M_V_Sol3] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)
[M_V_Sol4] = filtro_passa_baixa_1a_ordem(e, metodo , fa, fc)

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
*/
