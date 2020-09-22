require("/AE_FAIO_HTTP_IO/common/libs/libAE_FAIO-core");
require("/AE_FAIO_HTTP_IO/common/libs/libAE_FAIO-gpio");
require("/AE_FAIO_HTTP_IO/common/libs/libAE_FAIO-i2c");
require("/AE_FAIO_HTTP_IO/common/libs/libAE_FAIO-lcd");

print "HTTP/1.1 200 OK"
print ""

if(arg[1] == nil)then
	print "e.g. print.lua?message%0Ahello  (%0A = LineFeed)";
	return;
end

libAE_FAIO_Setup(10);
lcdInit();
lcdMax(16,2); --DisplaySize
lcdCont(0x20,1); --3.3V環境の場合はコメント外す。
lcdPrintLine(arg[1]);

print "OK";
