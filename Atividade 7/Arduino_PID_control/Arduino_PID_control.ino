/*
 * PME3402 - Laboratório de Medição e Controle Discreto
 * ATIVIDADE 7 - Controle digital por PID da posição de uma bola de isopor 
 * GRUPO 13
 */

// Carregando a biblioteca do sensor ultrassônico
#include <Ultrasonic.h>

// Inputs de características do sistema de Controle
// Uso do "define" economiza a memória do Arduino, pois ele substitui o que está no "define" no código antes de compilar, sem estocar como uma variável
#define ref_dist 15.0           // Posição de referência desejada para a bolinha
#define T_amost 0.023           // Período de amostragem do Arduino calculado no SciLab pela diferença entre tempos medidos (s)
#define f_c 2.5                 // Frequência de corte do filtro (Hz)
#define K_P 0.3                 // Constante proporcional do PID
#define K_I 0.0                 // Constante integrativa do PID
#define K_D 0.0                 // Constante derivativa do PID
#define max_dist 55.0           // Distância máxima da bola no tubo
#define min_dist 5.0            // Distância mínima da bola no tubo
const float error_max = - (ref_dist - max_dist);
const float error_min = - (ref_dist - min_dist);
const float PID_min = 1.1*K_P*error_min;          // Constante para o mapeamento da saída do PID entre 0 e 255
const float PID_max = 1.1*K_P*error_max;          // Constante para o mapeamento da saída do PID entre 0 e 255

//const float PID_min = -50.0;         // Constante para o mapeamento da saída do PID entre 0 e 255
//const float PID_max = 50.0; 

// Estados do sistema
const short sentido = 2;        // Sentido de rotação do motor (1 ou 2)

// Determinando os terminais de saída do sensor:
#define Sensor_Trigger 4        // pino conectado ao Trigger do Ultrassônico
#define Sensor_Echo 5           // pino conectado ao Echo do Ultrassônico
#define Driver_IN1 8            // pino conectado ao IN1 do Driver
#define Driver_IN2 9            // pino conectado ao IN2 do Driver
#define Driver_A 10             // pino conectado ao  A  do Driver

// Definição de variáveis de cálculos
unsigned long microsec;
unsigned long t;                // Leitura do tempo do clock (em ms)
unsigned int Sinal_Driver = 0 ; // Sinal enviado para o PWM do motor (int entre 0 e 255)

// Constantes usadas no código
#define PI_VALUE 3.141593       // Constante pi a ser utilizada

// Constantes para o filtro
const float freq_cortew = 2*PI_VALUE*f_c;  // Frequência de corte usada no filtro (rad/s)
const float Ce_0 = ((freq_cortew*T_amost)/2) / (1 + (freq_cortew*T_amost)/2);       // Coeficiente analítico usado no filtro
const float Ce_1 = Ce_0;                                                            // Coeficiente analítico usado no filtro
const float Cy_1 = -(1 - (freq_cortew*T_amost)/2) / (1 + (freq_cortew*T_amost)/2);  // Coeficiente analítico usado no filtro

// Constantes para o controlador PID (Método de integração 'euler-backwards')
const float K_ek    =  K_P + K_I*T_amost   +   K_D/T_amost;
const float K_ek_1  = -K_P                 - 2*K_D/T_amost;
const float K_ek_2  =                          K_D/T_amost;

// Variáveis para o filtro
float dist;                    // Leitura do sensor de ultrassom (cm)
float dist_ant;                // Valor de dist(k-1) usado na aplicação do filtro
bool primeira_leitura = true;  // Booleana para verificar se é a primeira leitura do sensor
float filtered_dist;           // Sinal filtrado da leitura do sensor (cm)
float filtered_dist_ant;       // Valor de filtered_dist (k-1) usado na aplicação do filtro

// Variáveis para o controlador PID
bool segunda_leitura = true;   // Booleana para verificar se é a segunda leitura do sensor
float PID_out = 0.0;           // É a variável u[k], da saída do controlador PID
float error = 0.0;             // É a variável e[k], de diferença entre a referência e a entrada
float error_K_1 = 0.0;         // É a variável e[k-1] do período anterior
float error_K_2 = 0.0;         // É a variável e[k-2] do período anterior ao anterior


// Inicialização o sensor nos pinos
Ultrasonic ultrasonic(Sensor_Trigger, Sensor_Echo);

