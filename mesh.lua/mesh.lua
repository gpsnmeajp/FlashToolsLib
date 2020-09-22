arg_in = arg[1];

---pioduino---

PIO_MODE = 0x00   --ピン入出力変数(触らないこと)
PIO_DATA  = 0x00   --ピン状態変数(触らないこと)

HIGH  = 0x1 --定数
LOW  = 0x0 --定数

INPUT  =  0x0 --定数
OUTPUT  =  0x1 --定数

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

---

function throw(s,m)
  	if(s == 200)then
		print("HTTP/1.1 200 OK\nPragma: no-cache\nCache-Control: no-cache\n\n"..m);
    end
  	if(s == 400)then
		print("HTTP/1.1 400 Bad Request\nPragma: no-cache\nCache-Control: no-cache\n\n"..m);
    end
end

---

if(arg_in == nil)then
  --print("FlashAir x Sony MESH GPIO Bridge v0.1");
  throw(400,"FlashAir x Sony MESH GPIO Bridge v0.1");
  return;
end

arg_in = string.match(arg_in,"[^\n]+"); --改行除去

PIO_MODE = tonumber(fa.sharedmemory("read", 0, 4))
PIO_DATA = tonumber(fa.sharedmemory("read", 4, 4))
if(PIO_MODE == nil)then PIO_MODE=0;end;
if(PIO_DATA == nil)then PIO_DATA=0;end;

--print("Now"..PIO_MODE.."/"..PIO_DATA);

port = string.match(arg_in,"port=[^&]+");
stat = string.match(arg_in,"stat=[^&]+");
output = string.match(arg_in,"output=[^&]+");

if(port == nil) then throw(400,"Port err"); return; end;
if(stat == nil) then throw(400,"Stat err"); return; end;
if(output == nil) then output="0"; end;

port_num = tonumber(string.sub(port, -1,-1));
stat_num = tonumber(string.sub(stat, -1,-1));
output_num = tonumber(string.sub(output, -1,-1));

if(port_num > 4)then
	throw(400,"Port num err");
 	return;
end

if(stat_num > 1)then
	throw(400,"Stat num err");
	return;
end

if(output_num > 1)then
	throw(400,"Output num err");
	return;
end

if(stat_num == 1)then
	pinMode(port_num,OUTPUT);
	digitalWrite(port_num,output_num);
	throw(200,"true");
else
	pinMode(port_num,INPUT);
	if(digitalRead(port_num)==1)then
		throw(200,"true");
    else
		throw(200,"false");
    end
end

--print("Now"..PIO_MODE.."/"..PIO_DATA);

fa.sharedmemory("write", 0, 4, PIO_MODE);
fa.sharedmemory("write", 4, 4, PIO_DATA);
