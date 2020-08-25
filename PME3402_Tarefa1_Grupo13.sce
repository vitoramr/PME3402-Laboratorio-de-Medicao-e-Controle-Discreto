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

clear; clc;    // Limpeza de variáveis e do console
xdel(winsid()) // Fecha as janelas abertas

// ============================================================
//    PARTE 1

// 1. Gerar um vetor de tempos com passo dt=1/fa, fa=100Hz (frequência de amostragem), de duração 4 segundos;
fa = 100;                      //[Hz]
dt1 = 1/fa;                    //[s]
t0 = 0;                        //[s] Tempo inicial (todas questões)
tf1 = 4.0;                     //[s] Tempo final da parte 1
t1 = t0:dt1:tf1;               //[s] Vetor de tempos da parte 1

// 2. Gerar um sinal periódico y1=cos(2πft+Φ), com f (frequência do sinal) e  Φ, fase do sinal, à sua escolha
// (ATENÇÃO: respeitar o critério de Nyquist);
phi1 = 0.5;                      //[rad] - Fase do sinal y1
f1 = 2;                        //[Hz] - Frequência dos sinais y1 e y2

y1 = cos(2*%pi*f1*t1 + phi1);

// 3. Gerar um sinal periódico y2=cos(2πft+Φ+2πPfat), com P um número inteiro;
P = 2;                        //Número inteiro
phi2 = 2*%pi*P*fa*t1;         //Fase da frequência 2 

y2 = cos(2*%pi*f1*t1 + phi2 + phi1);

// 4. Exibir um gráfico contendo os sinais y1 e y2 em função do tempo.
fig1 = scf(1);
    xgrid;
    plot(t1,y1, 'r');
    plot(t1,y2, 'b');
    xtitle("Figura I-1: Sinais períodicos em função do tempo, com f= " + string(f1) + "Hz, Φ1 = " + string(phi1) + "rad e P= " + string(P) );
    xlabel ('tempo(s)')
    ylabel ('y')
    hl = legend(['y1';'y2'])

// 5. Interpretar o gráfico e explicar o resultado.

/*
Como podemos notar, o sinal y2 se comporta como se ele possuísse defasagem = 0.
Isso ocorre, pois, mesmo que a fase de phi2 varie no tempo, como ela é
calculada em relação à fa, que é a frequência de amostragem do vetor de tempo,
e uma propocionalidade de um múltiplo de 2*pi (independente do valor de P, dado
que ele seja um inteiro), ocorre o fenômeno de falseamento (Aliasing).
Assim, a cada passo do vetor de tempo, a fase de y2 é multiplicada por um múltiplo
de 2pi, o que dá a impressão de que y2 possui uma fase estática de 0.

A figura I-2 ilustra o fenômeno ao mostrar que, ao calcularmos o resto da divisão
de phi2 por 2pi, este valor é aproximadamente zero ou 2pi, devido às aproximações
de cálculo, para toda duração do sinal.
*/

phi2_mod2pi = pmodulo(phi2,2*%pi) //Resto da divisão de Φ2 por 2pi

fig2 = scf(2);
    subplot(2,1,1)
    plot(t1,phi2); //Visualizar o pulso 1
    xtitle('Figura I.2-1: Fase do sinal y2', 't(s)','Φ2 (rad)');
    
    subplot(2,1,2)
    scatter(t1, phi2_mod2pi, '.')
    xtitle('Figura I.2-2: Fase do sinal y2 entre 0 e 2pi', 't(s)','Φ2 (rad)');
    


// ============================================================
// PARTE 2

// 1. Gerar um vetor de tempos com 10 s.  de duração total com passos de 0,05s. segundos;
dt2 = 0.05;                          //[s] Intervalo de amostragem do vetor de tempo t2
tf2 = 10.0;                          //[s] Tempo final da parte 2
t2  = t0:dt2:tf2;                    //[s] Vetor de tempos da parte 1
N   = size(t2,'*');                   // Número de amostras

