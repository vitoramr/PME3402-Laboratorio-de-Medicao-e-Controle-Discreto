/*
==============================================================
                Escola Politécnica da USP
 PME3402 - Laboratório de Medição e Controle Discreto
--------------------------------------------------------------
                   TAREFA 2 ATIVIDADE 2
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
// INICIALIZAÇÃO DE VARIÁVEIS E PARÂMETROS

/* 
Para armazenar os valores dos arquivos de som, como tinhamos muitos áudios,
seria inefetivo criar uma variável para cada áudio, além do fato de dificultar
a análise adicionando mais audios.

Assim, concatenamos os arquivos de som em seus respectivos vetores. Contudo,
como cada arquivo de som tem diferentes tamanhos, ou número de elementos,
o concatenamento direto não era possível.

Para contornar isso, analisamos os espectros de frequência dos sinais e
verificamos que os áudios tinham valores baixos em suas frequências para um número
de elementos alto, e decidimos fixar o número de elementos da fft armazenados para
cada dado.

Porém, como a escala de frequência de cada transformada de Fourier depende do 
número de elementos do vetor original, também criamos uma variável para armazenar
este número de elementos
*/

fa = 44100; //[Hz] Frequência de amostragem dos microfones
N_elementos = 1000;


// Vetores para armazenares os valores das FFTs dos audios obtidos
a_aberto = [];  // Tamanho: m_audios x N_elementos
a_fechado = []; // Tamanho: m_audios x N_elementos
e_aberto = [];  // Tamanho: m_audios x N_elementos
e_fechado = []; // Tamanho: m_audios x N_elementos
i_aberto = [];  // Tamanho: m_audios x N_elementos
o_aberto = [];  // Tamanho: m_audios x N_elementos
o_fechado = []; // Tamanho: m_audios x N_elementos

//Estocagem da escala de frequências de cada arquivo de som
f_a_aberto = [];
f_a_fechado = [];
f_e_aberto = [];
f_e_fechado = [];
f_i_aberto = [];
f_o_aberto = [];
f_o_fechado = [];

// ============================================================
// CARREGAMENTO E TRATAMENTO DOS DADOS

// Obtendo os caminhos de cada arquivo de som

base_path = pwd(); // Diretório atual onde o programa está
s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)

data_directory = base_path + s + 'Dados'

// Lista do caminho da cada arquivo de som
a_aberto_filespath = listfiles(data_directory + s + '*a.wav')  // Lista de todos os arquivos com fim 'a.wav'
a_fechado_filespath = listfiles(data_directory + s + '*â.wav') // Lista de todos os arquivos com fim 'â.wav'
e_aberto_filespath = listfiles(data_directory + s + '*é.wav')  // Lista de todos os arquivos com fim 'é.wav'
e_fechado_filespath = listfiles(data_directory + s + '*ê.wav') // Lista de todos os arquivos com fim 'ê.wav'
i_aberto_filespath = listfiles(data_directory + s + '*i.wav')  // Lista de todos os arquivos com fim 'i.wav'
o_aberto_filespath = listfiles(data_directory + s + '*ó.wav')  // Lista de todos os arquivos com fim 'ó.wav'
o_fechado_filespath = listfiles(data_directory + s + '*ô.wav') // Lista de todos os arquivos com fim 'ô.wav'

// Tratamento dos dados e concatenamento dos arquivos de som nos seus respectivos vetores
for i = 1:size(a_aberto_filespath,1)
    [audio_t, fs] = wavread(a_aberto_filespath(i));      // Leitura do arquivo de áudio e da sua frequência de amostragem
    N = length(audio_t);                                 // Número de elementos do arquivo
    audio_f = fft(audio_t,-1);                           // FFT do sinal temporal
    pot_audio_f = ( 1.0/(fs*N) ) * (abs(audio_f) ).^2 ;  // Potência espectral do sinal
    a_aberto = [a_aberto;
                pot_audio_f(1:N_elementos)];             // Para possibilitar o concatenamento, pega-se apenas os primeiros N_elementos da PSD
    f_a_aberto = [f_a_aberto;
                  (fs/N)*(0:N_elementos-1)];             // Armazena-se também a escala de frequência do sinal, até o tamanho N_elementos
end

// Aplicando o mesmo tratamento para os demais arquivos de áudio
for i = 1:size(a_fechado_filespath,1)
    [audio_t, fs] = wavread(a_fechado_filespath(i));
    N = length(audio_t);
    audio_f = fft(audio_t,-1);
    pot_audio_f = ( 1.0/(fs*N) ) * (abs(audio_f) ).^2 ;
    a_fechado = [a_fechado;
                pot_audio_f(1:N_elementos)];
    f_a_fechado = [f_a_fechado;
                  (fs/N)*(0:N_elementos-1)];
end

for i = 1:size(e_aberto_filespath,1)
    [audio_t, fs] = wavread(e_aberto_filespath(i));
    N = length(audio_t);
    audio_f = fft(audio_t,-1);
    pot_audio_f = ( 1.0/(fs*N) ) * (abs(audio_f) ).^2 ;
    e_aberto = [e_aberto;
                pot_audio_f(1:N_elementos)];
    f_e_aberto = [f_e_aberto;
                  (fs/N)*(0:N_elementos-1)];
end

