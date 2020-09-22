#include "FlashAirSharedMem.h"

void setup()
{

	delay(1000);
	Serial.begin(9600);

	while(int val = SharedMemInit(4)){
		Serial.println("Init err");
		if(val == -1)
			Serial.println("SD has no response. Please eject an reinsert it.");
		delay(500);
	}
	Serial.println("Init OK");
	
	Serial.print("Read 1Byte[0x000]:");
	Serial.write(SharedMemReadSimple(0x000));
	Serial.println();

	Serial.print("Read 1Byte[0x001]:");
	Serial.write(SharedMemReadSimple(0x001));
	Serial.println();
	
	uint8_t buf[512];

	long time3 = micros();
	if(SharedMemRead(0,512,buf)){
		Serial.println("\nread err");
		return;
	}
	long time4 = micros() - time3;
	Serial.print("\nTime:");
	Serial.print(time4);
	Serial.println("[us]");
	Serial.println("Data Red.");
	Serial.print(">");
	for(int i=0;i<512;i++)
		Serial.write(buf[i]);
	


	uint8_t buf2[512] = {'T','E','S','T'};

	long time = micros();
	if(SharedMemWrite(0,512,buf2)){
		Serial.println("\nwrite err");
		return;
	}
	long time2 = micros() - time;
	Serial.print("\nTime:");
	Serial.print(time2);
	Serial.println("[us]");
	Serial.println("Data Wrote.");
	Serial.print(">");
	
	for(int i=0;i<512;i++)
		Serial.write(buf2[i]);

	Serial.println();
	Serial.print("Write 1Byte[0x005] Status:");
	Serial.print(SharedMemWriteSimple(0x005,'A'));
	Serial.println();

	Serial.print("Read 1Byte[0x006] Status:");
	Serial.print(SharedMemWriteSimple(0x006,'B'));
	Serial.println();
	


	Serial.print("\nDone!\n");
}

void loop(void) {
}