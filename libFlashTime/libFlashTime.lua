--[[
libFlashTime v0.2

Copyright (c) 2015, GPS_NMEA
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

local FlashTime = {}

--FAT形式のファイルアクセス時間を生成する
function FlashTime.GetFATtimeFromLocalTime(Year,Month,Day,Hour,min,sec)
	local Year_bit = bit32.band((Year - 1980),0x7F);
	local Month_bit = bit32.band(Month,0x0F);
	local Day_bit = bit32.band(Day,0x3F);

	local Hour_bit = bit32.band(Hour,0x1F);
	local min_bit = bit32.band(min,0x3F);
	local sec_bit = bit32.band(sec/2,0x1F);

	local YMD_bits = bit32.bor(bit32.lshift(Year_bit,9),bit32.lshift(Month_bit,5),Day_bit);
	local HMS_bits = bit32.bor(bit32.lshift(Hour_bit,11),bit32.lshift(min_bit,5),sec_bit);

	return YMD_bits,HMS_bits;
end

--FAT形式のファイルアクセス時間を分解する
function FlashTime.GetLocalTimeFromFATtime(Fat_binary_time)
	local Year = bit32.band (bit32.rshift(Fat_binary_time, 9+16),0x7F) + 1980;
	local Month = bit32.band (bit32.rshift(Fat_binary_time, 5+16),0x0F);
	local Day = bit32.band (bit32.rshift(Fat_binary_time,0+16),0x1F);

	local Hour = bit32.band (bit32.rshift(Fat_binary_time, 11),0x1F);
	local min = bit32.band (bit32.rshift(Fat_binary_time, 5),0x3F);
	local sec = bit32.band (Fat_binary_time,0x1F)*2; --FAT時間は秒数が2秒刻み

	return Year,Month,Day,Hour,min,sec;
end

--FlashAirのRTCに登録
function FlashTime.SetTime(Year,Month,Day,Hour,min,sec)
	local YMD,HMS = FlashTime.GetFATtimeFromLocalTime(Year,Month,Day,Hour,min,sec);
  	fa.SetCurrentTime(YMD,HMS);
end

--時間を得る
function FlashTime.GetTime()
	local	DL = string.sub(fa.ReadStatusReg(),225,226)
	local	DH = string.sub(fa.ReadStatusReg(),227,228)
	local	TL = string.sub(fa.ReadStatusReg(),229,230)
	local	TH = string.sub(fa.ReadStatusReg(),231,232)
	local	z = tonumber(DH..DL..TH..TL,16)
	local	Year,Month,Day,Hour,min,sec = FlashTime.GetLocalTimeFromFATtime(z);

	return Year,Month,Day,Hour,min,sec;
end

--時間を日本形式で表示
function FlashTime.ShowTime()
	local	Year,Month,Day,Hour,min,sec = FlashTime.GetTime();
	print(Year.."年"..Month.."月"..Day.."日"..Hour.."時"..min.."分"..sec.."秒");
end

--NICT 国立研究開発法人 情報通信研究機構の日本標準時配信サーバー(HTTP版)を使って時刻合わせする。
function FlashTime.SetNICT()
	local b,s,h;
	local i;

	for i=0,10 do
		b,s,h = fa.request("http://worldtimeapi.org/api/timezone/Asia/Tokyo")
		if(s == 200)then break; end;
		sleep(1000);
	end

	if(s ~= 200)then return nil; end;
	local str = cjson.decode(b);
    itr = string.gmatch(str.datetime,"%d+");
	local Year  = itr();
	local Month = itr();
	local Day   = itr();
	local Hour  = itr();
	local min   = itr();
	local sec   = itr();

  	FlashTime.SetTime(Year,Month,Day,Hour,min,sec);

  	return true;
end

return FlashTime;

--[[
--FlashAirに任意の時刻を設定する
FlashTime.SetTime(2009,5,30,8,30,00);
FlashTime.ShowTime();

--FlashAirに自動で現在時刻を設定する(要STAモード)
FlashTime.SetNICT();
FlashTime.ShowTime();

--ファイルタイムスタンプを生成する
fattime,fattime2 = FlashTime.GetFATtimeFromLocalTime(2009,5,30,8,30,00);
print(fattime,fattime2);

--ファイルタイムスタンプから時刻を得る
Year,Month,Day,Hour,min,sec = FlashTime.GetLocalTimeFromFATtime(bit32.bor(bit32.lshift(fattime,16),fattime2));
print(Year.."年"..Month.."月"..Day.."日"..Hour.."時"..min.."分"..sec.."秒");
]]
