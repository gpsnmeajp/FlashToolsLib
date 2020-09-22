--ライブラリ LCD
--I2C液晶操作用。前提としてi2cが必要。Readは不要。
	
local LCD_ADR = 0x7C;
local _posX = 0;
local _posY = 0;
local _col = 16;
local _row = 2;

--データ1バイト送信。
function lcdData(data)
	i2cWrite(LCD_ADR,0x40,data);
end

--コマンド1バイト送信。
function lcdCommand(data)
	i2cWrite(LCD_ADR,0x00,data);
end

function lcdPrintLine(s)
	local ls = string.len(s);

	for i=1,ls do
		code = string.byte(s, i);
		if(code == 0xA)then
			lcdPos(0,_posY+1)			
		else
			lcdData(code);
		end
		
		_posX=_posX+1;
		if(_posX > _col)then
			lcdPos(0,_posY+1)
		end
		if(_posY > _row)then
			lcdPos(0,0)
		end
	end
end

--データ一括送信
function lcdPrint(s)
	local ls = string.len(s);

	i2cWriteStart(LCD_ADR,ls+1);
	spiComm(0x40); -- CO = 0,RS = 1

	for i=1,ls do
		code = string.byte(s, i);
		spiComm(code);
	end
	spiEnd();
end

--LCD位置
function lcdPos(x,y)
	local y_pos = 0;
	if(y ~= 0) then y_pos = 0x40; end;
	pos = bit32.bor(y_pos,x,0x80);
	
	lcdCommand(pos);

	_posX=x;
	_posY=y
end

--LCD位置
function lcdMax(x,y)
	_col = x;
	_row = y;
end

--画面消去
function lcdClear()
	lcdCommand(0x01);
	_posX=0;_posY=0;
	sleep(10);
end

function lcdCont(cont,boost)
	local boost_bit = 0;
	if(boost == 1)then 
		boost_bit=0x04;
	end

	local low_cont  = bit32.bor(bit32.band(cont,0x0F),0x70);
	local high_cont = bit32.bor(bit32.band(bit32.rshift(cont,4),0x03),0x58,boost_bit);
  
	i2cWrite(LCD_ADR,0x00,0x39,low_cont,high_cont,0x38);
	_posX=0;_posY=0;
end

 --初期化
function lcdInit(i2cadr)
	if(i2cadr ~= nil) then LCD_ADR=i2cadr; end;

	i2cWrite(LCD_ADR,0x00,0x38,0x39,0x04,0x14,0x70,0x5B,0x6C);
	sleep(100);
	i2cWrite(LCD_ADR,0x00,0x38,0x0C,0x01);
	sleep(100);
	_posX=0;_posY=0;
end

gc();
