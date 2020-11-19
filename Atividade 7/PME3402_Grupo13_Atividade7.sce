/*
=============================================================================
                        
                        Escola Politécnica da USP
         PME3402 - Laboratório de Medição e Controle Discreto
       --------------------------------------------------------------
   ATIVIDADE 7 - Controle digital por PID da posição de uma bola de isopor 
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
1) Certifique-se de que o Scilab está aberto na pasta "/Atividade 7/"
em que o programa se encontra
2) Certifique-se de que os dados do sensor Ultrassônico estão na pasta
"/Atividade 7/Processing_save_serial" dentro da pasta do programa
3) Rode o programa
*/

//LIMPEZA DE MEMÓRIA
clear;
clc;    // Limpeza de variáveis e do console
xdel(winsid()); // Fecha as janelas abertas

// Lendo arquivos
data_folder = 'Processing_save_serial'

file_names = [
    'Medicao 1 - Ref 20,Kp 0_6,Ki 0_1, Kd 0_1, max 30, min -15.csv',
    'Medicao 2 - Ref 30,Kp 0_6,Ki 0_1, Kd 0_1, max 30, min -15.csv',
    'Medicao 3 - Ref 30.csv',
    'Leitura_Sensor_11_19_20_3_28.csv',
    'Leitura_Sensor_11_19_20_5_4.csv',
    'Leitura_Sensor_11_19_20_6_18.csv',
    'Leitura_Sensor_11_19_20_7_14.csv',
];

// =============================================================================
// FUNÇÃO DE CARREGAMENTO DOS DADOS
// =============================================================================

function [t,d,d_filt,u] = data_read(data_folder,filename)
    // Obtendo os caminhos de cada arquivo do experimento
    base_path = pwd(); // Diretório atual onde o Scilab está aberto
    s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)
    
    data_directory = base_path + s + data_folder;
    //Ordem de chamada: csvRead(filename, separator, decimal, conversion, substitute, regexpcomments, range, header)
    data   = csvRead(data_directory + s + filename, ',','.','double', [], [], [], 1 );
    
    t = data(:,1) / 1000; // Sinal está em ms, e passa-se para s
    d = data(:,2);        // Sinal do sensor ultrassom em cm
    d_filt = data(:,3);   // Sinal fitlrado do sensor ultrassom em cm
    u = data(:,4);        // Sinal da saída do Controlador PID enviado ao motor
    
endfunction

// =============================================================================
// FUNÇÃO DE ANÁLISE DA FREQUÊNCIA DE AMOSTRAGEM
// =============================================================================
function [Ts_vec, Ts, fs] = sampling_time_step(t)
    // Input: t --> vetor discreto de tempos
    Ts_vec = ( t(2:$,1) - t(1:$-1,1) ) // Intervalos de tempo entre uma medição e outra
    Ts = mean(Ts_vec);                 // Período de amostragem médio do sinal
    fs = 1/Ts;                         // Frequência de amostragem média do sinal
endfunction

// =============================================================================
// MÉTRICA DE ANÁLISE DO DESEMPENHO DO CONTROLADOR
// =============================================================================
function [absolute_error, rmse] = squared_error_analysis(signal, reference)
    absolute_error = (signal - reference);
    rmse = sqrt( mean( (signal - reference).^2 ) ); // Root Mean Squared Error (RMSE)
endfunction

// Carregamento dos dados
[t1,d1,d1_filt,u1] = data_read(data_folder,file_names(1));
[t2,d2,d2_filt,u2] = data_read(data_folder,file_names(2));
[t3,d3,d3_filt,u3] = data_read(data_folder,file_names(3));
[t4,d4,d4_filt,u4] = data_read(data_folder,file_names(4));
[t5,d5,d5_filt,u5] = data_read(data_folder,file_names(5));
[t6,d6,d6_filt,u6] = data_read(data_folder,file_names(6));
[t7,d7,d7_filt,u7] = data_read(data_folder,file_names(7));

