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

// Syslin cria um sistema linear (continuo ou discreto) com as determinadas matrizes
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
motorD = dscr(motor,T);

// função de transferência do motor em tempo discreto (ZOH):
GmotorD = ss2tf(motorD);
// Simulando o sistema com compensador PID usando as equações de diferenças:
// Equações de diferenças para o modelo em tempo discreto do motor de corrente
// contínua:

nMD=coeff(GmotorD('num')); // Coeficientes do numerador
dMD=coeff(GmotorD('den'));
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

/* Instruções para o Filtro Digital da aula anterior
1. Como está nas instruções, obtenham (no Scilab) o espectro de frequência do sinal
antes da filtragem, e, em função dos objetivos do experimento e desse espectro,
escolham a freqüência de corte.

2. Com a freqüência de corte, definam o filtro em tempo contínuo no Scilab, na forma
 de função de transferência em s, como vocês já devem ter feito na disciplina de Modelagem
(comando poly para definir a variável s, e o comando syslin).

3. Por uma peculiaridade do Scilab (ao menos na versão 5.x ou anterior), não há
conversão direta para a função de transferência em z. É preciso usar o comando
tf2ss para obter o sistema no espaço de estados (ainda em tempo contínuo).

4. Usando o comando cls2dls , se converte o sistema em tempo contínuo, no espaço
de estados, no sistema em tempo discreto, no espaço de estados.

5. Usando o comando ss2tf , se obtém a função de transferência do filtro em z a
 partir do sistema em tempo discreto no espaço de estados obtido na etapa anterior.
 
6. Com essa função de transferência em z, devem ser obtidas as equações de diferenças.
Usem o inverso do procedimento mostrado na página 4 do arquivo PME3402_TOPICO_04_FILTROS_DIGITAIS_2020.pdf.
Façam à mão, ou escrevam um algoritmo no Scilab que leia os coeficientes das 
potências de z na função de transferência em z (na versão 5.x do Scilab pode ser usado o comando coeff).

7. De posse das equações de diferenças, desenvolvam um algoritmo que resolva tais
equações tendo como entrada o sinal a ser filtrado, e como saída o sinal filtrado.
Não podem ser usadas funções prontas de análise de sinais do Scilab.
*/