// Início do programa
void setup()
{
  // Inicialização do Serial
  Serial.begin(9600);

  // Definição dos pinos
  pinMode(Driver_IN1, OUTPUT);
  pinMode(Driver_IN2, OUTPUT);
  pinMode(Driver_A, OUTPUT);

  // Definindo sentido do driver
  if (sentido == 1) {
  // Sentido 1
    digitalWrite(Driver_IN1, HIGH);
    digitalWrite(Driver_IN2, LOW);
  }
  else if (sentido == 2) {
  // Sentido 2
    digitalWrite(Driver_IN1, LOW);
    digitalWrite(Driver_IN2, HIGH);
  }

  // Armazenando os dados iniciais para o início dos cáclulos com as variáveis de k-1 e k-2
  /*
  while (segunda_leitura){
    
    //Primeira leitura do sensor para armazenamento das variáveis de k-2
    while (primeira_leitura) { 
      microsec = ultrasonic.timing();
      dist = ultrasonic.convert(microsec, Ultrasonic::CM);
      error_K_2 = -(ref_dist - dist);
      primeira_leitura = false;
    }

    // Segunda leitura do sensor para armazenamento das variáveis em k-1
    microsec = ultrasonic.timing();
    dist_ant = ultrasonic.convert(microsec, Ultrasonic::CM);
    filtered_dist_ant = dist_ant;
    error_K_1 = -(ref_dist - dist);
    segunda_leitura = false;
  }
  */
}

void loop()
{
  // Leitura das informacoes do sensor, em cm
  t=millis();                                          // Tempo medido pelo Arduino (ms)
  
  microsec = ultrasonic.timing();
  dist = ultrasonic.convert(microsec, Ultrasonic::CM); // Distância medida pelo sensor (cm)
  //Serial.print(t);
  //Serial.print(',');
  Serial.print(dist);
  Serial.print(",");
  
  // Filtragem do sinal do sensor
  /*A equação de diferenças do filtro digital é dada por:
    y[k] = Ce_0*e[k] +Ce_1*e[k-1] - Cy_1*y[k-1]
        
    Analiticamente, pelo "Tópico 04 – Filtros Digitais", os coeficientes da aproximação bilinear
    para a função de transferência do filtro são dados por
    
    Cy_1 =  -(1 - (wc*T)/2) / (1 + (wc*T)/2);
    Ce_0 = Ce_1 = ((wc*T)/2) / (1 + (wc*T)/2);
  */
  
  filtered_dist = Ce_0*dist + Ce_1*dist_ant - Cy_1*filtered_dist_ant;
  Serial.print(filtered_dist);
  Serial.print(",");


  // Controlador PID
  /*  Segundo a apostila 6 da disciplina, a equação de diferenças de um controlador PID
      com métodode de integração Euler-backwards, resulta na seguinte equação de diferenças:
          u(k) = u(k-1)+ Kek*e(k)+ Kek_1*e(k-1)+ Kek_2*e(k-2)
      Os coeficientes são dados por:
          Kek    =  Kp + Ki*Ta   +   Kd/Ta;
          Kek_1  = -Kp           - 2*Kd/Ta
          Kek_2  =                   Kd/Ta;
  */
  // Usando o sinal de erro invertido, pois o sensor encontra-se num referêncial oposto ao do motor
  // Logo, deseja-se que um sinal medido maior do que o de referência aumente a ação do motor
  error = - (ref_dist - filtered_dist); 

  
  PID_out = ( PID_out + K_ek*error + K_ek_1*error_K_1 + K_ek_2*error_K_2 );

  // Enviando o sinal de saída do PID ao Driver
  //PID_min = min(PID_min, PID_out);
  //PID_max = max(PID_max, PID_out);
  
  Sinal_Driver = mapFloat(PID_out, PID_min, PID_max , 0.0 ,255.0);
  
  analogWrite(Driver_A, Sinal_Driver);


  Serial.print(Sinal_Driver);
  Serial.print(",");

  Serial.print(PID_min);
  Serial.print(",");

  Serial.print(PID_max);
  Serial.print(",");

  Serial.println(PID_out);
  
  // Atualizando os valores da medição antiga
  dist_ant = dist;
  filtered_dist_ant = filtered_dist;
  error_K_2 = error_K_1;
  error_K_1 = error;
}


int mapFloat(float x, float in_min, float in_max, float out_min, float out_max)
{
  x = constrain(x, in_min, in_max); // Satura o valor de x entre in_min e in_max
  float mapping = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min; // Mapeamento linear entre in e out
  return round(mapping); // Arredonda o cálculo para o número inteiro mais próximo
}
