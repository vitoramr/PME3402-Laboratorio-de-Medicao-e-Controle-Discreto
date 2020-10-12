/*
=============================================================================
                        
                        Escola Politécnica da USP
         PME3402 - Laboratório de Medição e Controle Discreto
       --------------------------------------------------------------
            ATIVIDADE 4 - CONTROLE DE MOTOR POR PID DISCRETO
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
KP=100;
KI=200;
KD=10;

//KP=5;
//KI=40;
//KD=0.1;

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

function [td,ed,ud,yd] = step_response_PID_digital(motor, metodo, Kp, Ki, Kd, Ta, Tf, zero_to_cancel, gain)
/*
    Por meio da equação de diferenças, essa função calcula a resposta discreta
    a um pulso unitário da função de transferência discreta do motor controlada
    por um controlador PID discreto.

    Ela calcula o controlador pela aproximação de um controlador PID contínuo
    por meio de métodos de integração diferentes:
       - metodo = 'bilinear' (trapezoidal) (atividade 1)
       - metodo = 'bilinear-corrected' (atividade1)
       - metodo = 'euler-backwards' (método de 'Backwards' Euler) (atividade 2)
    
    Devido à instabilidade do controlador PID pelo método Bilinear, oferece-se a
    possibilidade de corrigir a arquitetura do PID discreto adicionando um zero
    a ser cancelado e um ganho.
    
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
                        +a_0*u(k) +a_1*u(k-1) +a_2*u(k-2) + ... + a_k*u(k-d) 
    
    A função foi concebida e testada para o caso em que d>n. O caso em que d=n
    não foi testado, mas espera-se que a função também seja funcional nesse caso
    
    Inputs da função:
        motor          --> sistema linear em tempo contínuo do motor
        metodo         --> método de integração do sistema PID ('euler-backward', 'bilinear' ou 'bilinear-corrected')
        Kp, Ki e Kd    --> constantes de proporcionalidade do controlador PID
        Ta             --> período de amostragem do sinal
        Tf             --> tempo final de simulação
        zero_to_cancel --> um numéro real que representa o zero a ser cancelado no PID
                           com método de integração 'bilinear-corrected'
        gain           --> ganho de correção adicionado à função de transferência
                           do PID discreto com método de integração bilinear

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
    
    p_system = p;   // Caso seja o método corrigido, o sistema talvez precise de mais casas
    
    // Adicionando zeros nos coeficientes complementares do menor polinômio
    if n==d then //Não há necessidade de adicionar zeros
    elseif p == n then
        new_B = [zeros(1,n-d), kB] 
        kB = new_B
    elseif p == d then
        new_A = [zeros(1,d-n), kA]
        kA = new_A
    end
    
    kB(1) = 0; //Zera-se b0 para facilitar a entrada no loop de diferenças,
               //pois é o coeficiente que foi isolado para y[k]
    
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
    
    case 'bilinear-corrected' then // Tarefa 1
        // Calculando a função de transferência do corretor com o zero corrigido
        // e com ganho adicionado
        
        z = poly(0,'z');
        s_trap = (2/Ta)*(z-1)/(z+1); //Aproximação de s pra o método de integração trapezoidal
        GpidD = Kp+(Ki/s_trap)+Kd*s_trap;
        
        // Análise de estabilidade
        figure()
        subplot(2,1,1)
        evans(GmotorD*GpidD, 2)
        title('Local das raízes e polos do sistema discreto em malha aberta com Ta=' +string(Ta)+ 's, Kp = ' +string(KP)+ ', Ki = ' +string(KI)+ ' e Kd = ' +string(KD));
        ylabel("Eixo imaginário");
        xlabel("Eixo real");
        fig = gca();
        fig.data_bounds = [-1.1,1.1, -1.1,1.1];
        
        corrected_GpidD = gain*GpidD / (z-zero_to_cancel)
        GpidD = corrected_GpidD
        
        // Análise de estabilidade da malha aberta corrigida
        subplot(2,1,2)
        evans(GmotorD*corrected_GpidD, 2)
        title('Local das raízes e polos do sistema discreto em malha aberta, zero cancelado em '  + string(zero_to_cancel) + ', ganho = ' +string(gain)+ ', Ta=' +string(Ta)+ 's, Kp = ' +string(KP)+ ', Ki = ' +string(KI)+ ' e Kd = ' +string(KD));
        ylabel("Eixo imaginário");
        xlabel("Eixo real");
        fig = gca()
        fig.data_bounds = [-1.1,1.1, -1.1,1.1]
        
        // Para encontrar a nova equação de diferenças para o controlador PID controlador corrigido,
        // aplica-se o mesmo raciocínio utilizado para o Y
        // Contudo, como esta tem formato fixo, serão utilizadas variáveis fixas para seus
        // coeficientes
        
        // U(z)       Kek_3 + Kek_2*z + Kek_1*z²
        // ----  = -------------------------------
        // E(z)     Kuk_3 + Kuk_2*z + Kuk_1*z² + 1
        //
        // u[k] =      -Kuk_1*u(k-1) -Kuk_2*u(k-2) - Kuk_3*u(k-3)
        //             +Kek_1*e(k-1) +Kek_2*e(k-2) + Kek_3*e(k-3)
                    // Análise de estabilidade
        
        [numPID] =coeff(GpidD.num); // Coeficientes do numerador (saída)
        [denPID] =coeff(GpidD.den); // Coeficientes do denominador (entrada)
        
        p_PID = max(length(numPID), length(denPID));
        
        p_system = max(p, p_PID);   // Quantos estados anteriores o sistema necessita 
        
        // Normalizando os coeficientes
        numPID = numPID ./ denPID($)
        denPID = denPID ./ denPID($)
        
        Kuk_3 = denPID(1)
        Kuk_2 = denPID(2)
        Kuk_1 = denPID(3)
        //Kuk = denPID(4) = 1
        
        Kek_3 = numPID(1)
        Kek_2 = numPID(2)
        Kek_1 = numPID(3)
    else
        error("Wrong input of method")
    end
    
    // Condições iniciais do sinal de saída --> motor parado, mas entrada unitária
    for i=1:(p_system-1)
        ud(i)=0;
        yd(i)=0;
        ed(i)=1; //Entrada unitária
    end
    
    // Aplicando a equação de diferenças
    for k = p_system:length(td)
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
        elseif metodo == 'euler-backwards'
            ud(k) = ud(k-1)+ Kek*ed(k)+ Kek_1*ed(k-1)+ Kek_2*ed(k-2);
        elseif metodo == 'bilinear-corrected'
            ud(k) = -Kuk_3*ud(k-3) - Kuk_2*ud(k-2) - Kuk_1*ud(k-1) + Kek_1*ed(k-1)+ Kek_2*ed(k-2) + Kek_3*ed(k-3); // Multiplica-se os coeficientes calculados anteriormente
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

[td0,ed0,ud0,yd0] = step_response_PID_digital(motor, 'bilinear' , KP, KI, KD, Ta(3), Tf, 0,0); //Sem correção

[td1,ed1,ud1,yd1] = step_response_PID_digital(motor, 'bilinear-corrected' , KP, KI, KD, Ta(1), Tf, -0.377, 0.2); //Corrigido

[td7,ed7,ud7,yd7] = step_response_PID_digital(motor, 'bilinear-corrected' , KP, KI, KD, Ta(1), Tf, -0.377, 0.1); //Corrigido
[td2,ed2,ud2,yd2] = step_response_PID_digital(motor, 'bilinear-corrected' , KP, KI, KD, Ta(2), Tf, -0.671, 0.8); //Corrigido
[td3,ed3,ud3,yd3] = step_response_PID_digital(motor, 'bilinear-corrected' , KP, KI, KD, Ta(3), Tf, -0.82, 1); //Corrigido



// =============================================================================
//                                TAREFA 2
// =============================================================================
/*
Repita a Tarefa 1 usando a regra “para trás” (“backward rule”).

Obs.: não é preciso obter a aproximação em tempo discreto do compensador PID usando
a regra “para trás”, pode ser usado o resultado já mostrado na página 4 da apostila
“PME3402_TOPICO_06_PID_DIGITAL_2020.pdf”.
*/

