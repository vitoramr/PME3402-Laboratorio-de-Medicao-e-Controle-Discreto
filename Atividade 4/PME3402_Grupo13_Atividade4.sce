/*
=============================================================================
                        
                        Escola Politécnica da USP
         PME3402 - Laboratório de Medição e Controle Discreto
       --------------------------------------------------------------
            ATIVIDADE 4 - CONTROLE DE UM MOTOR POR PID DISCRETO
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

*/

//LIMPEZA DE MEMÓRIA
clear;
clc;    // Limpeza de variáveis e do console
xdel(winsid()) // Fecha as janelas abertas

// =============================================================================
// TAREFA 0 (programa fornecido, adaptado para a versão 6.1 do Scilab)
// =============================================================================

// Valores numéricos obtidos a partir do link:
// http://ctms.engin.umich.edu/CTMS/index.php?example=MotorSpeed&section=ControlPID
// Parâmetros do motor de corrente contínua:
J=0.01;
b=0.1;
K=0.01;
L=0.5;
R=1;

// Modelo no espaço de estados:
A=[-b/J K/J;-K/L -R/L];
B=[0;1/L]
C=[1 0];
D=0;

// syslin cria um sistema linear (continuo ou discreto) com as respectivas matrizes A,B,C,D
motor=syslin('c',A,B,C,D);

// Função de transferência do motor:
Gmotor=ss2tf(motor);

// Compensador PID
KP=100;
KI=200;
KD=10;
s=poly(0,'s');
Gpid=syslin('c',KP+(KI/s)+KD*s);

// Conexão em série do compensador PID e do motor (malha aberta):
Gma=Gpid*Gmotor;

// Fechamento da malha (feedback), com feedback unitário:
Gfb=syslin('c',s/s); // feedback unitário

// Fechando a malha (Gmf é a função de transferência de malha fechada):
Gmf=Gma/.Gfb; // Comando "/." é o comando de feedback para sistemas lineares SL1/.SL2 --> retorna SL1*(I+SL2*SL1)^-1

// Simulação para entrada degrau unitário:
DT=0.001;
Tf=10;
t=0:DT:(Tf-DT);
u=ones(t);
x0=[0;0;0];

// csim --> função realiza a simulação de um sistema linear a uma resposta [y [,x]]=csim(u,t,sistema,[x0 [,tol]])
// u pode ser um vetor, uma string ('impluse','step'), ou uma função
y=csim('step',t,Gmf,x0); 
f = scf(4)
    plot2d(t,y);
    xtitle('Saida controlada por PID: tempo contínuo – linha preta','t (s)','y(rad/s)');

// =============================================================================
//                                TAREFA 1
// =============================================================================
/*
1) Obtenha uma aproximação em tempo discreto do compensador PID mostrado na Tarefa 0,
usando transformada Z e o método do trapézio (à mão), e, usando o Scilab, aplique
no motor e simule calculando diretamente pelas equações de diferenças (sem usar
o comando “flts” ou similares).

Usar o inverso do procedimento mostrado na página 4 do arquivo
PME3402_TOPICO_04_FILTROS_DIGITAIS_2020.pdf

A aproximação do motor usando o método do segurador de ordem zero (comando “dscr” no Scilab)
já está apresentada neste arquivo.

De posse das equações de diferenças, desenvolvam um algoritmo que resolva tais
equações tendo como entrada o sinal a ser filtrado, e como saída o sinal filtrado.
Não podem ser usadas funções prontas de análise de sinais do Scilab.

2) Use os seguintes períodos de amostragem: T=0,25 s; T=0,1 s; T=0,05 s.

3) Compare as respostas do sistema com esses períodos de amostragem entre si e com a
obtida na simulação do sistema contínuo (Tarefa 0).
*/


// Modelo em tempo discreto do motor de corrente contínua usando o segurador de ordem zero (ZOH):
//T= [0,25;0,1;0,05]; //[s] períodos de amostragem desejados
T=0.25 // Período de amostragem

// dscr obtém o modelo em tempo discreto de uma planta no espaço de estado
// usando o ZOH.
motorD = dscr(motor,T); 

// função de transferência do motor em tempo discreto (ZOH):
GmotorD = ss2tf(motorD);

// Simulando o sistema com compensador PID usando as equações de diferenças:
// Equações de diferenças para o modelo em tempo discreto do motor de corrente
// contínua:

nMD=coeff(GmotorD('num')); // Coeficientes do numerador
dMD=coeff(GmotorD('den')); // Coeficientes do denominador
n=length(nMD);
d=length(dMD);

// p é o maior grau da função de transferência no numerador ou denominador
// U(z) = 

if d>n then //Se o grau do polinômio do denominador é maior do que o do denominador 
    p=d;    //p = d
else
    p=n;
end

// Condições iniciais do motor --> parado
for i=1:(p-1)
    um(i)=0;
    ym(i)=0;
    e(i)=0;
end

// Equações de diferenças:
// O restante do programa deve ser desenvolvido pelo grupo.
// É preciso escrever as equações de diferenças do motor e desenvolver
// e escrever as equações de diferenças do PID.
// IMPORTANTE: nas Tarefas 1 e 2 as simulações devem ser feitas por meio de
// equações de diferenças, não podem ser usadas funções “prontas” do Scilab para
// simulação de sistemas discretos.


// =============================================================================
//                                TAREFA 2
// =============================================================================
/*
Repita a Tarefa 1 usando a regra “para trás” (“backward rule”).

Obs.: não é preciso obter a aproximação em tempo discreto do compensador PID usando
a regra “para trás”, pode ser usado o resultado já mostrado na página 4 da apostila
“PME3402_TOPICO_06_PID_DIGITAL_2020.pdf”.
*/

