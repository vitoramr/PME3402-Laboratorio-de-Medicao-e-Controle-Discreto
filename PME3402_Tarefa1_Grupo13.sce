/*
==============================================================
                Escola Politécnica da USP
 PME3402 - Laboratório de Medição e Controle Discreto
--------------------------------------------------------------
                       TAREFA 1
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
*/
clear; clc; // Limpeza de variáveis

// ================
//    PARTE 1

// 1. Gerar um vetor de tempos com passo dt=1/fa, fa=100Hz (frequência de amostragem), de duração 4 segundos;
fa = 100;        //[Hz]
dt1 = 1/fa;      //[s]
t0 = 0;          //[s] Tempo inicial (todas questões)
tf1 = 4.0;       //[s] Tempo final da parte 1
t1 = t0:dt1:tf1; //[s] Vetor de tempos da parte 1

// 2. Gerar um sinal periódico y1=cos(2πft+Φ), com f (frequência do sinal) e  Φ, fase do sinal, à sua escolha
// (ATENÇÃO: respeitar o critério de Nyquist);
phi1 = 1;        //[rad] - Fase do sinal y1
f1 = 2;          //[Hz] - Frequência dos sinais y1 e y2

y1 = cos(2*%pi*f1*t1 + phi1);

// 3. Gerar um sinal periódico y2=cos(2πft+Φ+2πPfat), com P um número inteiro;
P = 2; //Número inteiro
phi2 = 2*%pi*P*fa*t1;

y2 = cos(2*%pi*f1*t1 + phi2);

// 4. Exibir um gráfico contendo os sinais y1 e y2 em função do tempo.
fig1 = scf(1);
    xgrid;
    plot(t1,y1, 'r');
    plot(t1,y2, 'b');
    xtitle("Parte 1: Sinais períodicos em função do tempo, com f= " + string(f1) + "Hz, phi_1 = " + string(phi1) + "rad e P= " + string(P) );
    xlabel ('tempo(s)')
    ylabel ('y')
    hl = legend(['y1';'y2'])

// 5. Interpretar o gráfico e explicar o resultado.
/*
EXPLICAÇÃO
*/

// ================
// PARTE 2

// 1. Gerar um vetor de tempos com 10 s.  de duração total com passos de 0,05s. segundos;
dt2 = 0.05;                          //[s]
tf2 = 10.0;                          //[s] Tempo final da parte 2
t2 = t0:dt2:tf2;                     //[s] Vetor de tempos da parte 1

// 2. Gerar um pulso unitário de duração 2 s.  começando no instante t=1s.
pulso1 = zeros(t2);                  //Vetor de zeros do mesmo tamanho de t2
ti_p1 = 1.0;                         //Início do pulso 1
dt_p1 = 2.0;                         //Duração do pulso 1
idx_ti_p1 = (ti_p1 - t0)/dt2 + 1;    //Índice no vetor t2 do tempo inicial do pulso 1 (ti_p1)
idx_tf_p1 = idx_ti_p1 + dt_p1 / dt2; //Índice no vetor t2 do tempo final do pulso 1 (ti_p1)

pulso1(idx_ti_p1:idx_tf_p1) = 1;     //Adicionando 1's ao vetor de pulso em seus respectivos indices

// 3. Aplicar a transformada rápida de Fourier ao sinal gerado em (2);
// Função fft do Scilab: https://help.scilab.org/docs/5.5.1/en_US/fft.html

// 4. Exibir gráficos contendo o sinal gerado em (2) e seu espectro de potência;

fig2 = scf(2);
    scatter(t2,pulso1,'b'); //Visualizar o pulso 1

// 5. Utilizando o mesmo vetor de tempos, gerar uma função periódica (seno ou cosseno) de frequência 4 Hz;

// 6. Aplicar a transformada rápida de Fourier ao sinal gerado em (5);

// 7. Exibir gráficos contendo o sinal gerado em (5) e seu espectro de potência;

// 8. Efetuar a multiplicação dos sinais gerados em (2) e em (5);

// 9. Aplicar a transformada rápida de Fourier ao sinal gerado em (8);

// 10. Exibir gráficos contendo o sinal gerado em (8) e seu espectro de potência.

// ================
// PARTE 3

// Repetir o procedimento da Parte 2 a partir do item (5) gerando um sinal periódico com frequências 4,01 e 4,16 Hz.

// Explicar o comportamento dos espectros.
/*
EXPLICAÇÃO
*/

// ================
// PARTE 4

// Repetir o procedimento da Parte 3,  porém modificando o passo do vetor de tempos para 0,01s.

// Comparar com o resultado do item (III) e explicar o que ocorre.
/*
EXPLICAÇÃO
*/
