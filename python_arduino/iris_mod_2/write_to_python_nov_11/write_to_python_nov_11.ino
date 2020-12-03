/*
  gets what python sent in from USB, and prints it to serial monitor
  ref write_serial_out.py
*/
//#include <Wire.h>
//#include <string.h>
const uint8_t COMM_PIN = 2; //pin to transmit on
const uint8_t PERIOD = 104; //period = 1/baud *1000000

void setup() {
  Serial.begin(9600); //USB
  Serial1.begin(9600); //Serial output or something
  pinMode(COMM_PIN, OUTPUT);
  delay(1000);
  Serial.println("Starting");
  bool good = false;
  uint32_t start = millis();
}
byte incomingBytes[10];
void loop() {
  //  Serial.println("HIHI");
  //  delay(1000);
  if (Serial.available() > 0) {
    memset(incomingBytes, 0, 10); // make all output high=255? or make it zero?
    Serial.readBytes(incomingBytes, 2);
    serial_bitbang(incomingBytes, 2);
    delay(4);
  }
  if (Serial1.available()) {
    Serial.write(Serial1.read());   // read it and send it out Serial (USB)
  }
}

void serial_bitbang(uint8_t* invals, int length) {
  for (uint16_t i = 0; i < length; i++) {
    //start bit
    uint32_t comm = micros();
    digitalWrite(COMM_PIN, 0);
    //Serial.print(invals[i]);
    while (micros() - comm < PERIOD); //start bit
    comm = micros();
    uint16_t val = (uint8_t)(invals[i]);
    //val/=16;
    for (uint16_t j = 0; j < 8; j++) {
      if (val % 2) {
        digitalWrite(COMM_PIN, 1);
      } else {
        digitalWrite(COMM_PIN, 0);
      }
      val /= 2;  //right shift
      while (micros() - comm < PERIOD); //data bit
      comm = micros();
    }

    digitalWrite(COMM_PIN, 1);
    while (micros() - comm < PERIOD); //stop bit
    //delay(3); // if >2, then becomes 1 byte wait
  }
}
