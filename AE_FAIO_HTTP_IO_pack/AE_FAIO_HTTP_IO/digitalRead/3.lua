require("/AE_FAIO_HTTP_IO/common/module/pinIOstartup")

pin = 3;

pinMode(pin,INPUT);
print(digitalRead(pin));

endOfProgram();