// Posições de referência dos dados
d1_ref = 20.0;
d2_ref = 30.0;
d3_ref = 30.0;
d4_ref = 30.0;
d5_ref = 45.0;
d6_ref = 10.0;
d7_ref = 15.0;

// Análise do período de amostragem
[Ta_t1, Ta1, fa1] = sampling_time_step(t1);
[Ta_t2, Ta2, fa2] = sampling_time_step(t2);
[Ta_t3, Ta3, fa3] = sampling_time_step(t1);
[Ta_t4, Ta4, fa4] = sampling_time_step(t2);
[Ta_t5, Ta5, fa5] = sampling_time_step(t1);
[Ta_t6, Ta6, fa6] = sampling_time_step(t2);
[Ta_t7, Ta7, fa7] = sampling_time_step(t2);

// Análise do desempenho do controlador
[err1, rmse1] = squared_error_analysis(d1_filt, d1_ref);
[err2, rmse2] = squared_error_analysis(d2_filt, d2_ref);
[err3, rmse3] = squared_error_analysis(d3_filt, d3_ref);
[err4, rmse4] = squared_error_analysis(d4_filt, d4_ref);
[err5, rmse5] = squared_error_analysis(d5_filt, d5_ref);
[err6, rmse6] = squared_error_analysis(d6_filt, d6_ref);
[err7, rmse7] = squared_error_analysis(d7_filt, d7_ref);


disp("RMSE da medição 1: " + string(rmse1) )
disp("RMSE da medição 2: " + string(rmse2) )
disp("RMSE da medição 3: " + string(rmse3) )
disp("RMSE da medição 4: " + string(rmse4) )
disp("RMSE da medição 5: " + string(rmse5) )
disp("RMSE da medição 6: " + string(rmse6) )
disp("RMSE da medição 7: " + string(rmse7) )



// =============================================================================
//                         ANÁLISE DOS RESULTADOS
// =============================================================================
/*

Resultados obtidos nas medições:
Medição 1 (ref = 20.0, K_P = 0.6 , K_I = 0.1 , K_D = 0.1 , PID_min = -15, PID_max = 30) --> RMSE = 6.3840101
Medição 2 (ref = 30.0, K_P = 0.6 , K_I = 0.1 , K_D = 0.1 , PID_min = -15, PID_max = 30) --> RMSE = 4.6528019
Medição 3 (ref = 30.0, K_P = 0.6 , K_I = 0.12, K_D = 0.1 , PID_min = -15, PID_max = 30) --> RMSE = 4.560936
Medição 4 (ref = 30.0, K_P = 0.55, K_I = 0.12, K_D = 0.12, PID_min = -15, PID_max = 30) --> RMSE = 4.4613355
Medição 5 (ref = 45.0, K_P = 0.55, K_I = 0.12, K_D = 0.12, PID_min = -15, PID_max = 30) --> RMSE = 3.451867
Medição 6 (ref = 10.0, K_P = 0.55, K_I = 0.12, K_D = 0.12, PID_min = -15, PID_max = 30) --> RMSE = 8.461225
Medição 7 (ref = 15.0, K_P = 0.55, K_I = 0.12, K_D = 0.12, PID_min = -15, PID_max = 30) --> RMSE = 8.5295188

Comentários do Tamai
1 - O sensor de ultrassom tem uma faixa de operação. Se a bolinha estiver muito próxima, o sensor não fornece a distância correta.

2 - A dinâmica do sistema é muito diferente quando a bolinha está na saída livre do tubo (perto do sensor), pois parte da bolinha fica fora do tubo.

4 - A bancada é altamente não linear. Além da "zona morta" do ventilador, ou seja, toda a faixa de valores de rotação do ventilador desde o zero, até que a bolinha comece a subir, há também atrito no eixo do ventilador, fazendo que a tensão precise aumentar até um certo valor até que o ventilador comece a girar.

5 - Não é apenas isso, a perda de carga na região da bolinha muda bastante. Ou seja, suponha que você, em malha aberta, consiga o milagre de encontrar uma tensão que, aplicada no motor do ventilador, faz com que a bolinha fique equilibrada. Basta ocorrer alguma mudança na posição da bolinha, e ela pode cair e ficar "presa" na posição inferior, se, por exemplo, essa tensão é insuficiente para mover a bolinha (item 4).


Lógica empregada no controle do Arduino:

medir a distancia da bolinha
filtra distancia medida

Cálculo do erro
Tipo, geralmente o cálculo do erro seria erro = referência - medido, mas tem que pensar que o referencial do sensor de distância é outro, então a gente quer que ele "aumente" o sinal do ventilador caso a distância medida seja maior do que a referência
erro = - (ref_dist - filtered_dist);

equação de diferenças para pegar a saída do PID

Mapear a saída do PID: sinal = mapFloat(PID_out, PID_min, PID_max , 0.0 ,255.0)

PID_max e PID_min dependem de vários fatores, como as constantes do controlador (Kp,Ki,Kd) e da posição de referência escolhida. Para um valor que funcionasse para os Ks testados e para diferentes posições de referência foram valores arbitrarios testados experimentalmente. Uma estimativa utilizada pela equipe para estimar esses extremos foi considerar 10% a mais do erro máximo e mínimo quando só há a atuação da constante proporcional do controlador PID

Código do Arduino utilizado
#define max_dist 55.0           // Distância máxima da bola no tubo (bola em contato com o ventilador)
#define min_dist 5.0            // Distância mínima da bola no tubo (bola na saída do tubo)
const float error_max = - (ref_dist - max_dist);
const float error_min = - (ref_dist - min_dist);
const float PID_min_estimado = 1.1*K_P*error_min;          // Constante para o mapeamento da saída do PID entre 0 e 255
const float PID_max_estimado = 1.1*K_P*error_max;          // Constante para o mapeamento da saída do PID entre 0 e 255


analogWrite(sinal)

Atualiza variaveis para o próximo loop


*/
// =============================================================================
//                         PLOTAGEM DOS GRÁFICOS
// =============================================================================

