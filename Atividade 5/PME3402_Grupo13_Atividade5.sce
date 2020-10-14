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
2) Certifique-se de que os dados do sensor Ultrassônico estão na pasta "/Atividade 5/Processing_save_serial"
dentro da pasta do programa
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
    'Leitura_Sensor_10_14_12_38_41.csv',
];

//Ordem de chamada: csvRead(filename, separator, decimal, conversion, substitute, regexpcomments, range, header)
function [t,d,u] = data_read(data_folder,filename)
    // Obtendo os caminhos de cada arquivo do experimento
    base_path = pwd(); // Diretório atual onde o programa está
    s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)
    
    data_directory = base_path + s + data_folder;
    sensor   = csvRead(data_directory + s + filename, ',','.','double', [], [], [], 1 );
    
    t = sensor(:,1) / 1000;
    d = sensor(:,2);
    u = sensor(:,3)*5/255;
    
    // Plotagem dos gráficos individuais
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
        plot2d(t,d, style = color(cores(1)) );
        title('Distância lida pelo ultrassom (cm)');
        ylabel("d (cm)");
        xlabel("tempo(s)");
    
        subplot(2,1,2)
        plot2d(t,u, style = color(cores(1)) );
        title('Tensão enviada ao motor');
        ylabel("Tensão (V)");
        xlabel("tempo(s)");

endfunction

[t1,d1,u1] = data_read(data_folder, file_names(1));

// =============================================================================
//                         PLOTAGEM DOS GRÁFICOS
// =============================================================================
/*

cores = [
'blue4',
'deepskyblue3',
'aquamarine3',
'springgreen4',
'gold3',
'firebrick1',
'magenta3',
]

f1= scf(1);
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
/*
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
*/
