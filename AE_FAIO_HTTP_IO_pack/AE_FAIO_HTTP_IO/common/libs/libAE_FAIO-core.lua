--ライブラリコア
--レジスタ読み書き・通信部分を担当。

gc = collectgarbage;

--初期化を行う。
function libAE_FAIO_Setup(speed)
	if(speed == nil) then speed = 1314; end; --安全のため初期値は20kHz

	fa.spi("init",speed);
	fa.spi("mode",3);
	spiEnd(); --念のため切り替え処理。
end

--生SPI送受信
function spiComm(dat)
	if(dat == nil) then dat = 0xFF; end;
	rcv = fa.spi("write",dat);
	return rcv;
end

--SPI完了(CSバグ対策)
function spiEnd()
	fa.spi("cs",1);
	fa.spi("read");
	collectgarbage();
end
function spiStart()
	fa.spi("cs",0);
end

--レジスタ書き込み。
function regWrite(adr,data)
	spiStart();
	spiComm(0x20);
	spiComm(adr);
	spiComm(data);	
	spiEnd();
end

--レジスタ読み込み。
function regRead(adr)
	spiStart();
	spiComm(0x21);
	spiComm(adr);
	rcv = spiComm(0xFF);	
	spiEnd();
	return rcv;
end

gc();

if(fa.md5 ~= nil) then
	print("FlashAir firmware version is too old!\n");
	print("FlashAirのファームウェアが古すぎます！");
	error("error() has been called.");
end;
