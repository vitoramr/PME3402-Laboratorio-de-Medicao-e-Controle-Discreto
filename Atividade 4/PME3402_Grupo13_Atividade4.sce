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
// TAREFA 0 (programa fornecido, adaptado à versão 6.1 do Scilab)
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
//KP=100;
//KI=200;
//KD=10;

KP=5;
KI=40;
KD=0.1;

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
f = scf(1)
    plot2d(t,y);
    xtitle('Saida controlada por PID: tempo contínuo – linha preta','t (s)','y(rad/s)');

// =============================================================================
//                                TAREFA 1
// =============================================================================

// Simulando o sistema com compensador PID usando as equações de diferenças:

function [td,ed,ud,yd] = step_response_PID_digital(motor, metodo, Kp, Ki, Kd, Ta, Tf)
/*
    Por meio da equação de diferenças, essa função calcula a resposta discreta
    a um pulso unitário da função de transferência discreta do motor controlada
    por um controlador PID discreto.

    Ela calcula o controlador pela aproximação de um controlador PID contínuo
    por meio de métodos de integração diferentes:
       - metodo = 'bilinear' (trapezoidal) (atividade 1)
       - metodo = 'euler-backwards' (método de 'Backwards' Euler) (atividade 2)
       
    Quer-se analizar a resposta impulsiva da função de transferência, logo
    o sinal de entrada é R[z] = 1
    Além disso, considera-se um feedback unitário, então M[z] = Y[z]
    Logo a diferença E[z] = R[z] - M[z] = 1 - Y[z]
    O controlador PID tem entrada E[z] e saída U[z]
    
    A função de transferência do motor é um sistema de entrada U[z] e saída Y[z].
    
    Para d>n (o caso do exercício), seus coeficientes são
     
    Y(z)      a0*z^n + a1*z^(n-1) + a2*z^(n-2) + ... + an-1
    ----  =  ----------------------------------------------------
    U(z)      1*z^d + b1*z^(d-1) + b2*z^(d-2) + ... + bd-1
    
    Multiplicando-se em cima e em baixo por z^(d)
     
    Y(z)      a0 + a1*z^(-1) + a2*z^(-2) + ... + an*z^(d-n)
    ----  =  ----------------------------------------------
    U(z)      1 + b1*z^(-1) + b2*z^(-2) + ... + bd*z^(-d)
     
    Logo, têm-se que: y[k] =      -b_1*y(k-1) -b_2*y(k-2) - ... - b_p*y(k-d+n)
                        +a_0*u(k) +a_1*u(k-1) +b_2*u(k-2) + ... + b_k*u(k-d) 
    
    Porém, espera-se que o programa seja capaz de lidar com o caso em que d<n, com o raciocínio análogo
    
    Inputs da função:
        motor --> sistema linear em tempo contínuo do motor
        metodo --> método de integração do sistema PID ('euler-backward' ou 'bilinear')
        Kp, Ki e Kd --> constantes de proporcionalidade do controlador PID
        Ta --> período de amostragem do sinal
        Tf --> tempo final de simulação

    Outputs da função:
        td --> vetor de tempo discretizado do sinal
        ed --> sinal de direnças
        ud --> sinal de saída do controlador PID
        y --> vetor de saída do sistema, com a resposta discreta a um impulso unitário controlada
*/

    // Modelo em tempo discreto do motor de corrente contínua usando o segurador de ordem zero (ZOH):
    motorD = dscr(motor,Ta); 
    
    // função de transferência do motor em tempo discreto (ZOH):
    GmotorD = ss2tf(motorD);
    
    // Inicializando variáveis
    td = 0:Ta:Tf-Ta;
    N = length(td);
    ed = zeros(td);  
    ud = zeros(td);
    yd = zeros(td);
    
    [kA] =coeff(GmotorD.num); // Coeficientes do numerador (saída)
    [kB] =coeff(GmotorD.den);  // Coeficientes do denominador (entrada)
    
    kA = kA ./ kB($) // Normaliza-se os coeficientes do polinômio
    kB = kB ./ kB($) // Normaliza-se os coeficientes do polinômio
    
    // Para d>n (como no exemplo)
    // A = [an-1, an-2 , an-3 , ... , an-d]
    // B = [bd-1, bd-2 , bd- 3, ... , 1 ]
    
    // Para facilitar o entendimento do código, invertem-se os vetores A e B
    kA = flipdim(kA,2) // Agora A = [an-d, ..., an-2, an-1, an]
    kB = flipdim(kB,2) // Agora B = [a0, a1, a2, ...]
    
    n=length(kA);
    d=length(kB);
    
    p = max([n,d]); // p é o maior grau da função de transferência no numerador ou denominador
                    // ele significa quantos estados anteriores o sistema utiliza
                    // no cálculo do estado atual
    
    
    
    // Adicionando zeros nos coeficientes complementares do menor polinômio
    if n==d then //Não há necessidade de adicionar zeros
    elseif p == n then
        new_B = [zeros(n-d), kB] 
        kB = new_B
    elseif p == d then
        new_A = [zeros(d-n), kA]
        kA = new_A
    end
    
    // No caso desse exercício, por exemplo, n = 2, d = 3, p = 3
    // a_0 = 0;
    // a_1 = kA(1);
    // a_2 = kA(2);
    //
    
    //b_0 = kB(1);
    //b_1 = kB(2);
    //b_2 = kB(3);
    
    
    // Constantes de integração do PID discreto (antes do loop para evitar repetição de cálculos)
    select metodo // Seleciona o tratamento para cada tipo de método de integração
    case 'bilinear' then       // Tarefa 1
    // Para determinar os coeficientes de aproximação de integração de um PID
    // de tempo contínuo, substitui-se o 's' da função de transferência do PID
    // C_PID = Kp + Ki/s + s*Kd
    // Pela transformação da integração trapezoidal s -> (2/Ta)*( 1-z^(-1) )/( 1+z^(-1) )
    // O cálculo resulta na equação de diferenças:
    // u(k) = u(k-1)+ Kek*e(k)+ Kek_1*e(k-1)+ Kek_2*e(k-2)
    // Onde os coeficientes são:
        Kek    =  Kp + Ki*Ta/2 + 2*Kd/Ta;
        Kek_1  =       Ki*Ta   - 4*Kd/Ta;
        Kek_2  = -Kp + Ki*Ta/2 + 2*Kd/Ta;
    case 'euler-backwards' then // Tarefa 2 (Tirado da apostila 6 da disciplina)
        Kek    =  Kp + Ki*Ta   +   Kd/Ta;
        Kek_1  = -Kp           - 2*Kd/Ta;
        Kek_2  =                   Kd/Ta;
    else
        error("Wrong input of method")
    end
    
    // Condições iniciais do sinal de saída --> motor parado, mas entrada unitária
    for i=1:(p-1)
        ud(i)=0;
        yd(i)=0;
        ed(i)=1; //Entrada unitária
    end
    
    disp(kA)
    disp(kB)
    
    // Aplicando a equação de diferenças
    for k = p:length(td)
        // Para a saída discreta y, como visto:
        // kA = [a0, a1, a2, ... , an-1]
        // kB = [1 , b1, b2, ... , bd-1] 
        // y[k] =           -b1*y(k-1) -b2*y(k-2) - ... - bd-1*y(k-d-1)
        //         +a0*u(k) +a1*u(k-1) +b2*u(k-2) + ... + bd-1*u(k-d-1) 
        
        for i = 1:p-1 //Somando yd += a_i*y(k-i) -b_i*u(k-i), com i = 1:p-1
            yd(k) = yd(k) - kB(i+1)*yd(k-i) + kA(i+1)*ud(k-i);
        end
        
        
        // Nesse problema:
        //a_2 = kA(2);
        //a_1 = kA(1);
        //a_0 = 0;
        
        //b_2 = kB(3);
        //b_1 = kB(2);
        //b_0 = kB(1);
        //yd(k) =(a_2*ud(k-2)+a_1*ud(k-1)-b_2*yd(k-2)-b_1*yd(k-1));
        
        ed(k)  = 1 - yd(k); // Diferença do sinal de impulso unitário menos o feedback unitário
        if metodo == 'bilinear' then
            ud(k) = ud(k-2)+ Kek*ed(k)+ Kek_1*ed(k-1)+ Kek_2*ed(k-2); // Multiplica-se os coeficientes calculados anteriormente
        else // metodo == 'euler-backwards'
            ud(k) = ud(k-1)+ Kek*ed(k)+ Kek_1*ed(k-1)+ Kek_2*ed(k-2);
        end
    end
    
    /*
    // Plot único do sinal obtido
    figure();
    plot2d(td,yd);
    title('Velocidade do motor controlado por um controle PID discreto pelo metodo ' + metodo + ' e tempo de amostragem Ta = ' + string(Ta) +' s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    */
