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
// FUNÇÃO DE ANÁLISE ESPECTRAL DO SINAL
// =============================================================================

function [psd] = spectral_calculation(signal_t,fs)
    /*
    Inputs:
    sinat_t --> um vetor unidimensional sinal_t (Nx1) que representa o valor de um
    sinal temporal
    fs      --> um valor real que representa a frequência de amostragem do sinal em Hz
    
    Outputs:
    psd  --> vetor (N/2 x 1) de números reais com a densidade espectral de potência do sinal temporal
    */
    
    N = length(signal_t);
    
    //spectrum_f = fft(signal_t - mean(signal_t)); // Retira o viés do sinal (pico na frequência zero)
    spectrum_f = fft(signal_t); 
    
    spectrum_f = spectrum_f(1:N/2+1); // Como a fft é simétrica, pega-se metade do vetor
    
    psd = (1/(fs*N)) * ( abs(spectrum_f) ).^2 ; // PSD --> densidade espectral de potência
    psd(2:$-1) = 2*psd(2:$-1);
    
endfunction


// Analisando o período e frequência de amostragem do Arduino
function [Ts_vec, Ts, fs] = sampling_time_step(t)
    // Input: t --> vetor discreto de tempos
    Ts_vec = ( t(2:$,1) - t(1:$-1,1) ) // Intervalos de tempo entre uma medição e outra
    Ts = mean(Ts_vec);                 // Período de amostragem médio do sinal
    fs = 1/Ts;                         // Frequência de amostragem média do sinal
endfunction


// Analise espectral dos sinais
function [f, psd_d, psd_d_filt, psd_u] = data_spectral_treatment(fs,d,d_filt, u)
    /*
    Para evitar repetições de código, essa função aplica os calculos espectrais para todos os dados que temos 
    */
    N = length(d);
    f = (fs /N)*(0:N/2)'                    // Escala de frequências
    psd_d              = spectral_calculation(d,fs);
    psd_d_filt         = spectral_calculation(d_filt,fs);
    psd_u              = spectral_calculation(d,fs);
endfunction


// Análise do desempenho do controlador
function [absolute_error, rmse] = squared_error_analysis(signal, reference)
    absolute_error = (signal - reference);
    rmse = sqrt( mean( (signal - reference).^2 ) ); // Root Mean Squared Error (RMSE)
endfunction

// Carregamento dos dados
[t1,d1,d1_filt,u1] = data_read(data_folder,file_names(1));
[t2,d2,d2_filt,u2] = data_read(data_folder,file_names(2));

// Posições de referência dos dados
d1_ref = 20.0;
d2_ref = 30.0;

// Análise do período de amostragem
[Ta_t1, Ta1, fa1] = sampling_time_step(t1);
[Ta_t2, Ta2, fa2] = sampling_time_step(t2);

// Análise espectral
[f1,psd_d1, psd_d1_filt, psd_u1] = data_spectral_treatment(fa1,d1,d1_filt, u1);
[f2,psd_d2, psd_d2_filt, psd_u2] = data_spectral_treatment(fa2,d2,d2_filt, u2);

// Análise do desempenho do controlador
[err1, rmse1] = squared_error_analysis(d1_filt, d1_ref)
[err2, rmse2] = squared_error_analysis(d2_filt, d2_ref)


disp("RMSE da medição 1: " + string(rmse1) )
disp("RMSE da medição 2: " + string(rmse2) )

// =============================================================================
//                         ANÁLISE DOS RESULTADOS
// =============================================================================
/*
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

Comentários do Tamai
1 - O sensor de ultrassom tem uma faixa de operação. Se a bolinha estiver muito próxima, o sensor não fornece a distância correta.

2 - A dinâmica do sistema é muito diferente quando a bolinha está na saída livre do tubo (perto do sensor), pois parte da bolinha fica fora do tubo.

4 - A bancada é altamente não linear. Além da "zona morta" do ventilador, ou seja, toda a faixa de valores de rotação do ventilador desde o zero, até que a bolinha comece a subir, há também atrito no eixo do ventilador, fazendo que a tensão precise aumentar até um certo valor até que o ventilador comece a girar.

5 - Não é apenas isso, a perda de carga na região da bolinha muda bastante. Ou seja, suponha que você, em malha aberta, consiga o milagre de encontrar uma tensão que, aplicada no motor do ventilador, faz com que a bolinha fique equilibrada. Basta ocorrer alguma mudança na posição da bolinha, e ela pode cair e ficar "presa" na posição inferior, se, por exemplo, essa tensão é insuficiente para mover a bolinha (item 4).

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
function plot_dist(t, d, d_filt, d_ref, rmse, medicao)
    fig = scf();
    plot2d(t, d, style = color(cores(2)) );
    plot2d(t, d_filt, style = color(cores(7)) );
    plot2d(t, d_ref*ones(t), style = color('red') )
    title('Distância captada pelo ultrassom na medição ' + string(medicao) + " ( RMSE = " + string(rmse) + " )." );
    ylabel("d (cm)");
    xlabel("tempo(s)");
    h= legend(['Sinal medido';'Filtrado'; 'Referência']);
endfunction

plot_dist(t1,d1,d1_filt, d1_ref, rmse1, 1);
plot_dist(t2,d2,d2_filt, d2_ref, rmse2, 2);


function plot_PID(t, abs_error, u, rmse, medicao)
    fig = scf();
    subplot(2,1,1)
    plot2d(t, abs_error, style = color(cores(2)) );
    title('Erro entre a distância captada e o sinal de referência na medição ' + string(medicao) + " ( RMSE = " + string(rmse) + " )." );
    ylabel("Erro (cm)");
    xlabel("tempo(s)");
    
    subplot(2,1,2)
    plot2d(t, u, style = color(cores(7)) );
    title('Saída do controlado PID na medição ' + string(medicao) + " ( RMSE = " + string(rmse) + " )." );
    ylabel("Saída do PID");
    xlabel("tempo(s)");
endfunction

plot_PID(t1,err1,u1, rmse1, 1);
plot_PID(t2,err2,u2, rmse2, 2);