[td4,ed4,ud4,yd4] = step_response_PID_digital(motor, 'euler-backwards', KP, KI, KD, Ta(1), Tf, 0); //Sem correção
[td5,ed5,ud5,yd5] = step_response_PID_digital(motor, 'euler-backwards', KP, KI, KD, Ta(2), Tf, 0); //Sem correção
[td6,ed6,ud6,yd6] = step_response_PID_digital(motor, 'euler-backwards', KP, KI, KD, Ta(3), Tf, 0); //Sem correção


// =============================================================================
//                          ANÁLISE DOS RESULTADOS
// =============================================================================
/*
[ESTABILIDADE]

Percebe-se que ao aplicar as constantes Kp = 100, Ki = 200, Kd = 10, o sinal discreto
gerado pelo sistema diverge no método Bilinear (figura 6). Isso ocorre, pois o sistema discretizado
do controlador PID por método de integração trapezoidal possui dois polos com módulo
unitário (z² - 1), um em -1 e outro em 1. Assim, este sistema compensado será sempre
instável para qualquer ganho positivo porque há um número par de pólos e zeros à
direita do pólo em -1. Como o polo em -1 vem do controlador, muda-se a arquitetura
do controlador PID para cancelar algum de seus zeros à direita de -1, o que torna
o sistema estável para alguns ganhos, adicionando-se também um ganho ao controlador
para manter o lugar geométrico das raízes e polos dentro do círculo unitário.

O mesmo não ocorre para o método de Backwards Euler, que consegue estabilizar o
sistema (figura 6). Isso ocorre, pois o controlador PID discreto possuir apenas
um polo em 1, ainda possuindo duas raizes, conseguindo cumprir o critério de Nyquist.
Ainda assim, este método de integração diverge para Ta = 0,25s (figura 9), por
ser um período de amostragem alto. Isso ocorre pois, para um tempo de amostragem maior,
o sistema fica menos sensível a variações rápidas e acaba desconsiderando variações
que o levariam a uma convergência ou o método sofre variações muito grandes a
cada integração, gerando uma dificuldade na estabilização da resposta do sistema.

Também, o método de Backwards-Euler para Ta=0,1s e esses ganhos do controlador PID (figura 7)
apresenta uma resposta oscilante. Embora ela seja estável, por não divergir, a 
resposta do sistema não atinge um regime permanente, oscilando ao redor do sinal
de entrada de 1.

Ao adicionar as correções de zero e de ganho ao controlador PID discreto com o método trapezoidal,
o sistema passa a possuir estabilidade, conforme observa-se nas figuras 6,7 e 8.
Os valores do zero a ser utilizado para correção foram obtidos por meio da plotagem do
local das suas raízes e polos da função de transferência do sistema em malha aberta.
Os valores do ganho foram ajustados empiricamente para obtenção de um sistema
estável, em que o contorno do local das raízes e polos ficasse dentro do círculo unitário.

Após aplicar a correção do controlador PID trapezoidal, nota-se que o método 'Bilinear'
corrigido passou a convergir, enquanto o método de integração numérica de 'Euler-Backwards'
apresenta estabilidade para os períodos de amostragem de T=0,1s e T=0,05s, e instabilidade para T=0,25s.


[RAPIDEZ]
Como esperado, em comparação ao sinal de controle contínuo, o controle discreto
possui um atraso significativo em sua resposta. Isso ocorre, pois, ao discretizar o sinal,
introduz-se um atraso ao sistema da ordem de X_Cont(s)/X_Disc(s) = e^(-Ta*s/2).
A partir dessa expressão, é visível, também, que quanto menor o período de amostragem, maior é
sua velocidade resposta em comparação ao sinal discreto.

É notável, além disso, que a rapidez de resposta do método de integração Bilinear corrigido
é levemente maior do que a do método de integração Euler-backwards para as constantes
do controlador utilizadas.

[OVERSHOOT]
Percebe-se que o Overshoot da resposta depende das constantes Kp, Kd e Ki do
controlador PID, além do ganho na correção do Método Bilinear.

Na figura 10, por exemplo, vê-se a comparação de dois ganhos de correção na resposta
do sistema controlado pelo PID com médoto de aproximação Bilinear corrigio para
o período de amostragem de T=0,25s. Enquanto na figura 10.1, utilizando um ganho de 0,2 , existe um grande
overshoot, ao utilizar um ganho de 0,1 (figura 10.2), o overshoot diminui e aumenta-se
o tempo de resposta.

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

figure(6);
    subplot(2,1,1)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td0,yd0, style = color(cores(6)) );
    title('Figura 6.1: Controle do motor por PID discreto sem correção e com metodo Bilinear e tempo de amostragem Ta = 0.05 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto']);
    
    subplot(2,1,2)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td6,yd6, style = color(cores(6)) );
    title('Figura 6.2: Controle do motor por PID discreto com metodo Euler-backwards e tempo de amostragem Ta = 0.05 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto']);

figure(7);
    subplot(2,1,1)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td1,yd1, style = color(cores(6)) );
    title('Figura 7.1: Controle do motor por PID discreto com metodo Bilinear e tempo de amostragem Ta = 0.25 s, corrigido adicionando um polo em -0.377 e ganho .');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto']);
    
    subplot(2,1,2)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td4,yd4, style = color(cores(6)) );
    title('Figura 7.2: Controle do motor por PID discreto com metodo Euler-backwards e tempo de amostragem Ta = 0.25 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto'])
    
figure(8);
    subplot(2,1,1)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td2,yd2, style = color(cores(6)) );
    title('Figura 8.1: Controle do motor por PID discreto com metodo Bilinear e tempo de amostragem Ta = 0.1 s, corrigido adicionando um polo em -0.671 e ganho 0.8 .');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto']);
    
    subplot(2,1,2)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td5,yd5, style = color(cores(6)) );
    title('Figura 8.2: Controle do motor por PID discreto com metodo Euler-backwards e tempo de amostragem Ta = 0.1 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto']);
    
figure(9);
    subplot(2,1,1)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td3,yd3, style = color(cores(6)) );
    title('Figura 9.1: Controle do motor por PID discreto com metodo Bilinear e tempo de amostragem Ta = 0.05 s, corrigido adicionando um polo em -0.82 e ganho 0.8 .');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto'])
    
    subplot(2,1,2)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td6,yd6, style = color(cores(6)) );
    title('Figura 9.2: Controle do motor por PID discreto com metodo Euler-backwards e tempo de amostragem Ta = 0.05 s.');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto']);
   
   
figure(10);
    subplot(2,1,1)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td1,yd1, style = color(cores(6)) );
    title('Figura 10.1: Controle do motor por PID discreto com metodo Bilinear e tempo de amostragem Ta = 0.25 s, corrigido adicionando um polo em -0.377 e ganho 0.2 .');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto'])
    
    subplot(2,1,2)
    plot2d(t,y, style = color(cores(1)) );
    plot2d(td7,yd7, style = color(cores(6)) );
    title('Figura 10.2: Controle do motor por PID discreto com metodo Bilinear e tempo de amostragem Ta = 0.25 s, corrigido adicionando um polo em -0.377 e ganho 0.1 .');
    ylabel("Velocidade (rad/s)");
    xlabel("tempo(s)");
    legend(['PID contínuo';'PID discreto']);