// 2. Gerar um pulso unitário de duração 2 s.  começando no instante t=1s.
pulso1_t = zeros(t2);                //Vetor de zeros do mesmo tamanho de t2
ti_p1 = 1.0;                         //Início do pulso 1
dt_p1 = 2.0;                         //Duração do pulso 1
idx_ti_p1 = (ti_p1 - t0)/dt2 + 1;    //Índice no vetor t2 do tempo inicial do pulso 1 (ti_p1)
idx_tf_p1 = idx_ti_p1 + dt_p1 / dt2; //Índice no vetor t2 do tempo final do pulso 1 (ti_p1)

pulso1_t(idx_ti_p1:idx_tf_p1) = 1;   //Adicionando 1's ao vetor de pulso em seus respectivos indices

// 3. Aplicar a transformada rápida de Fourier ao sinal gerado em (2);

// Função fft do Scilab: https://help.scilab.org/docs/5.5.1/en_US/fft.html
pulso1_f = fft(pulso1_t, -1)         //Realiza a Transformada Direta de Fourier.


// Encontrando a escala da frequência
N_f = size(pulso1_f,'*')             //Tamanho do vetor de frequências
sample_rate2 = 1.0/(dt2);          //[Hz] Escala horizontal da DFT

f2 = (sample_rate2/N) * (0:(N_f-1));     //[Hz] Escala horizontal das frequências da DFT

// Densidade de potência do sinal

// A densidade de potência de um sinal é dada pelo produto da sua DFT com seu conjugado complexo
pot_pulso1 = ( abs(pulso1_f) ).^2;

// 4. Exibir gráficos contendo o sinal gerado em (2) e seu espectro de potência;

fig3 = scf(3);
    subplot(2,1,1)
    scatter(t2,pulso1_t,".");        //Visualizar o pulso 1
    xtitle('Figura II.1-1: Sinal de pulso unitário de com início em t = '+ string(ti_p1) + 's e duração de ' + string(dt_p1) +'s.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f2(1:N_f/2) , pot_pulso1(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura II.1-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');
    
// 5. Utilizando o mesmo vetor de tempos, gerar uma função periódica (seno ou cosseno) de frequência 4 Hz;
f5_2 = 4;                              //Frequência para o sinal de (5) da parte 2
phi5_2 = 0;                            //Fase inicial para o sinal de (5) da parte 2
y5_t_2 = cos(2*%pi*f5_2*t2 + phi5_2);

// 6. Aplicar a transformada rápida de Fourier ao sinal gerado em (5) da parte 2;
y5_f_2 = fft(y5_t_2, -1)                 //Realiza a Transformada Direta de Fourier.
pot_y5_2 = ( abs(y5_f_2) ).^2

// 7. Exibir gráficos contendo o sinal gerado em (5) e seu espectro de potência;
fig4 = scf(4);
    subplot(2,1,1)
    plot(t2,y5_t_2);        //Visualizar o sinal de (5)
    xtitle('Figura II.2-1: Sinal periódico de frequência '+ string(f5_2) + 'Hz e fase ' + string(phi5_2) +' rad.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f2(1:N_f/2) , pot_y5_2(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura II.2-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');

// 8. Efetuar a multiplicação dos sinais gerados em (2) e em (5) da parte 2;
y8_t_2 = y5_t_2 .* pulso1_t

// 9. Aplicar a transformada rápida de Fourier ao sinal gerado em (8) da parte 2;
y8_f_2 = fft(y8_t_2, -1)                 //Realiza a Transformada Direta de Fourier.
pot_y8_2 = ( abs(y8_f_2) ).^2

// 10. Exibir gráficos contendo o sinal gerado em (8) e seu espectro de potência.
fig5 = scf(5);
    subplot(2,1,1)
    plot(t2,y8_t_2);        //Visualizar o sinal de (5)
    xtitle('Figura II.3-1: Sinal periódico aplicado à janela entre  t = '+ string(ti_p1) + 's e t = ' + string(ti_p1 + dt_p1) +'s.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f2(1:N_f/2) , pot_y8_2(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura II.3-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');


// ================
// PARTE 3

