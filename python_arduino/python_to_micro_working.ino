/*
  gets what python sent in from USB, and prints it to serial monitor
  ref write_serial_out.py
*/

void setup() {
  Serial.begin(115200); //USB
  Serial1.begin(115200); //Serial output or something
}
int incomingByte =0;
void loop() {
  while (!Serial.available()) {} // wait
  while (Serial.available()>0) {
    incomingByte = Serial.read();
    if (incomingByte > 0) {
      Serial.println(incomingByte, DEC);
      Serial1.write(incomingByte);
    }

  }

}
