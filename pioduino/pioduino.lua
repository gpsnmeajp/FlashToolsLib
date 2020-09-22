--[[
Arduino的にFlashAirのPIOを扱う。

必ず、pinModeで入出力を設定後、digitalWriteもしくはdigitalReadで操作すること。
各ピンの入出力選択、出力状態は記憶しているため、
これらを使わずpio関数を直接触った後、これらの関数を使うと望み通りの動作をしない。

入出力は、デフォルトでは全端子INPUT(0)、全LOW(0)である。

s, indata = pinMode(port,mode)
入出力設定
OUTPUT(1)で出力
INPUT(1以外)で入力に設定。

sは制御可否(pio関数の戻り値参照)
indataがくっついているのは、pioの返却値をそのまま返しているため。

s, indata = digitalWrite(port,dat)
出力。
HIGH(0以外)で3,3V
LOW(0)で0Vを出力。

sは制御可否(pio関数の戻り値参照)
indataがくっついているのは、pioの返却値をそのまま返しているため。


dat , s = digitalRead(port)
指定したピンの入力状態をHIGH(1)もしくはLOW(0)で返却する。
sは制御可否(pio関数の戻り値参照)

]]--

PIO_MODE = 0x00   --ピン入出力変数(触らないこと)
PIO_DATA  = 0x00   --ピン状態変数(触らないこと)

HIGH  = 0x1 --定数
LOW  = 0x0 --定数

INPUT  =  0x0 --定数
OUTPUT  =  0x1 --定数

function delay(t)
	sleep(t)
end

function digitalWrite(port,dat)
	local mask = bit32.lshift(1,port)
	local nmask = bit32.bnot (mask)

	if(dat == LOW) then
		PIO_DATA = bit32.band(PIO_DATA, nmask)
	else
		PIO_DATA = bit32.bor(PIO_DATA, mask)	
	end

	return fa.pio(PIO_MODE,PIO_DATA)
end

function digitalRead(port)
	local PIO_STATUS = 0
	local mask = bit32.lshift(1,port)
	
	PIO_STATUS, PIO_INFO = fa.pio(PIO_MODE, PIO_DATA)
	
	if(bit32.btest (PIO_INFO,mask)) then
		return HIGH, PIO_STATUS
	end
	
	return LOW, PIO_STATUS
--(IF文や他の関数に直接突っ込めるよう、第一引数にポート状態を置いてある)
end

function pinMode(port,mode)
	local mask = bit32.lshift(1,port)
	local nmask = bit32.bnot (mask)

	if (mode == OUTPUT) then
		PIO_MODE = bit32.bor(PIO_MODE, mask)	
	else
		PIO_MODE = bit32.band(PIO_MODE, nmask)
	end

	return fa.pio(PIO_MODE,PIO_DATA)
end

dW = digitalWrite
dR = digitalRead
pM = pinMode
