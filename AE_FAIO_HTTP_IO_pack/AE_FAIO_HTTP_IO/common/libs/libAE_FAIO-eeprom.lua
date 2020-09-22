--ライブラリ EEROM
--I2C EEROM操作用。前提としてi2cとi2cReadが必要。

--EERPOM---
function eepromRead(i2cadr,adr,len)
	local High_adr = bit32.band(bit32.rshift(adr,8),0xFF);
	local Low_adr = bit32.band(adr,0xFF);
	local ep_adr = i2cadr;
	
	if(len == nil) then len=1; end;
	
	if(bit32.band(adr,0x10000) ~= 0)then
		ep_adr = bit32.bor(ep_adr, 0x02);
	end;
	
	local list = i2cWriteRead(ep_adr,len,High_adr,Low_adr);

	if(len == 1) then return list[1]; end;
	return list;
end

function eepromWrite(i2cadr,adr,dat)
	local High_adr = bit32.band(bit32.rshift(adr,8),0xFF);
	local Low_adr = bit32.band(adr,0xFF);
	local ep_adr = i2cadr;
	
	if(bit32.band(adr,0x10000) ~= 0)then
		ep_adr = bit32.bor(ep_adr, 0x02);
	end;
	
	i2cWrite(i2cadr,High_adr,Low_adr,dat);
end

gc();
