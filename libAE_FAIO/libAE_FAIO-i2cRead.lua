--ライブラリ I2CRead
--I2C受信処理を担当する。前提として送信部が必要。

function i2cReadBuf(len)
	local ReadBuffer = {};
	i2cBusyWait();

	spiStart();
	spiComm(0x06);
	for i = 1,len do
		ReadBuffer[i] = spiComm(0xFF);
	end
	spiEnd();
	
	return ReadBuffer;
end

function i2cWriteRead(adr,ReadLen,...)
	local WriteLen = select("#", ...);

	i2cBusyWait();

	spiStart();
	spiComm(0x02);
	spiComm(WriteLen);
	spiComm(ReadLen);
	spiComm(adr);
	
	for i = 1,WriteLen do
		 spiComm(select(i, ...));
	end

	spiComm(adr+1); --読み込みAdr

	spiEnd();
	return i2cReadBuf(ReadLen);
end

function i2cRead(adr,len)
	i2cBusyWait();

	spiStart();
	spiComm(0x01);
	spiComm(len);
	spiComm(adr);
	spiEnd();
	return i2cReadBuf(len);
end

gc();
