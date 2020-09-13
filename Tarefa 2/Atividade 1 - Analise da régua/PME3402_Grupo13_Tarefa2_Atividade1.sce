/*
==============================================================
                Escola Politécnica da USP
 PME3402 - Laboratório de Medição e Controle Discreto
--------------------------------------------------------------
                  TAREFA 2 ATIVIDADE 1
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

INSTRUÇÕES PARA RODAR O PROGRAMA
Antes de rodar o programa, siga os seguintes passos
1) Certifique-se de que o Scilab está aberto na pasta "/Atividade 1 - Análise da régua/" em que o programa se encontra
2) Certifique-se de que os dados do acelerômetro estão na pasta 'Dados' dentro da pasta do programa
3) Rode o programa
*/

//LIMPEZA DE MEMÓRIA

clear;
clc;    // Limpeza de variáveis e do console
xdel(winsid()) // Fecha as janelas abertas


// ============================================================
// CARREGAMENTO DOS DADOS

// Obtendo os caminhos de cada arquivo do experimento
base_path = pwd(); // Diretório atual onde o programa está
s = filesep();     // Separador de arquivos para o OS atual ( '\' para Windows e '/' para Linux)

data_directory = base_path + s + 'Dados';


// Parâmetros
fa = 100; //[Hz] Frequência de amostragem do sensor do acelerômetro

// ============================================================
// TRATAMENTO DOS DADOS

// ============================================================
// PLOTAGEM DOS GRÁFICOS

// ============================================================
// ANÁLISE