endfunction

Ta = [0.25,0.1,0.05] //[s] períodos de amostragem desejados

Tf = 10;
[td1,ed1,ud1,yd1] = step_response_PID_digital(motor, 'bilinear' , KP, KI, KD, Ta(1), Tf);
[td2,ed2,ud2,yd2] = step_response_PID_digital(motor, 'bilinear' , KP, KI, KD, Ta(2), Tf);
[td3,ed3,ud3,yd3] = step_response_PID_digital(motor, 'bilinear' , KP, KI, KD, Ta(3), Tf);

// =============================================================================
//                                TAREFA 2
// =============================================================================
/*
Repita a Tarefa 1 usando a regra “para trás” (“backward rule”).

Obs.: não é preciso obter a aproximação em tempo discreto do compensador PID usando
a regra “para trás”, pode ser usado o resultado já mostrado na página 4 da apostila
“PME3402_TOPICO_06_PID_DIGITAL_2020.pdf”.
*/

[td4,ed4,ud4,yd4] = step_response_PID_digital(motor, 'euler-backwards', KP, KI, KD, Ta(1), Tf);
[td5,ed5,ud5,yd5] = step_response_PID_digital(motor, 'euler-backwards', KP, KI, KD, Ta(2), Tf);
[td6,ed6,ud6,yd6] = step_response_PID_digital(motor, 'euler-backwards', KP, KI, KD, Ta(3), Tf);


