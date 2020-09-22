/*
BSD 3-Clause License

Copyright (c) 2016-2018, GPS_NMEA
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#include "Arduino.h"
#include "FlashAirSharedMem.h"
//#define SOFT_SPI
int cs = 4;

#ifdef SOFT_SPI
const int miso = 12;
const int mosi = 11;
const int sck = 13;

uint8_t spi_trans(uint8_t dat)
{

	byte rcv = 0x00;
	for(int i=0;i<8;i++)
	{
		if(dat & 0x80)
			digitalWrite(mosi,HIGH);
		else
			digitalWrite(mosi,LOW);
	
		dat <<= 1;	

		digitalWrite(sck,HIGH); //LATCH
		
		rcv <<= 1;	
		if(digitalRead(miso) == HIGH)
			rcv |= 0x01;
		else
			rcv |= 0x00;
		
		digitalWrite(sck,LOW); //SHIFT
	}
	
	return rcv;
}
#else
#include <SPI.h>
uint8_t spi_trans(uint8_t dat)
{
	return SPI.transfer(dat);
}

#endif

void cs_release()
{
	//release
	digitalWrite(cs,HIGH);
	spi_trans(0xFF);
}

int8_t sd_cmd(uint8_t cmd,uint32_t arg)
{
	uint8_t val;

	spi_trans(0xFF);//END of MODE

	digitalWrite(cs,LOW);
	spi_trans(0x40 | cmd);
	spi_trans(arg>>24);
	spi_trans(arg>>16);
	spi_trans(arg>>8);
	spi_trans(arg);
	
	if(cmd == 0x00)
		spi_trans(0x95);
	else if(cmd == 0x08)
		spi_trans(0x87);
	else
		spi_trans(0x01); //CRC+STOP

	do{
		val = spi_trans(0xFF);//R1 Rcv
	}while(val == 0xFF);
	
	return val;
}

int8_t SharedMemInit(int _cs)
{
	cs = _cs;
	uint8_t val;
	
	pinMode(cs, OUTPUT);//CS output
#ifdef SOFT_SPI
	pinMode(miso,INPUT);
	pinMode(mosi,OUTPUT);
	pinMode(sck,OUTPUT);
	digitalWrite(mosi,LOW);
	digitalWrite(sck,LOW);
#else
	SPI.begin();
	SPI.setClockDivider(SPI_CLOCK_DIV4);
	SPI.setDataMode(SPI_MODE0);
	SPI.setBitOrder(MSBFIRST);
#endif	
	//power-on clock
	digitalWrite(cs,LOW);
	for(int8_t i=0;i<10;i++)
		spi_trans(0xFF);

	cs_release();

	if(sd_cmd(0,0x00000000) != 0x01){
		return -1;
	}

	cs_release();
	if(sd_cmd(8,0x000001AA) != 0x01){
		return -2;
	}
	//R7 Responce
	spi_trans(0xFF); //0
	spi_trans(0xFF); //0
	spi_trans(0xFF); //0
	if(spi_trans(0xFF) != 0xAA) //AA
	{
		return -3;
	}
	
	//--ACMD41--
	do{
		cs_release();
		val = sd_cmd(55,0x00000000);
		val = sd_cmd(41,0x40000000); //HCS=1
	}while(val != 0);
	
	cs_release();
	return 0;
}
int8_t SharedMemWrite(uint16_t adr, uint16_t len, uint8_t buf[])
{
	if(adr + len > 512)
		return -1;
	if(len == 0)
		return -1;
		
	uint32_t sd_adr = 0x1000 + adr;
	uint32_t arg = 0x90000000 | ((sd_adr & 0x1FFFF) << 9) | ((len - 1) & 0x1FF);
	
	if(sd_cmd(24,arg) != 0)
	{
		return -2;
	}
	
	spi_trans(0xFE); //BLOCK START
	
	for (int16_t i = 0; i < 512; i++) {
		if(i < len){
			spi_trans(buf[i]);
		}else{
			spi_trans(0xFF);
		}
	}

	//CRC
	spi_trans(0xFF);
	spi_trans(0xFF);
	
	//Ans
	if((spi_trans(0xFF) & 0x1F) != 0x05) //DATA ACCEPTED
	{
		return -3;
	}
	
	//Wait for Busy
	while(spi_trans(0xFF) == 0x00);

	cs_release();
	return 0;
}

int8_t SharedMemRead(uint16_t adr, uint16_t len, uint8_t buf[])
{
	if(adr + len > 512)
		return -1;
	if(len == 0)
		return -1;
		
	uint32_t sd_adr = 0x1000 + adr;
	uint32_t arg = 0x90000000 | ((sd_adr & 0x1FFFF) << 9) | ((len - 1) & 0x1FF);

	if(sd_cmd(17,arg) != 0)
	{
		return -2;
	}

	while((spi_trans(0xFF)) != 0xFE);
 
	for (int16_t i = 0; i < 514; i++) {
		if(i < len){
			buf[i] = spi_trans(0xFF);
		}else{
			spi_trans(0xFF);
		}
	}
	cs_release();
	return 0;
}

int8_t SharedMemWriteSimple(uint16_t adr, uint8_t data)
{
	uint8_t buf[1] = {data}; 
	return SharedMemWrite(adr,1,buf);
}
int16_t SharedMemReadSimple(uint16_t adr)
{
	uint8_t buf[1] = {0};
	int16_t stat = SharedMemRead(adr,1,buf);
	if(stat < 0)
		return stat;
	
	return buf[0];
}