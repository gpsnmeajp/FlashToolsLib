--ライブラリ I2C
--I2C送信処理を担当する。受信処理は別。

--I2Cの速度を設定する。5=369kHz,255=7.2kHz
function i2cSpeed(speed)
  	if(speed < 5)then speed = 5; end;
	regWrite(0x02,speed);
end

--I2Cバスがビジーな間待つ。スピードを下げている時に特に有効。
function 	i2cBusyWait()
  while true do
		local rcv = regRead(0x04);
		if(rcv ~= 0xF3)then break end; --0xF3 = I2C Busy
	end
end

--I2Cスタート。逐次送信したいものにはこっち。ストップは長さで自動で行われる。
--ただし、	spiEnd();ENDを忘れずに
--8bitアドレスなので注意。
function i2cWriteStart(adr,len)
	i2cBusyWait();

	spiStart();
	spiComm(0x00);
	spiComm(len);
	spiComm(adr);
end

--I2C一括送信。まとめて送信したいものに使う。
--8bitアドレスなので注意。
function i2cWrite(adr,...)
	local len = select("#", ...);

	i2cBusyWait();

	spiStart();
	spiComm(0x00);
	spiComm(len);
	spiComm(adr);
	
	for i = 1,len do
		 spiComm(select(i, ...));
	end
	spiEnd();
end

gc();
