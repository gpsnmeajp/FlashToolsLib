#ifndef FlashAirSharedMem_h
#define FlashAirSharedMem_h

int8_t SharedMemInit(int _cs);

int8_t SharedMemWrite(uint16_t adr, uint16_t len, uint8_t buf[]);
int8_t SharedMemRead(uint16_t adr, uint16_t len, uint8_t buf[]);

int8_t SharedMemWriteSimple(uint16_t adr, uint8_t data);
int16_t SharedMemReadSimple(uint16_t adr);

//Internal
uint8_t spi_trans(uint8_t x);
void cs_release();
int8_t sd_cmd(uint8_t cmd,uint32_t arg);

#endif