cores = [
'blue4',        // 1
'deepskyblue3', // 2
'aquamarine3',  // 3
'springgreen4', // 4
'gold3',        // 5
'firebrick1',   // 6
'magenta3',     // 7
'red',          // 8
]

// Plot das distâncias
function plot_dist(t, d, d_filt, d_ref, u, abs_error, rmse, medicao)
    fig = scf();
    
    subplot(2,1,1)
    plot2d(t, d, style = color(cores(2)) );
    plot2d(t, d_filt, style = color(cores(7)) );
    plot2d(t, d_ref*ones(t), style = color('red') )
    title('Distância captada pelo ultrassom na medição ' + string(medicao) + " ( RMSE = " + string(rmse) + " )." );
    ylabel("d (cm)");
    xlabel("tempo(s)");
    h= legend(['Sinal medido';'Filtrado'; 'Referência']);
    
    subplot(2,2,3)
    plot2d(t, abs_error, style = color(cores(2)) );
    title('Erro entre a distância captada e o sinal de referência na medição ' + string(medicao));
    ylabel("Erro (cm)");
    xlabel("tempo(s)");
    
    subplot(2,2,4)
    plot2d(t, u, style = color(cores(7)) );
    title('Saída do controlado PID na medição ' + string(medicao) );
    ylabel("Saída do PID");
    xlabel("tempo(s)");
endfunction

plot_dist(t1,d1,d1_filt, d1_ref, u1, err1, rmse1, 1);
plot_dist(t2,d2,d2_filt, d2_ref, u2, err2, rmse2, 2);
plot_dist(t3,d3,d3_filt, d3_ref, u3, err3, rmse3, 3);
plot_dist(t4,d4,d4_filt, d4_ref, u4, err4, rmse4, 4);
plot_dist(t5,d5,d5_filt, d5_ref, u5, err5, rmse5, 5);
plot_dist(t6,d6,d6_filt, d6_ref, u6, err6, rmse6, 6);
plot_dist(t7,d7,d7_filt, d7_ref, u7, err7, rmse7, 7);