// =============================================================================
//                          ANÁLISE DOS RESULTADOS
// =============================================================================
/*
[ESTABILIDADE]

Percebe-se que ao aplicar as constantes Kp = 100, Ki = 200, Kd = 10, o sinal discreto
gerado pelo sistema diverge no método Bilinear. Isso ocorre, pois o sistema discretizado
do controlador PID por método de integração trapezoidal possui dois polos com módulo
unitário (z² - 1). Assim, a posição de suas duas raízes do sistema em malha aberta
devem estar em posições que não cumprem o critério de estabilidade de Nyquist,
fazendo com que uma das raízes do sistema fechado tivessem parte real positiva,
tornando o sistema instável.

O mesmo não ocorre para o método de Backwards Euler, que consegue estabilizar o
sistema, por possuir apenas um polo em (z -1) e ainda duas rapizes, conseguindo
cumprir o critério de Nyquist para essas condições. Ainda assim, este método de integração
diverge para Ta = 0,25s, por ser um período de amostragem alto acima do critério
de estabilidade <<<<<<[NÃO SEI QUAL CRITÉRIO. SERIA BOM PESQUISAR ISSO].

Ao alterar as constantes de ganho PID para 5, 40 e 0.1 respectivamente para P,I e D,
mudam-se as raízes do sistema, que agora passam a cumprir o critério de Nyquist
e o sistema passa a possuir estabilidade, conforme se observa nas figuras 2,3,4.

Após aplicar a mudança das constantes do PID,

[Bilinear --> apesar de estável, oscila p/ Ta=0,25s]

[RAPIDEZ]
Como esperado, em comparação ao sinal de controle contínuo, o controle discreto
possui muito mais atraso de resposta. Isso ocorre, pois, ao discretizar o sinal,
introduz-se um atraso ao sistema da ordem de X_Cont(s)/X_Disc(s) = e^(-Ta*s/2)

Deste modo, é visível, também, que quanto menor o período de amostragem, maior é
sua velocidade resposta em comparação ao sinal discreto.

É notável, também, que a rapidez de resposta do método de integração 'Euler-backwards'
é levemente maior do que o método de integração 'Bilinear'

[OVERSHOOT]
Euler-backwards --> oversoot levemente menor que Bilinear

*/


// =============================================================================
//                         PLOTAGEM DOS GRÁFICOS
// =============================================================================
cores = [
'blue4',
'deepskyblue3',
'aquamarine3',
'springgreen4',
'gold3',
'firebrick1',
'magenta3',
]

figure(2);
    subplot(2,1,1)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td1,yd1, style = color(cores(6)) );
    title('Controle do motor por PID discreto com metodo Bilinear e tempo de amostragem Ta = 0.25 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto'])
    
    subplot(2,1,2)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td4,yd4, style = color(cores(6)) );
    title('Controle do motor por PID discreto com metodo Euler-backwards e tempo de amostragem Ta = 0.25 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto'])
    
figure(3);
    subplot(2,1,1)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td2,yd2, style = color(cores(6)) );
    title('Controle do motor por PID discreto com metodo Bilinear e tempo de amostragem Ta = 0.1 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto'])
    
    subplot(2,1,2)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td5,yd5, style = color(cores(6)) );
    title('Controle do motor por PID discreto com metodo Euler-backwards e tempo de amostragem Ta = 0.1 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto'])
    
figure(4);
    subplot(2,1,1)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td3,yd3, style = color(cores(6)) );
    title('Controle do motor por PID discreto com metodo Bilinear e tempo de amostragem Ta = 0.05 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto'])
    
    subplot(2,1,2)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td6,yd6, style = color(cores(6)) );
    title('Controle do motor por PID discreto com metodo Euler-backwards e tempo de amostragem Ta = 0.05 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto'])
