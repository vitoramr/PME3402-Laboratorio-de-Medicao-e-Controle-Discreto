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
fc = 10;        // Frequência de corte do filtro (Hz)
wc = 2*%pi*fc;  // Frequência de corte do filtro (rad/s)

s=poly(0,'s');
z=poly(0,'z');
H_filtro_c = wc/(s+wc);                   // Função de transferência em tempo contínuo
Sys_filtro_c = tf2ss(H_filtro_c);         // Transforma a função de transferência em espaço de estados
Sys_filtro_d = cls2dls(Sys_filtro_c, Ts); // Transforma o sistema contínuo em discreto pelo método bilinear
H_filtro_d = ss2tf(Sys_filtro_d);         // Função de transferência em tempo discreto

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

