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
N_elementos = 4000;


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
// CARREGAMENTO DOS DADOS

// Obtendo os caminhos de cada arquivo de som

base_path = pwd(); // Diretório atual onde o programa está
s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)

data_directory = base_path + s + 'Dados'

// Lista do caminho da cada arquivo de som
a_aberto_filespath = listfiles(data_directory + s + '*a.wav') // Pesquisa todos os arquivos com fim 'a.wav'
a_fechado_filespath = listfiles(data_directory + s + '*â.wav') // Pesquisa todos os arquivos com fim 'â.wav'
e_aberto_filespath = listfiles(data_directory + s + '*é.wav') // Pesquisa todos os arquivos com fim 'é.wav'
e_fechado_filespath = listfiles(data_directory + s + '*ê.wav') // Pesquisa todos os arquivos com fim 'ê.wav'
i_aberto_filespath = listfiles(data_directory + s + '*i.wav') // Pesquisa todos os arquivos com fim 'i.wav'
o_aberto_filespath = listfiles(data_directory + s + '*ó.wav') // Pesquisa todos os arquivos com fim 'ó.wav'
o_fechado_filespath = listfiles(data_directory + s + '*ô.wav') // Pesquisa todos os arquivos com fim 'ô.wav'

// Concatenamento dos arquivos de som nos seus respectivos vetores
for i = 1:size(a_aberto_filespath,1)
    [audio_t, fs] = wavread(a_aberto_filespath(i)); // Leitura do arquivo de áudio e da sua frequência de amostragem
    N = length(audio_t)
    audio_f = fft(audio_t,-1);                // FFT no sinal temporal
    a_aberto = [a_aberto;
                audio_f(1:N_elementos)];      // Para possibilitar o concatenamento, pega-se apenas os primeiros N_elementos da FFT
    f_a_aberto = [f_a_aberto;
                  (fs/N)*(0:N_elementos-1)];    // Armazena-se também a escala de frequência de tamanho N_elementos
end

for i = 1:size(a_fechado_filespath,1)
    [audio_t, fs] = wavread(a_fechado_filespath(i));
    N = length(audio_t)
    audio_f = fft(audio_t,-1);
    a_fechado = [a_fechado;
                audio_f(1:N_elementos)];  // Para possibilitar o concatenamento, pega-se apenas os primeiros N_elementos da FFT
    f_a_fechado = [f_a_fechado;
                  (fs/N)*(0:N_elementos-1)];    // Armazena-se também a escala de frequência de tamanho N_elementos
end

for i = 1:size(e_aberto_filespath,1)
    [audio_t, fs] = wavread(e_aberto_filespath(i));
    N = length(audio_t)
    audio_f = fft(audio_t,-1);
    e_aberto = [e_aberto;
                audio_f(1:N_elementos)];  // Para possibilitar o concatenamento, pega-se apenas os primeiros N_elementos da FFT
    f_e_aberto = [f_e_aberto;
                  (fs/N)*(0:N_elementos-1)];    // Armazena-se também a escala de frequência de tamanho N_elementos
end

for i = 1:size(e_fechado_filespath,1)
    [audio_t, fs] = wavread(e_fechado_filespath(i));
    N = length(audio_t)
    audio_f = fft(audio_t,-1);
    e_fechado = [e_fechado;
                audio_f(1:N_elementos)];  // Para possibilitar o concatenamento, pega-se apenas os primeiros N_elementos da FFT
    f_e_fechado = [f_e_fechado;
                  (fs/N)*(0:N_elementos-1)];    // Armazena-se também a escala de frequência de tamanho N_elementos
end

for i = 1:size(i_aberto_filespath,1)
    [audio_t, fs] = wavread(i_aberto_filespath(i));
    N = length(audio_t)
    audio_f = fft(audio_t,-1);
    i_aberto = [i_aberto;
                audio_f(1:N_elementos)];  // Para possibilitar o concatenamento, pega-se apenas os primeiros N_elementos da FFT
    f_i_aberto = [f_i_aberto;
                  (fs/N)*(0:N_elementos-1)];    // Armazena-se também a escala de frequência de tamanho N_elementos
end

for i = 1:size(o_aberto_filespath,1)
    [audio_t, fs] = wavread(o_aberto_filespath(i));
    N = length(audio_t)
    audio_f = fft(audio_t,-1);
    o_aberto = [o_aberto;
                audio_f(1:N_elementos)];  // Para possibilitar o concatenamento, pega-se apenas os primeiros N_elementos da FFT
    f_o_aberto = [f_o_aberto;
                  (fs/N)*(0:N_elementos-1)];    // Armazena-se também a escala de frequência de tamanho N_elementos
end

for i = 1:size(o_fechado_filespath,1)
    [audio_t, fs] = wavread(o_fechado_filespath(i));
    N = length(audio_t)
    audio_f = fft(audio_t,-1);
    o_fechado = [o_fechado;
                audio_f(1:N_elementos)];  // Para possibilitar o concatenamento, pega-se apenas os primeiros N_elementos da FFT
    f_o_fechado = [f_o_fechado;
                  (fs/N)*(0:N_elementos-1)];    // Armazena-se também a escala de frequência de tamanho N_elementos
end

// ============================================================
// TRATAMENTO DOS DADOS

//(MUDAR) Cópia do programa 1

// Encontrando a escala da frequência
//N_f = size(pulso1_f,'*')             //Tamanho do vetor de frequências
//sample_rate2 = 1.0/(dt2);          //[Hz] Escala horizontal da DFT

//f2 = (sample_rate2/N) * (0:(N_f-1));     //[Hz] Escala horizontal das frequências da DFT

// Densidade de potência do sinal

// A densidade de potência de um sinal é proporcional ao produto da sua DFT com seu conjugado complexo
//pot_pulso1 = (dt2 / N_f) * ( abs(pulso1_f) ).^2 ;


//f_max = 300; // Máxima frequência para plotagem
//analyze(a_aberto(1));



// ============================================================
// PLOTAGEM DOS GRÁFICOS

// ============================================================
// ANÁLISE DOS RESULTADOS


/*
Quanto mais baixa a frequência, mais grave é o som.
A faixa de voz masculina costuma variar entre 80 Hz e 150 Hz, sendo a média da
frequência da voz dos homens adultos brasileiros é de 113 Hz. A faixa feminina
varia entre 150 Hz e 250 Hz
*/

f_max = 350;    //Máxima frequência para a plotagem




