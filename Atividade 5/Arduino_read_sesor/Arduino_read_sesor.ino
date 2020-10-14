// Carregando a biblioteca do sensor ultrassônico

#include <Ultrasonic.h>

// Determinando os terminais de saída do sensor:

#define Sensor_Trigger 4 // pino conectado ao Trigger do Ultrassônico
#define Sensor_Echo 5    // pino conectado ao Echo do Ultrassônico
#define Driver_IN1 8     // pino conectado ao IN1 do Driver
#define Driver_IN2 9     // pino conectado ao IN2 do Driver
#define Driver_A 10      // pino conectado ao  A  do Driver

// Constantes usadas no código ("#define" economiza memória do Arduino)
#define PI_VALUE 3.14159265358979 //Constante pi a ser utilizada
#define dlay 50                   //delay para cada loop do código (ms)
#define tciclo 2                  // período do sinal senoidal para a velocidade do driver (s)

// Definição de variáveis
float cmMsec;
unsigned long microsec;
unsigned long t;         // Leitura do tempo do clock
unsigned int velocidade = 0 ;   // Sinal senoidal da velocidade (int entre 0 e 255)
float w = 0;             // // Frequência angular do sinal enviado (rad/s)

// Inicialização o sensor nos pinos
Ultrasonic ultrasonic(Sensor_Trigger, Sensor_Echo);

// Estados do sistema
unsigned short sentido = 2; // Sentido de rotação do motor (1 ou 2)
bool parado = false;         // Setar para True para parar o controle do Driver


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

  if (! parado){ 
    w = 2*PI_VALUE/(tciclo*1000); // Frequência angular do sinal (rad/s)
  }
}

void loop()
{
  // Leitura as informacoes do sensor, em cm
  t=millis();

  microsec = ultrasonic.timing();
  cmMsec = ultrasonic.convert(microsec, Ultrasonic::CM);
  
  // Exibindo informacoes no Serial monitor
  Serial.print(t);
  Serial.print(',');
  Serial.print(cmMsec);
  Serial.print(',');
  
  // Controle do driver
  // Definindo velocidade do driver
  if (parado){ // Parado
    velocidade = 0;
  }
  else {
    //velocidade = sin(w*t);
    //velocidadePWM = map(velocidade,-1,1,0,255);
    velocidade = (255/2)* sin(w*t) + 255/2;
  }
  Serial.print(",");
  Serial.println(velocidade);
  
  analogWrite(Driver_A, velocidade);

  delay(dlay);
}
