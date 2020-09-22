#include <FlashAirSharedMem.h>

void setup()
{
	pinMode(10,OUTPUT); //Arduino Uno HW-SPI-SS pin
	
	Serial.begin(9600);

	while(SharedMemInit(4)){
		Serial.println("Init err");
		delay(500);
	}
	
	//--- Write ---
	uint8_t buf[512] = {'T','E','S','T'};
	if(SharedMemWrite(0,512,buf)){
		Serial.println("\nWrite err");
		return;
	}
	Serial.print("WRITE>");
	for(int i=0;i<512;i++)
		Serial.write(buf[i]);
	Serial.println();
	
	//--- Verify ---
	uint8_t buf2[512];
	if(SharedMemRead(0,512,buf2)){
		Serial.println("\nRead error");
		return;
	}
	Serial.print("READ>");
	for(int i=0;i<512;i++)
		Serial.write(buf2[i]);

	Serial.println();
	Serial.println("OK");
}

void loop(void) {
}
