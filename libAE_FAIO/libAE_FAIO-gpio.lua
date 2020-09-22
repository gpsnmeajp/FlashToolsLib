--ライブラリ GPIO
--Arduino風のIOポート操作を提供する

local PIO_MODE = 0x00;	--ピン入出力変数(触らないこと)
local PIO_DATA  = 0x00;	--ピン状態変数(触らないこと)

HIGH  = 0x1; --定数
LOW  = 0x0; --定数

INPUT  =  0x0; --定数
OUTPUT  =  0x1; --定数

local _bor = bit32.bor;
local _band = bit32.band;
local _btst = bit32.btest;

--1が出力、0が入力、を、10で出力、01で入力、に変換する。
function setTris(S)
	local T=0x00
	if(_btst(S,0x01))then T = _bor(T,0x02) else T = _bor(T,0x01) end
	if(_btst(S,0x02))then T = _bor(T,0x08) else T = _bor(T,0x04) end
	if(_btst(S,0x04))then T = _bor(T,0x20) else T = _bor(T,0x10) end
	if(_btst(S,0x08))then T = _bor(T,0x80) else T = _bor(T,0x40) end
	regWrite(0x00,T)
end

--IOピンから入力する
function digitalRead(port)
	local PIO_INFO=0
	local mask = bit32.lshift(1,port)
 
	PIO_INFO = regRead(0x01);
	
	if(_btst (PIO_INFO,mask)) then
		 return 1;
	end
	
	return 0;
end

--IOピンに出力する。HIGH/LOW
function digitalWrite(port,dat)
	local mask = bit32.lshift(1,port)
	local nmask = bit32.bnot (mask)

	if(dat == 0) then
		 PIO_DATA = _band(PIO_DATA, nmask)
	else
		 PIO_DATA = _bor(PIO_DATA, mask)	
	end

	regWrite(0x01,PIO_DATA)
end
--IOピンのステートを設定する。INPUT/OUTPUT/INPUT_PULLUP
function pinMode(port,mode)
	local mask = bit32.lshift(1,port)
	local nmask = bit32.bnot (mask)

	if (mode == OUTPUT) then
		 PIO_MODE = _bor(PIO_MODE, mask)	
	else
		 PIO_MODE = _band(PIO_MODE, nmask)
	end

	setTris(PIO_MODE)
	return
end
--時間待ち互換関数
function delay(t)
	collectgarbage();
	sleep(t);
end

gc();
