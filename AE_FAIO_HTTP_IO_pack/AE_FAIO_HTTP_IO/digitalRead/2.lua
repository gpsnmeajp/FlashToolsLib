require("/AE_FAIO_HTTP_IO/common/module/pinIOstartup")

pin = 2;

pinMode(pin,INPUT);
print(digitalRead(pin));

endOfProgram();
