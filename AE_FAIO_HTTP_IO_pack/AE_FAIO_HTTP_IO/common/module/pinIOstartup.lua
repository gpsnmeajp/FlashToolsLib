require("/AE_FAIO_HTTP_IO/common/libs/libAE_FAIO-core");
require("/AE_FAIO_HTTP_IO/common/libs/libAE_FAIO-gpio");

print "HTTP/1.1 200 OK"
print ""

libAE_FAIO_Setup(100);

--前回の状態を読みだし
PIO_MODE = tonumber(fa.sharedmemory("read", 0, 4))
PIO_DATA = tonumber(fa.sharedmemory("read", 4, 4))
if(PIO_MODE == nil)then PIO_MODE=0;end;
if(PIO_DATA == nil)then PIO_DATA=0;end;

function endOfProgram()
	--今回の状態を保存
	fa.sharedmemory("write", 0, 4, PIO_MODE);
	fa.sharedmemory("write", 4, 4, PIO_DATA);
	return;
end;
