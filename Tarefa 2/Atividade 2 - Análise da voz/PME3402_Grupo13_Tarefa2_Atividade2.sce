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
N_elementos = 800;


// Vetores para armazenar os valores das FFTs dos audios obtidos
a_aberto = [];  // Tamanho: m_audios x N_elementos
a_fechado = []; // Tamanho: m_audios x N_elementos
e_aberto = [];  // Tamanho: m_audios x N_elementos
e_fechado = []; // Tamanho: m_audios x N_elementos
i_aberto = [];  // Tamanho: m_audios x N_elementos
o_aberto = [];  // Tamanho: m_audios x N_elementos
o_fechado = []; // Tamanho: m_audios x N_elementos

// Vetores para armazenar os valores das PSDs dos audios obtidos
a_aberto_pot = [];  // Tamanho: m_audios x N_elementos
a_fechado_pot = []; // Tamanho: m_audios x N_elementos
e_aberto_pot = [];  // Tamanho: m_audios x N_elementos
e_fechado_pot = []; // Tamanho: m_audios x N_elementos
i_aberto_pot = [];  // Tamanho: m_audios x N_elementos
o_aberto_pot = [];  // Tamanho: m_audios x N_elementos
o_fechado_pot = []; // Tamanho: m_audios x N_elementos

//Estocagem da escala de frequências de cada arquivo de som
f_a_aberto = [];
f_a_fechado = [];
f_e_aberto = [];
f_e_fechado = [];
f_i_aberto = [];
f_o_aberto = [];
f_o_fechado = [];

// ============================================================
// OBTENÇÂO DOS DADOS

// Obtendo os caminhos de cada arquivo de som

base_path = pwd(); // Diretório atual onde o programa está
s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)

data_directory = base_path + s + 'Dados';

// Lista do caminho da cada arquivo de som
a_aberto_filespath =  listfiles(data_directory + s + '*A.wav');  // Lista de todos os arquivos com fim 'A.wav'
a_fechado_filespath = listfiles(data_directory + s + '*Â.wav');  // Lista de todos os arquivos com fim 'Â.wav'
e_aberto_filespath =  listfiles(data_directory + s + '*É.wav');  // Lista de todos os arquivos com fim 'É.wav'
e_fechado_filespath = listfiles(data_directory + s + '*Ê.wav');  // Lista de todos os arquivos com fim 'Ê.wav'
i_aberto_filespath =  listfiles(data_directory + s + '*I.wav');  // Lista de todos os arquivos com fim 'I.wav'
o_aberto_filespath =  listfiles(data_directory + s + '*Ó.wav');  // Lista de todos os arquivos com fim 'Ó.wav'
o_fechado_filespath = listfiles(data_directory + s + '*Ô.wav');  // Lista de todos os arquivos com fim 'Ô.wav'

// Tratamento dos dados e concatenamento dos arquivos de som nos seus respectivos vetores

function [audio_fft, audio_psd, freq_audio] = leitura_audios(nomes_dos_arquivos)
    /*
    Recebe uma lista com os nomes dos arquivos que contêm os áudios em .wav
    Lê esses arquivos armazenando em matrizes os N_elementos primeiros valores da:
    FFT, PSD e Vetor de frequências do áudio 
    */
    audio_fft = [];
    audio_psd = [];
    freq_audio = [];
    
    for i = 1:size(nomes_dos_arquivos,1)
        [audio_t, fs] = wavread(nomes_dos_arquivos(i));      // Leitura do arquivo de áudio e da sua frequência de amostragem
        N = size(audio_t,2);                                 // Número de elementos do arquivo
        audio_f = fft(audio_t(1,:),-1);                      // FFT do sinal temporal
        pot_audio_f = ( 1.0/(fs*N) ) * (abs(audio_f) ).^2 ;  // Potência espectral do sinal
        audio_fft = [audio_fft;
                     abs(audio_f(1:N_elementos))];           // Para possibilitar o concatenamento, pega-se apenas os primeiros N_elementos da FFT
        audio_psd = [audio_psd;
                     pot_audio_f(1:N_elementos)];            // Armazenamento da PSD do sinal
        freq_audio = [freq_audio;
                     (fs/N)*(0:N_elementos-1) ];             // Armazena-se também a escala de frequência do sinal, até o tamanho N_elementos
    end

endfunction