// Repetir o procedimento da Parte 2 a partir do item (5) gerando um sinal periódico com frequências 4,01 e 4,16 Hz.

// Explicar o comportamento dos espectros.

// .1: Para o sinal de 4,01

// 3.1.5. Utilizando o mesmo vetor de tempos, gerar uma função periódica (seno ou cosseno) de frequência 4,01 Hz;
f5_3_1 = 4.01;                              //Frequência para o sinal de (5) da parte 3.1
phi5_3_1 = 0;                            //Fase inicial para o sinal de (5) da parte 3.1
y5_t_3_1 = cos(2*%pi*f5_3_1*t2 + phi5_2);

// 3.1.6. Aplicar a transformada rápida de Fourier ao sinal gerado em (5) da parte 3.1;
y5_f_3_1 = fft(y5_t_3_1, -1)                 //Realiza a Transformada Direta de Fourier.
pot_y5_3_1 = ( abs(y5_f_3_1) ).^2

// 3.1.7. Exibir gráficos contendo o sinal gerado em (5) e seu espectro de potência;
fig6 = scf(6);
    subplot(2,1,1)
    plot(t2,y5_t_3_1);        //Visualizar o sinal de (5)
    xtitle('Figura III.1-1: Sinal periódico de frequência '+ string(f5_3_1) + 'Hz e fase ' + string(phi5_3_1) +' rad.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f2(1:N_f/2) , pot_y5_3_1(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura III.1-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');

// 3.1.8. Efetuar a multiplicação dos sinais gerados em (2) e em (5);
y8_t_3_1 = y5_t_3_1 .* pulso1_t

// 3.1.9. Aplicar a transformada rápida de Fourier ao sinal gerado em (8) da parte 3;
y8_f_3_1 = fft(y8_t_3_1, -1)                 //Realiza a Transformada Direta de Fourier.
pot_y8_3_1 = ( abs(y8_f_3_1) ).^2

// 3.1.10. Exibir gráficos contendo o sinal gerado em (8) e seu espectro de potência.
fig7 = scf(7);
    subplot(2,1,1)
    plot(t2,y8_t_3_1);        //Visualizar o sinal de (5)
    xtitle('Figura III.2-1: Sinal periódico aplicado à janela entre  t = '+ string(ti_p1) + 's e t = ' + string(ti_p1 + dt_p1) +'s.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f2(1:N_f/2) , pot_y8_3_1(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura III.2-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');
    
// 3.2: Para o sinal de 4,16

// 3.2.5. Utilizando o mesmo vetor de tempos, gerar uma função periódica (seno ou cosseno) de frequência 4,16 Hz;
f5_3_2 = 4.16;                              //Frequência para o sinal de (5) da parte 3.2
phi5_3_2 = 0;                            //Fase inicial para o sinal de (5) da parte 3.2
y5_t_3_2 = cos(2*%pi*f5_3_2*t2 + phi5_2);

// 3.2.6. Aplicar a transformada rápida de Fourier ao sinal gerado em (5) da parte 3.2;
y5_f_3_2 = fft(y5_t_3_2, -1)                 //Realiza a Transformada Direta de Fourier.
pot_y5_3_2 = ( abs(y5_f_3_2) ).^2

// 3.2.7. Exibir gráficos contendo o sinal gerado em (5) e seu espectro de potência;
fig8 = scf(8);
    subplot(2,1,1)
    plot(t2,y5_t_3_2);        //Visualizar o sinal de (5)
    xtitle('Figura III.3-1: Sinal periódico de frequência '+ string(f5_3_2) + 'Hz e fase ' + string(phi5_3_2) +' rad.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f2(1:N_f/2) , pot_y5_3_2(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura III.3-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');

// 3.2.8. Efetuar a multiplicação dos sinais gerados em (2) e em (5);
y8_t_3_2 = y5_t_3_2 .* pulso1_t

// 3.2.9. Aplicar a transformada rápida de Fourier ao sinal gerado em (8) da parte 3;
y8_f_3_2 = fft(y8_t_3_2, -1)                 //Realiza a Transformada Direta de Fourier.
pot_y8_3_2 = ( abs(y8_f_3_2) ).^2

