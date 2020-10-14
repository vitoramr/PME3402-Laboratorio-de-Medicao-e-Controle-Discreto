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

INSTRUÇÕES PARA RODAR O PROGRAMA
Antes de rodar o programa, siga os seguintes passos
1) Certifique-se de que o Scilab está aberto na pasta "/Atividade 5/"
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
// CARREGAMENTO DOS DADOS
// =============================================================================

// Lendo arquivos
data_folder = 'Processing_save_serial'

file_names = [
    'Leitura_Sensor_10_14_15_35_4.csv',  // T = 2, Sinal varia de 0 a 5V ( velocidade = (255/2)*sin(w*t) + (255/2) )
    'Leitura_Sensor_10_14_15_39_44.csv', // T = 2, Sinal varia de 0 a 5V ( velocidade = (255/2)*sin(w*t) + (255/2) )
    'Leitura_Sensor_10_14_15_49_25.csv', // T = 1, Sinal da velocidade = 105 + 50*sin(w*t)
    'Leitura_Sensor_10_14_15_52_23.csv', // T = 0.5 , Sinal varia de 0 a 5V ( velocidade = (255/2)*sin(w*t) + (255/2) )
];

//Ordem de chamada: csvRead(filename, separator, decimal, conversion, substitute, regexpcomments, range, header)
function [t,d,u] = data_read(data_folder,filename, plot_signal)
    // Obtendo os caminhos de cada arquivo do experimento
    base_path = pwd(); // Diretório atual onde o programa está
    s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)
    
    data_directory = base_path + s + data_folder;
    sensor   = csvRead(data_directory + s + filename, ',','.','double', [], [], [], 1 );
    
    t = sensor(:,1) / 1000; // Sinal está em ms
    d = sensor(:,2);        // Sinal do sensor em cm
    u = sensor(:,3)*5/255;  // Sinal tem a tensão entre 0 --> 0V e 255 --> 5V
    
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

plot_na_funcao = %F; // %T para True ou %F para False

[t1,d1,u1] = data_read(data_folder, file_names(1), plot_na_funcao);
[t2,d2,u2] = data_read(data_folder, file_names(2), plot_na_funcao);
[t3,d3,u3] = data_read(data_folder, file_names(3), plot_na_funcao);
[t4,d4,u4] = data_read(data_folder, file_names(4), plot_na_funcao);

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

f0 = scf(0)
    subplot(2,1,1)
    plot2d(t1,d1, style = color(cores(1)) );
    title('Distância lida pelo ultrassom (cm)');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(2,1,2)
    plot2d(t1,u1, style = color(cores(1)) );
    title('Tensão enviada ao motor');
    ylabel("Tensão (V)");
    xlabel("tempo(s)");


f1= scf(1);
    subplot(2,1,1)
    plot2d(t1(d1 < 60),d1(d1<60), style = color(cores(1)) ); // Plotando apenas entre 0 e 60
    title('Distância lida pelo ultrassom (cm)');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(2,1,2)
    plot2d(t1,u1, style = color(cores(1)) );
    title('Tensão enviada ao motor');
    ylabel("Tensão (V)");
    xlabel("tempo(s)");
    
    
f2= scf(2);
    subplot(2,1,1)
    plot2d(t2(d2<60),d2(d2<60), style = color(cores(1)) );
    title('Distância lida pelo ultrassom (cm)');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(2,1,2)
    plot2d(t2,u2, style = color(cores(1)) );
    title('Tensão enviada ao motor');
    ylabel("Tensão (V)");
    xlabel("tempo(s)");
    
    
f3= scf(3);
    subplot(2,1,1)
    plot2d(t3(d3<60),d3(d3<60), style = color(cores(1)) );
    title('Distância lida pelo ultrassom (cm)');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(2,1,2)
    plot2d(t3,u3, style = color(cores(1)) );
    title('Tensão enviada ao motor');
    ylabel("Tensão (V)");
    xlabel("tempo(s)");
    

f4= scf(4);
    subplot(2,1,1)
    plot2d(t4(d4<60),d4(d4<60), style = color(cores(1)) );
    title('Distância lida pelo ultrassom (cm)');
    ylabel("d (cm)");
    xlabel("tempo(s)");
    
    subplot(2,1,2)
    plot2d(t4,u4, style = color(cores(1)) );
    title('Tensão enviada ao motor');
    ylabel("Tensão (V)");
    xlabel("tempo(s)");
    
