#include <FlashAirSharedMem.h>

void setup()
{
	pinMode(10,OUTPUT); //Arduino Uno HW-SPI-SS pin
	
	Serial.begin(9600);

	while(SharedMemInit(4)){
		Serial.println("Init err");
		delay(500);
	}
	
	uint8_t buf[512];
	if(SharedMemRead(0,512,buf)){
		Serial.println("\nRead error");
		return;
	}

	Serial.print("Read 1Byte[0x000]:");
	Serial.write(SharedMemReadSimple(0x000));
	Serial.println();

	Serial.print("Read 1Byte[0x001]:");
	Serial.write(SharedMemReadSimple(0x001));
	Serial.println();	

	Serial.print("Read 1Byte[0x002]:");
	Serial.write(SharedMemReadSimple(0x002));
	Serial.println();	
	
	Serial.println("OK");
}

void loop(void) {
}
