require("pioduino")

--ピン定義
PIN_R = 1
PIN_G = 3
PIN_B = 2

--ピン初期化
pinMode(0,INPUT)
pinMode(PIN_R ,OUTPUT)
pinMode(PIN_G ,OUTPUT)
pinMode(PIN_B ,OUTPUT)

digitalWrite(PIN_R ,HIGH)
digitalWrite(PIN_G ,HIGH)
digitalWrite(PIN_B ,HIGH)
delay(500)

digitalWrite(PIN_R ,LOW)
digitalWrite(PIN_G ,LOW)
digitalWrite(PIN_B ,LOW)
delay(1000)

digitalWrite(PIN_R ,HIGH)
delay(500)
digitalWrite(PIN_R ,LOW)
delay(500)
digitalWrite(PIN_G ,HIGH)
delay(500)
digitalWrite(PIN_G ,LOW)
delay(500)
digitalWrite(PIN_B ,HIGH)
delay(500)
digitalWrite(PIN_B ,LOW)

--スイッチ入力してみる
delay(1000)
if(digitalRead(0) == HIGH) then
	digitalWrite(PIN_R ,1)
	delay(500)
	digitalWrite(PIN_G ,1)
	delay(500)
	digitalWrite(PIN_B ,1)
	delay(500)
else
	digitalWrite(PIN_R ,1)
	digitalWrite(PIN_G ,1)
	digitalWrite(PIN_B ,1)
	delay(500)

	digitalWrite(PIN_R ,0)
	delay(500)
	digitalWrite(PIN_G ,0)
	delay(500)
	digitalWrite(PIN_B ,0)
	delay(500)
end

delay(500)

