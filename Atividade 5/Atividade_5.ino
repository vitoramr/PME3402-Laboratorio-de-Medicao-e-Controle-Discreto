// Carregando a biblioteca do sensor ultrassônico

#include <Ultrasonic.h>

// Determinando os terminais de saída do sensor:

#define Sensor_Trigger 4;
#define Sensor_Echo 5;
#define Driver_IN1 8;
#define Driver_IN2 9;
#define Driver_A 10;

// Definindo parâmetros

const int dlay = 30; //delay para cada loop do código
const int tciclo = 1; //tempo do ciclo senoidal para a velocidade do driver (s)
const float pi =  3.14159265358979;

// Inicializa o sensor nos pinos

Ultrasonic ultrasonic(Sensor_Trigger, Sensor_Echo);

void setup()
{
 Serial.begin(9600);
 pinMode(Sensor_Trigger, INPUT);
 pinMode(Sensor_Echo, INPUT);
 pinMode(Driver_IN1, OUTPUT);
 pinMode(Driver_IN2, OUTPUT);
 pinMode(Driver_A, OUTPUT);
 t=millis();
}

void loop()
{
// Le as informacoes do sensor, em cm

  float cmMsec;
  long microsec = ultrasonic.timing();
  cmMsec = ultrasonic.convert(microsec, Ultrasonic::CM);
  
  // Exibe informacoes no serial monitor
  
  Serial.println(cmMsec);

// Controle do driver
  // Definindo sentido do driver
  // Sentido 1
  digitalWrite(Driver_IN1, HIGH);
  digitalWrite(Driver_IN2, LOW);
  // Sentido 2
  /*
  digitalWrite(Driver_IN1, LOW);
  digitalWrite(Driver_IN2, HIGH);
  */

  // Definindo velocidade do driver
  // Parado
  velocidade = 0
  /*
  // Função senoidal
  w = 2*pi/(tciclo*1000);
  velocidade = 255 * sin(w*t);
  */
  analogWrite(Driver_A, velocidade);

  delay(dlay);
}
