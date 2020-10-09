/*
==============================================================
                Escola Politécnica da USP
 PME3402 - Laboratório de Medição e Controle Discreto
--------------------------------------------------------------
                       ATIVIDADE 4
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

//LIMPEZA DE MEMÓRIA
clear;
clc;    // Limpeza de variáveis e do console
xdel(winsid()) // Fecha as janelas abertas


// ============================================================
// PROGRAMA INICIAL
// Use este programa como ponto de partida.
// A Tarefa 0 já está pronta, e a Tarefa 1 iniciada.
// Obs.: esse programa foi escrito para o Scilab 5.5.2.
// Adaptações podem ser necessárias se este programa for usado no Scilab 6.1.
// Importante: os gráficos devem estar em sua própria janela, evitando
// que a próxima figura se sobreponha à figura anterior, exceto se for esse
// o objetivo, no caso de se querer fazer comparações dos resultados.

// ============================================================
// TAREFA 0
// Valores numéricos obtidos a partir do link: http://ctms.engin.umich.edu/CTMS/index.php?example=MotorSpeed&section=ControlPID
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
Gmf=Gma/.Gfb;

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

// ============================================================
// TAREFA 1

// Modelo em tempo discreto do motor de corrente contínua usando o segurador de ordem zero (ZOH):
T=0.25 // Período de amostragem

//dscr obtém o modelo em tempo discreto de uma planta no espaço de estado
// usando o ZOH.
motorD=dscr(motor,T);
// função de transferência do motor em tempo discreto (ZOH):
GmotorD=ss2tf(motorD);
// Simulando o sistema com compensador PID usando as equações de diferenças:
// Equações de diferenças para o modelo em tempo discreto do motor de corrente
// contínua:
nMD=coeff(numer(GmotorD));
dMD=coeff(denom(GmotorD));
n=length(nMD);
d=length(dMD);
if d>n then
    p=d;
else
    p=n;
end
// Condições iniciais - motor
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
