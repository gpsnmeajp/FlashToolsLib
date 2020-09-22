require("pioduino")

--ピン定義
PIN_R = 1
PIN_G = 3
PIN_B = 2

--ピン初期化
pM(0,INPUT)
pM(PIN_R ,OUTPUT)
pM(PIN_G ,OUTPUT)
pM(PIN_B ,OUTPUT)

dW(PIN_R ,HIGH)
dW(PIN_G ,HIGH)
dW(PIN_B ,HIGH)
delay(500)

dW(PIN_R ,LOW)
dW(PIN_G ,LOW)
dW(PIN_B ,LOW)
delay(1000)

dW(PIN_R ,HIGH)
delay(500)
dW(PIN_R ,LOW)
delay(500)
dW(PIN_G ,HIGH)
delay(500)
dW(PIN_G ,LOW)
delay(500)
dW(PIN_B ,HIGH)
delay(500)
dW(PIN_B ,LOW)

--スイッチ入力してみる
delay(1000)
if(dR(0) == HIGH) then
	dW(PIN_R ,1)
	delay(500)
	dW(PIN_G ,1)
	delay(500)
	dW(PIN_B ,1)
	delay(500)
else
	dW(PIN_R ,1)
	dW(PIN_G ,1)
	dW(PIN_B ,1)
	delay(500)

	dW(PIN_R ,0)
	delay(500)
	dW(PIN_G ,0)
	delay(500)
	dW(PIN_B ,0)
	delay(500)
end

delay(500)

	dW(PIN_R ,1)
	dW(PIN_G ,1)
	dW(PIN_B ,1)
delay(3000)
