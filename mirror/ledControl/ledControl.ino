int ledPin = 12;
int val;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);

}

void loop() {
  // put your main code here, to run repeatedly:
  while(Serial.available()){
    val = Serial.read();
  }
  if(val == 'q'){
    lightLEDs(10);
  }
  if(val == 'w'){
    lightLEDs(20);
  }
  if(val == 'e'){
    lightLEDs(30);
  }
  

}

void lightLEDs(int n){
  for(int i = 0; i < n; i++){
    digitalWrite(ledPin,HIGH);
    delay(100);
    digitalWrite(ledPin,LOW);
    delay(100);  
  }
}