// 3.2.10. Exibir gráficos contendo o sinal gerado em (8) e seu espectro de potência.
fig9 = scf(9);
    subplot(2,1,1)
    plot(t2,y8_t_3_2);        //Visualizar o sinal de (5)
    xtitle('Figura III.4-1: Sinal periódico aplicado à janela entre  t = '+ string(ti_p1) + 's e t = ' + string(ti_p1 + dt_p1) +'s.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f2(1:N_f/2) , pot_y8_3_2(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura III.4-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');

//Explicar o comportamento dos espectros.
/*
Analisando-se o sinal periódico de frequência e a densidade de potência gerada a partir da aplicação da transformada rápida de Fourier,
pode-se observar que a densidade de potência contém um pico (~7500) na frequência definida para o sinal periódico, isso ocorre para qualquer frequência utilizada.
Ao mesclar o pulso unitário com o sinal periódico, a periodicidade do sinal é mantida apenas na região em que o pulso ocorre, deste modo,
a transformada rápida de Fourier obtém um resultado mais esparso, ainda com pico na frequência definida, porém com valor de densidade menor (~400) e
com pequenas gaussianas com picos menores em torno da frequência definida.
A diferença numérica no valor da densidade de potência ocorre devido à somatória presente no cálculo da transformada rápida de Fourier, por haverem mais termos nulos na mesclagem do pulso com o sinal,
o valor calculado pela transformada é numéricamente menor.
*/

// ================
// PARTE 4



// Repetir o procedimento da Parte 3,  porém modificando o passo do vetor de tempos para 0,01s.

dt4 = 0.01;                          //[s] Intervalo de amostragem do vetor de tempo t4
tf4 = 10.0;                          //[s] Tempo final da parte 4
t4  = t0:dt4:tf4;                    //[s] Vetor de tempos da parte 4
N4   = size(t4,'*');                   // Número de amostras

// Gerar um pulso unitário de duração 2 s.  começando no instante t=1s.
pulso1_t4 = zeros(t4);                //Vetor de zeros do mesmo tamanho de t2
ti_p1 = 1.0;                         //Início do pulso 1
dt_p1 = 2.0;                         //Duração do pulso 1
idx_ti_p1 = (ti_p1 - t0)/dt4 + 1;    //Índice no vetor t2 do tempo inicial do pulso 1 (ti_p1)
idx_tf_p1 = idx_ti_p1 + dt_p1 / dt4; //Índice no vetor t2 do tempo final do pulso 1 (ti_p1)

pulso1_t4(idx_ti_p1:idx_tf_p1) = 1;   //Adicionando 1's ao vetor de pulso em seus respectivos indices

sample_rate4 = 1.0/(dt4);          //[Hz] Escala horizontal da DFT

f4 = (sample_rate4/N4) * (0:(N_f-1));     //[Hz] Escala horizontal das frequências da DFT

// 4.1.5. Utilizando o mesmo vetor de tempos, gerar uma função periódica (seno ou cosseno) de frequência 4,01 Hz;
f5_4_1 = 4.01;                              //Frequência para o sinal de (5) da parte 4.1
phi5_4_1 = 0;                            //Fase inicial para o sinal de (5) da parte 4.1
y_t_4_1 = cos(2*%pi*f5_4_1*t4 + phi5_4_1);

// 4.1.6. Aplicar a transformada rápida de Fourier ao sinal gerado em (5) da parte 4.1;
y_f_4_1 = fft(y_t_4_1, -1)                 //Realiza a Transformada Direta de Fourier.
pot_y_4_1 = ( abs(y_f_4_1) ).^2

// 4.1.7. Exibir gráficos contendo o sinal gerado em (5) e seu espectro de potência;
fig10 = scf(10);
    subplot(2,1,1)
    plot(t4,y_t_4_1);        //Visualizar o sinal de (5)
    xtitle('Figura IV.1-1: Sinal periódico de frequência '+ string(f5_4_1) + 'Hz e fase ' + string(phi5_4_1) +' rad.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f4(1:N_f/2) , pot_y5_3_1(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura IV.1-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');

