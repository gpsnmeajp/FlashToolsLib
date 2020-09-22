require("/AE_FAIO_HTTP_IO/common/libs/libAE_FAIO-core");
require("/AE_FAIO_HTTP_IO/common/libs/libAE_FAIO-gpio");
require("/AE_FAIO_HTTP_IO/common/libs/libAE_FAIO-i2c");
require("/AE_FAIO_HTTP_IO/common/libs/libAE_FAIO-lcd");

print "HTTP/1.1 200 OK"
print ""

libAE_FAIO_Setup(10);
lcdInit();
lcdCont(0x20,1); --3.3V環境の場合はコメント外す。
lcdClear();

print "OK";
