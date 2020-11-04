// Carregando a biblioteca do sensor ultrassônico

#include <Ultrasonic.h>

// Determinando os terminais de saída do sensor:
// Uso do "define" economiza a memória do Arduino, pois ele substitui o que está no "define" no código antes de compilar, sem estocar como uma variável
#define Sensor_Trigger 4        // pino conectado ao Trigger do Ultrassônico
#define Sensor_Echo 5           // pino conectado ao Echo do Ultrassônico
#define Driver_IN1 8            // pino conectado ao IN1 do Driver
#define Driver_IN2 9            // pino conectado ao IN2 do Driver
#define Driver_A 10             // pino conectado ao  A  do Driver

// Constantes usadas no código
#define PI_VALUE 3.141593       // Constante pi a ser utilizada
#define dlay 50                 // delay para cada loop do código (ms)

// Características do sinal a ser enviado ao motor
#define tciclo 1                // período do sinal senoidal enviado ao driver (s)
#define voltMax 255             // valor máximo para a senoide (máximo 255)
#define voltMin 0               // valor mínimo para a senoide (mínimo 0)

// Definição de variáveis
unsigned long microsec;
unsigned long t;                // Leitura do tempo do clock (em ms)
unsigned int velocidade = 0 ;   // Sinal senoidal enviado para o motor (int entre 0 e 255)
float w = 0;                    // Frequência angular do sinal enviado (rad/s)
  // Variáveis para o filtro
float cmMsec;                   // Leitura do sensor de ultrassom (cm)
float cmMsec_ant;               // Valor de cmMsec(k-1) usado na aplicação do filtro
bool primeira_leitura = true;   // Booleana para verificar se é a primeira leitura do sensor
float filtered_cmMsec;          // Sinal filtrado da leitura do sensor (cm)
float filtered_cmMsec_ant;      // Valor de filtered_cmMsec (k-1) usado na aplicação do filtro
const float freq_cortew = 2*PI_VALUE*10;  // Frequência de corte usada no filtro (rad/s)
const float per_amo = 0.015;    // Período de amostragem calculada na aula 5 através do SciLab (s)
const float Ce_0 = ((freq_cortew*per_amo)/2) / (1 + (freq_cortew*per_amo)/2);       // Coeficiente analítico usado no filtro
const float Ce_1 = Ce_0;        // Coeficiente analítico usado no filtro
const float Cy_1 = -(1 - (freq_cortew*per_amo)/2) / (1 + (freq_cortew*per_amo)/2);  // Coeficiente analítico usado no filtro

// Inicialização o sensor nos pinos
Ultrasonic ultrasonic(Sensor_Trigger, Sensor_Echo);

// Estados do sistema
const short sentido = 2;        // Sentido de rotação do motor (1 ou 2)
const bool movendo = true;      // Setar para True para mover o controle do Driver, False para parar o Driver


void setup()
{
  // Inicialização do Serial
  Serial.begin(9600);

  // Definição dos pinos
  //pinMode(Sensor_Trigger, INPUT);
  //pinMode(Sensor_Echo, INPUT);
  pinMode(Driver_IN1, OUTPUT);
  pinMode(Driver_IN2, OUTPUT);
  pinMode(Driver_A, OUTPUT);

  // Definindo sentido do driver
  // Sentido 1
  if (sentido == 1) {
    digitalWrite(Driver_IN1, HIGH);
    digitalWrite(Driver_IN2, LOW);
  }
  else if (sentido == 2) {
  // Sentido 2
  digitalWrite(Driver_IN1, LOW);
  digitalWrite(Driver_IN2, HIGH);
  }

  if (movendo){ 
    w = 2*PI_VALUE/(tciclo*1000); // Frequência angular do sinal (rad/s)
  }
  else {
    velocidade = 0;
    w = 0;
  }
}

void loop()
{
  // Leitura das informacoes do sensor, em cm
  t=millis();                                            // Tempo medido pelo Arduino (ms)
  
  microsec = ultrasonic.timing();
  cmMsec = ultrasonic.convert(microsec, Ultrasonic::CM); // Distância medida pelo sensor (cm)
  Serial.print(t);
  Serial.print(',');
  Serial.print(cmMsec);
  Serial.print(",");
  
  // Filtragem do sinal do sensor
  /*A equação de diferenças do filtro digital é dada por:
    y[k] = Ce_0*e[k] +Ce_1*e[k-1] - Cy_1*y[k-1]
        
    Analiticamente, pelo "Tópico 04 – Filtros Digitais", os coeficientes da aproximação bilinear
    para a função de transferência do filtro são dados por
    
    Cy_1 =  -(1 - (wc*T)/2) / (1 + (wc*T)/2);
    Ce_0 = Ce_1 = ((wc*T)/2) / (1 + (wc*T)/2);
  */
  if (primeira_leitura) {
    cmMsec_ant = cmMsec;
    filtered_cmMsec_ant = cmMsec;
  }
  
  filtered_cmMsec = Ce_0*cmMsec + Ce_1*cmMsec_ant - Cy_1*filtered_cmMsec_ant;
  cmMsec_ant = cmMsec;
  filtered_cmMsec_ant = filtered_cmMsec;
  primeira_leitura = false;
  
  // Definindo velocidade do driver
  //velocidade = (255/2)* sin(w*t) + 255/2;
  velocidade = movendo*mapfloat(sin(w*t),-1.,1.,voltMin,voltMax); // Mapeia a velocidade para valores entre 0 e 255  

  Serial.println(velocidade);

  analogWrite(Driver_A, velocidade);

  //delay(dlay);
}

int mapfloat(float x, float in_min, float in_max, int out_min, int out_max)
{
  /*
  Realiza uma interpolação linear para a variável x, (x varia entre in_min,in_max)
  Output: int com interpolação entre out_min e out_max 
   */
 return  (x - in_min)*(out_max - out_min) / (in_max - in_min) + out_min;
}
