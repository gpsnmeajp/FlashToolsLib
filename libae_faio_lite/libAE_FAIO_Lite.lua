--v0.1/BSD license
local gc=collectgarbage
local _bor=bit32.bor
local _band=bit32.band
local _btst=bit32.btest
local _rsf=bit32.rshift
local _bn=bit32.bnot
local _lsf=bit32.lshift
local T,t;
local LCD_ADR=0x7C

local mk,nk
local PM=0
local PD =0
HIGH=1;LOW=0;INPUT=0;OUTPUT=1

if(fa.md5 ~= nil) then
	print("firmware too old");error()
end
function spiEnd()
	fa.spi("cs",1);fa.spi("read");gc()
end
local sE=spiEnd
function spiStart()
	fa.spi("cs",0)
end
local sS=spiStart
function spiComm(d)
	return fa.spi("write",d)
end
local sC=spiComm
function libAE_FAIO_Setup(s)
	if(s == nil) then s = 100;end
	fa.spi("init",s);fa.spi("mode",3);sE()
end
function regWrite(a,d)
	sS();sC(0x20);sC(a);sC(d);sE()
end
function regRead(a)
	sS();sC(0x21);sC(a);rcv = sC(0xFF);sE()
	return rcv
end
gc()
function setTris(S)
	T=0
	if(_btst(S,1))then T=_bor(T,2) else T=_bor(T,1) end
	if(_btst(S,2))then T=_bor(T,8) else T=_bor(T,4) end
	if(_btst(S,4))then T=_bor(T,32) else T=_bor(T,16) end
	if(_btst(S,8))then T=_bor(T,128) else T=_bor(T,64) end
	regWrite(0,T)
end

function digitalRead(p)
	mk=_lsf(1,p);T=regRead(1)
	if(_btst (T,mk)) then return 1;end
	return 0
end
function digitalWrite(p,d)
	mk=_lsf(1,p);nk=_bn(mk)
	if(d==0) then PD=_band(PD, nk) else PD=_bor(PD, mk) end
	regWrite(1,PD)
end
function pinMode(p,m)
	mk=_lsf(1,p);nk=_bn(mk)
	if (m==1) then PM=_bor(PM, mk) else PM=_band(PM, nk) end
	setTris(PM)
	return
end
function delay(t)
	gc();sleep(t)
end
gc()
function i2cSpeed(s)
	regWrite(2,s)
end
function 	i2cBusyWait()
  while true do
		T=regRead(4)
		if(T~=0xF3)then break end
	end
end
function i2cWriteStart(a,l)
	i2cBusyWait()
	sS();sC(0);sC(l);sC(a)
end
function i2cWrite(a,...)
	local l = select("#", ...)
	i2cWriteStart(a,l)
	for i = 1,l do
		 sC(select(i, ...))
	end
	sE()
end
gc()
function lcdData(d)
	i2cWrite(LCD_ADR,0x40,d)
end
local Da = lcdData
function lcdCommand(d)
	i2cWrite(LCD_ADR,0,d)
	sleep(1)
end
local Cm = lcdCommand
function lcdPrint(s)
	local ls=string.len(s)
	i2cWriteStart(LCD_ADR,ls+1)
	sC(0x40)
	for i=1,ls do
		code=string.byte(s, i)
		sC(code)
	end
	sE()
end
function lcdPos(x,y)
	t=0
	if(y~=0) then t=0x40 end
	pos=_bor(t,x,0x80)
	Cm(pos)
end
function lcdClear()
	Cm(1)sleep(10)
end
function lcdCont(c,b)
	t=0
	if(b==1)then t=0x04 end
	local l=_bor(_band(c,0x0F),0x70)
	local h=_bor(_band(_rsf(c,4),3),0x58,t)
	i2cWrite(LCD_ADR,0,0x39,l,h,0x38)
end
function lcdInit(i)
	if(i ~= nil) then LCD_ADR=i end
	Cm(0x38);Cm(0x39);Cm(0x04);Cm(0x14);Cm(0x70);Cm(0x5B);Cm(0x6C);sleep(200)
	Cm(0x38);Cm(0x0C);Cm(1);sleep(100)
end
gc()
