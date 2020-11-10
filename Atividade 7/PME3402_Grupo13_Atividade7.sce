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
];

// =============================================================================
// FUNÇÃO DE CARREGAMENTO DOS DADOS
// =============================================================================

function [t,d,d_filt,u] = data_read(data_folder,filename, plot_signal)
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
    
    // Plotagem dos gráficos individuais
    if plot_signal then
        cores = [
            'blue4',
            'deepskyblue3',
            'aquamarine3',
            'springgreen4',
            'gold3',
            'firebrick1',
            'magenta3',
        ]
        scf();
            subplot(2,1,1)
            fig = gca();
            plot2d(t,d, style = color(cores(1)) );
            title('Distância lida pelo ultrassom (cm)');
            ylabel("d (cm)");
            xlabel("tempo(s)");
        
            subplot(2,1,2)
            plot2d(t,u, style = color(cores(1)) );
            title('Tensão enviada ao motor');
            ylabel("Tensão (V)");
            xlabel("tempo(s)");
    end
endfunction

// =============================================================================
// FUNÇÃO DE APLICAÇÃO DO FILTRO PELO SCILAB
// =============================================================================

function [y] = filtro_passa_baixa(e, fc, Ts)
    /*
    Realiza a filtragem numérica de um sinal discreto e[k] por meio da aproximação
    bilinear de um filtro digital passa baixa de 1º ordem 
    
    Inputs
        e --> sinal discretizado
        fc --> frequência de corte do filtro (Hz)
        Ts --> período de amostragem do sinal
    Output
        y --> sinal filtrado
    */
    
    wc = 2*%pi*fc;  // Frequência de corte do filtro (rad/s)
    // Cálculo dos coeficientes do filtro
    Cy_1 =  -(1 - (wc*Ts)/2) / (1 + (wc*Ts)/2);
    Ce_0 = ((wc*Ts)/2) / (1 + (wc*Ts)/2);
    Ce_1 = Ce_0;
    
    y = zeros(e); // Cria um vetor de zeros do tamanho do vetor e
    y(1) = e(1);  // Atribuindo o valor inicial
    
    // Loop da filtragem do sinal e[k]
    for k =2:length(e)
        y(k) = -Cy_1*y(k-1) + Ce_1*e(k-1) + Ce_0*e(k);
    end
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



// Carregamento dos dados

// Analisando o período e frequência de amostragem do Arduino
function [Ts_vec, Ts, fs] = sampling_time_step(t)
    // Input: t --> vetor discreto de tempos
    Ts_vec = ( t(2:$,1) - t(1:$-1,1) ) // Intervalos de tempo entre uma medição e outra
    Ts = mean(Ts_vec);                 // Período de amostragem médio do sinal
    fs = 1/Ts;                         // Frequência de amostragem média do sinal
endfunction


// Analise espectral dos sinais

function [f, psd_d, psd_d_filt_Arduino, psd_d_filt_Scilab, psd_u] = data_spectral_treatment(fs,d,d_filt_Arduino,d_filt_Scilab, u)
    /*
    Para evitar repetições de código, essa função aplica os calculos espectrais para todos os dados que temos 
    */
    N = length(d);
    f = (fs /N)*(0:N/2)'                    // Escala de frequências
    psd_d              = spectral_calculation(d,fs);
    psd_d_filt_Arduino = spectral_calculation(d_filt_Arduino,fs);
    psd_d_filt_Scilab  = spectral_calculation(d_filt_Scilab,fs);
    psd_u              = spectral_calculation(d,fs);
endfunction


// =============================================================================
// ANÁLISE DO DESEMPENHO DO CONTROLADOR
// =============================================================================

function [sqr_error, msqr, bias] = squared_error_analysis(signal, reference)
    sqr_error = (signal - reference).^2;
    msqr = mean(sqr_error);
    bias = stdev(sqr_error);
endfunction


// =============================================================================
// ANÁLISE DOS RESULTADOS
// =============================================================================
/*


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