// 4.1.8. Efetuar a multiplicação dos sinais gerados em (2) e em (5);
y8_t_4_1 = y_t_4_1 .* pulso1_t4

// 4.1.9. Aplicar a transformada rápida de Fourier ao sinal gerado em (8) da parte 4;
y8_f_4_1 = fft(y8_t_4_1, -1)                 //Realiza a Transformada Direta de Fourier.
pot_y8_4_1 = ( abs(y8_f_4_1) ).^2

// 4.1.10. Exibir gráficos contendo o sinal gerado em (8) e seu espectro de potência.
fig11 = scf(11);
    subplot(2,1,1)
    plot(t4,y8_t_4_1);        //Visualizar o sinal de (5)
    xtitle('Figura IV.2-1: Sinal periódico aplicado à janela entre  t = '+ string(ti_p1) + 's e t = ' + string(ti_p1 + dt_p1) +'s.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f4(1:N_f/2) , pot_y8_4_1(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura IV.2-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');
    
// 4.2: Para o sinal de 4,16

// 4.2.5. Utilizando o mesmo vetor de tempos, gerar uma função periódica (seno ou cosseno) de frequência 4,16 Hz;
f5_4_2 = 4.16;                              //Frequência para o sinal de (5) da parte 4.2
phi5_4_2 = 0;                            //Fase inicial para o sinal de (5) da parte 4.2
y5_t_4_2 = cos(2*%pi*f5_4_2*t4 + phi5_4_2);

// 4.2.6. Aplicar a transformada rápida de Fourier ao sinal gerado em (5) da parte 4.2;
y5_f_4_2 = fft(y5_t_4_2, -1)                 //Realiza a Transformada Direta de Fourier.
pot_y_4_2 = ( abs(y5_f_4_2) ).^2

// 4.2.7. Exibir gráficos contendo o sinal gerado em (5) e seu espectro de potência;
fig12 = scf(12);
    subplot(2,1,1)
    plot(t4,y5_t_4_2);        //Visualizar o sinal de (5)
    xtitle('Figura IV.3-1: Sinal periódico de frequência '+ string(f5_4_2) + 'Hz e fase ' + string(phi5_4_2) +' rad.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f4(1:N_f/2) , pot_y_4_2(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura IV.3-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');

// 4.2.8. Efetuar a multiplicação dos sinais gerados em (2) e em (5);
y8_t_4_2 = y5_t_4_2 .* pulso1_t4

// 4.2.9. Aplicar a transformada rápida de Fourier ao sinal gerado em (8) da parte 4;
y8_f_4_2 = fft(y8_t_4_2, -1)                 //Realiza a Transformada Direta de Fourier.
pot_y8_4_2 = ( abs(y8_f_4_2) ).^2

// 4.2.10. Exibir gráficos contendo o sinal gerado em (8) e seu espectro de potência.
fig13 = scf(13);
    subplot(2,1,1)
    plot(t4,y8_t_4_2);        //Visualizar o sinal de (5)
    xtitle('Figura IV.4-1: Sinal periódico aplicado à janela entre  t = '+ string(ti_p1) + 's e t = ' + string(ti_p1 + dt_p1) +'s.' , 't (s)','s (t)');
    
    subplot(2,1,2)
    plot( f4(1:N_f/2) , pot_y8_4_2(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura IV.4-2: Densidade de potência do sinal acima', 'f (Hz)','|S(w)| ^2');

// Comparar com o resultado do item (III) e explicar o que ocorre.
/*
Alterando-se o passo para um menor aumenta-se o número de intervalos em que os dados são obtidos, assim obtêm-se uma melhor resolução das curvas.
Além disso, a transformada rápida de Fourier envolve uma somatória dos termos, por haver um número maior de termos devido ao passo menor,
o valor obtido com a transformada é maior, logo a densidade de potência calculada também é maior.
*/