for i = 1:size(e_fechado_filespath,1)
    [audio_t, fs] = wavread(e_fechado_filespath(i));
    N = length(audio_t)
    audio_f = fft(audio_t,-1);
    pot_audio_f = ( 1.0/(fs*N) ) * (abs(audio_f) ).^2 ;
    e_fechado = [e_fechado;
                pot_audio_f(1:N_elementos)];
    f_e_fechado = [f_e_fechado;
                  (fs/N)*(0:N_elementos-1)];
end

for i = 1:size(i_aberto_filespath,1)
    [audio_t, fs] = wavread(i_aberto_filespath(i));
    N = length(audio_t)
    audio_f = fft(audio_t,-1);
    pot_audio_f = ( 1.0/(fs*N) ) * (abs(audio_f) ).^2 ;
    i_aberto = [i_aberto;
                pot_audio_f(1:N_elementos)];
    f_i_aberto = [f_i_aberto;
                  (fs/N)*(0:N_elementos-1)];
end

for i = 1:size(o_aberto_filespath,1)
    [audio_t, fs] = wavread(o_aberto_filespath(i));
    N = length(audio_t);
    audio_f = fft(audio_t,-1);
    pot_audio_f = ( 1.0/(fs*N) ) * (abs(audio_f) ).^2 ;
    o_aberto = [o_aberto;
                pot_audio_f(1:N_elementos)];
    f_o_aberto = [f_o_aberto;
                  (fs/N)*(0:N_elementos-1)];
end

for i = 1:size(o_fechado_filespath,1)
    [audio_t, fs] = wavread(o_fechado_filespath(i));
    N = length(audio_t);
    audio_f = fft(audio_t,-1);
    pot_audio_f = ( 1.0/(fs*N) ) * (abs(audio_f) ).^2 ;
    o_fechado = [o_fechado;
                pot_audio_f(1:N_elementos)];
    f_o_fechado = [f_o_fechado;
                  (fs/N)*(0:N_elementos-1)];
end


// ============================================================
// PLOTAGEM DOS GRÁFICOS

fig1 = scf(1);
    fig1.color_map = rainbowcolormap(20);
    
    subplot(3,2,1)
    xtitle('Densidade espectral dos áudios para a vogal: A (aberto)' , 'f (Hz)','PSD');
    for i = 1:size(a_aberto,1)
        plot(f_a_aberto(i,:),a_aberto(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    
    subplot(3,2,2)
    xtitle('Densidade espectral dos áudios para a vogal: A (fechado)' , 'f (Hz)','PSD');
    for i = 1:size(a_fechado,1)
        plot(f_a_fechado(i,:),a_fechado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    
    subplot(3,2,3)
    xtitle('Densidade espectral dos áudios para a vogal: É (aberto)' , 'f (Hz)','PSD');
    for i = 1:size(e_aberto,1)
        plot(f_e_aberto(i,:),e_aberto(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    
    subplot(3,2,4)
    xtitle('Densidade espectral dos áudios para a vogal: Ê (fechado)' , 'f (Hz)','PSD');
    for i = 1:size(e_fechado,1)
        plot(f_e_fechado(i,:),e_fechado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    
    subplot(3,2,5)
    xtitle('Densidade espectral dos áudios para a vogal: Ó (aberto)' , 'f (Hz)','PSD');
    for i = 1:size(o_aberto,1)
        plot(f_o_aberto(i,:),o_aberto(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    
    subplot(3,2,6)
    xtitle('Densidade espectral dos áudios para a vogal: Ô (fechado)' , 'f (Hz)','PSD');
    for i = 1:size(o_fechado,1)
        plot(f_o_fechado(i,:),o_fechado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end

/*
    subplot(3,2,2)
    plot( f2(1:N_f/2) , pot_pulso1(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura II.1-2: Densidade de potência do sinal à esquerda', 'f (Hz)','PSD');
    
    subplot(3,2,3)
    plot(t2,y5_t_2);        //Visualizar o sinal de (5)
    xtitle('Figura II.2-1: Sinal periódico de frequência '+ string(f5_2) + 'Hz e fase ' + string(phi5_2) +' rad.' , 't (s)','s (t)');
    
    subplot(3,2,4)
    plot( f2(1:N_f/2) , pot_y5_2(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura II.2-2: Densidade de potência do sinal à esquerda', 'f (Hz)','PSD');

    subplot(3,2,5)
    plot(t2,y8_t_2);        //Visualizar o sinal de (5)
    xtitle('Figura II.3-1: Sinal periódico aplicado à janela entre  t = '+ string(ti_p1) + 's e t = ' + string(ti_p1 + dt_p1) +'s.' , 't (s)','s (t)');
    
    subplot(3,2,6)
    plot( f2(1:N_f/2) , pot_y8_2(1:N_f/2) ); // Como o sinal é real, a FFT é simétrica, e retemos apenas os N/2 primeiros elementos
    xtitle('Figura II.3-2: Densidade de potência do sinal à esquerda', 'f (Hz)','PSD');
*/

// ============================================================
// ANÁLISE DOS RESULTADOS


/*
Quanto mais baixa a frequência, mais grave é o som.
A faixa de voz masculina costuma variar entre 80 Hz e 150 Hz, sendo a média da
frequência da voz dos homens adultos brasileiros é de 113 Hz. A faixa feminina
varia entre 150 Hz e 250 Hz
*/

f_max = 350;    //Máxima frequência para a plotagem