[a_aberto , a_aberto_pot , f_a_aberto ] = leitura_audios(a_aberto_filespath);
[a_fechado, a_fechado_pot, f_a_fechado] = leitura_audios(a_fechado_filespath);
[e_aberto , e_aberto_pot , f_e_aberto ] = leitura_audios(e_aberto_filespath);
[e_fechado, e_fechado_pot, f_e_fechado] = leitura_audios(e_fechado_filespath);
[i_aberto , i_aberto_pot , f_i_aberto ] = leitura_audios(i_aberto_filespath);
[o_aberto , o_aberto_pot , f_o_aberto ] = leitura_audios(o_aberto_filespath);
[o_fechado, o_fechado_pot, f_o_fechado] = leitura_audios(o_fechado_filespath);


// ============================================================
// TRATAMENTO DOS DADOS

// Plot de cada sinal de áudio individualmente
// A Aberto
fig1 = scf(1);
    fig1.color_map = rainbowcolormap(size(a_aberto,1));
    for i = 1:size(a_aberto,1)
        subplot(2,2,i)
        plot(f_a_aberto(i,:),a_aberto(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
        title('Figura 1: Espectro de frequências de cada áudio para a vogal A (aberta)')
        xlabel('f (Hz)');
        ylabel('PSD');
    end

/*
Como é visível na figura 1, os audios possuem amplitudes muito distintas. Isso
ocorre, pois os áudio provêm de diferentes fontes, já que cada celular possui
sensores diferentes com arquiteturas diferentes e cada pessoa gravação possui
volumes diferentes.

Dessa forma, como o interesse é comparar os áudios para identificar as diferentes
frequências de cada vogal, faz-se necessária a normalização dos valores obtidos.
Isso é feito dividindo o valor de cada áudio pela sua norma em L2 para que todos
os áudios adquiram norma igual a 1.

Além disso, utilizaremos na comparação os valores da PSD normalizados, pois estas
mostraram-se distinguir melhor as frequências que mais influenciam no áudio 
*/

function matriz_normalizada = normaliza_audios(matriz_de_audio)
    /*
    Normaliza as linhas de uma matriz dividindo seus valores pela norma em L2 de sua respectiva linha
    */
    
    matriz_normalizada  = zeros(matriz_de_audio);
    for i = 1:size(matriz_de_audio,1); //Para cada áudio que o possui
        norma = norm(matriz_de_audio(i,:)); // Calcula a norma da linha
        matriz_normalizada(i,:) = matriz_de_audio(i,:)./norma; //Dividindo cada valor do da linha por sua norma
    end
endfunction

// Normalização dos vetores
// Inicializando os vetores normalizados como vetores de zeros 
a_aberto_normalizado  = normaliza_audios(a_aberto_pot) ;
a_fechado_normalizado = normaliza_audios(a_fechado_pot);
e_aberto_normalizado  = normaliza_audios(e_aberto_pot) ;
e_fechado_normalizado = normaliza_audios(e_fechado_pot);
i_aberto_normalizado  = normaliza_audios(i_aberto_pot) ;
o_aberto_normalizado  = normaliza_audios(o_aberto_pot) ;
o_fechado_normalizado = normaliza_audios(o_fechado_pot);

// ============================================================
// PLOTAGEM DOS GRÁFICOS
// Análise geral das vogais
fig2 = scf(2);
    fig2.color_map = rainbowcolormap(size(a_aberto,1));
    
    subplot(4,2,1)
    xtitle('Figura 2.1: Densidade de frequência normalizada dos áudios para a vogal: A (aberto)' , 'f (Hz)','PSD normalizada');
    for i = 1:size(a_aberto_normalizado,1)
        plot(f_a_aberto(i,:),a_aberto_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    legend(['Vítor', 'Vitória','Vinicius'])
    
    subplot(4,2,2)
    xtitle('Figura 2.2: Densidade de frequência normalizada dos áudios para a vogal: A (fechado)' , 'f (Hz)','PSD normalizada');
    for i = 1:size(a_fechado,1)
        plot(f_a_fechado(i,:),a_fechado_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    
    subplot(4,2,3)
    xtitle('Figura 2.3: Densidade de frequência normalizada dos áudios para a vogal: É (aberto)' , 'f (Hz)','PSD normalizada');
    for i = 1:size(e_aberto,1)
        plot(f_e_aberto(i,:),e_aberto_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    
    subplot(4,2,4)
    xtitle('Figura 2.4: Densidade de frequência normalizada dos áudios para a vogal: Ê (fechado)' , 'f (Hz)','PSD normalizada');
    for i = 1:size(e_fechado,1)
        plot(f_e_fechado(i,:),e_fechado_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    
    subplot(4,2,5)
    xtitle(' Figura 2.5: Densidade de frequência normalizada dos áudios para a vogal: Ó (aberto)' , 'f (Hz)','PSD normalizada');
    for i = 1:size(o_aberto,1)
        plot(f_o_aberto(i,:),o_aberto_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    
    subplot(4,2,6)
    xtitle('Figura 2.6: Densidade de frequência normalizada dos áudios para a vogal: Ô (fechado)' , 'f (Hz)','PSD normalizada');
    for i = 1:size(o_fechado,1)
        plot(f_o_fechado(i,:),o_fechado_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
    
    subplot(4,2,7)
    xtitle('Figura 2.7: Densidade de frequência normalizada dos áudios para a vogal: Ô (fechado)' , 'f (Hz)','PSD normalizada');
    for i = 1:size(i_aberto,1)
        plot(f_i_aberto(i,:),i_aberto_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end


// Análise específica das vogais
// A aberto normalizado
fig3 = scf(3);
    fig3.color_map = rainbowcolormap(size(a_aberto,1));
    for i = 1:size(a_aberto_normalizado,1)
        subplot(2,2,i)
        xtitle('Figura 3: PSD normalizada de cada audio para a Vogal: A (aberto)' , 'f (Hz)','PSD normalizada');
        plot(f_a_aberto(i,:),a_aberto_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end

// A fechado normalizado
fig4 = scf(4);
    fig4.color_map = rainbowcolormap(size(a_fechado,1));
    for i = 1:size(a_fechado_normalizado,1)
        subplot(2,2,i)
        xtitle('Figura 4: PSD normalizada de cada audio para a Vogal: A (fechado)' , 'f (Hz)','PSD normalizada');
        plot(f_a_fechado(i,:),a_fechado_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end

// E aberto normalizado
fig5 = scf(5);
    fig5.color_map = rainbowcolormap(size(e_aberto,1));
    for i = 1:size(e_aberto_normalizado,1)
        subplot(2,2,i)
        xtitle('Figura 5: PSD normalizada de cada audio para a Vogal: E (aberto)' , 'f (Hz)','PSD normalizada');
        plot(f_e_aberto(i,:),e_aberto_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
// E fechado normalizado
fig6 = scf(6);
    fig6.color_map = rainbowcolormap(size(e_fechado,1));
    for i = 1:size(e_fechado_normalizado,1)
        subplot(2,2,i)
        xtitle('Figura 6: PSD normalizada de cada audio para a Vogal: E (fechado)' , 'f (Hz)','PSD normalizada');
        plot(f_e_fechado(i,:),e_fechado_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end


// I normalizado
fig7 = scf(5);
    fig5.color_map = rainbowcolormap(size(i_aberto,1));
    for i = 1:size(i_aberto_normalizado,1)
        subplot(2,2,i)
        xtitle('Figura 7: PSD normalizada de cada audio para a Vogal: I' , 'f (Hz)','PSD normalizada');
        plot(f_i_aberto(i,:),i_aberto_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end
// O aberto normalizado
fig8 = scf(8);
    fig8.color_map = rainbowcolormap(size(o_aberto,1));
    for i = 1:size(o_aberto_normalizado,1)
        subplot(2,2,i)
        xtitle('Figura 8: PSD normalizada de cada audio para a Vogal: O (aberto)' , 'f (Hz)','PSD normalizada');
        plot(f_o_aberto(i,:),o_aberto_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end


// O fechado normalizado
fig9 = scf(9);
    fig9.color_map = rainbowcolormap(size(o_fechado,1));
    for i = 1:size(o_fechado_normalizado,1)
        subplot(2,2,i)
        xtitle('Figura 9: PSD normalizada de cada audio para a Vogal: O (fechado)' , 'f (Hz)','PSD normalizada');
        plot(f_o_fechado(i,:),o_fechado_normalizado(i,:));
        plot_propriedades = gce();
        plot_propriedades.children.foreground = i; // Mudando as cores a cada elemento
    end

// ============================================================
// ANÁLISE DOS RESULTADOS


/*
Quanto mais baixa a frequência, mais grave é o som.
A faixa de voz masculina costuma variar entre 80 Hz e 150 Hz, sendo a média da
frequência da voz dos homens adultos brasileiros é de 113 Hz. A faixa feminina
varia entre 150 Hz e 250 Hz
*/




