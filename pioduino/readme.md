FlashAirのPIOをArduino風に扱う

FlashAirのPIO関数は、入出力の設定と、出力状態を同時に指定する形ですが、いかんせん1bit単位でいじるのが面倒くさい、ということで、Arduinoでお馴染みdigitalWrite、digiralRead、pinModeで扱えるようにしてみました。これを使うと、Arduinoで上記の関数を使って作ったSPIやI2Cなどの再現を、ほぼそのまま移植して使うことができます。バグ等あるかもしれませんので、十分注意してご利用ください。FlashAirをいじってわかったこと。

Luaスクリプト集

スクリプトはファイルとして配布することにしました。pioduino.luaをスクリプトと同じフォルダに置き、スクリプトの先頭にrequire("pioduino")を書くと、読み込まれます。また、サイズを小さくしたい、打つのが面倒くさい、という人向けにpinMode       →   pMdigitalWrite  →   dWdigitalRead   →   dRでも参照できるようにしました。demo1.luaはArduino互換の通常表記demo2.luaは短縮表記でのデモです。短縮表記は、pioduino.luaの最後の3行ですので、不要な場合は削除してください。

※FlashAirのバグ的挙動により、require後に一部の関数を実行するとフリーズする場合があります(string.byteなど)　その場合、require("pioduino")を使わず、pioduino.luaの中身をスクリプトに直書きすることで　問題が解消することがあります。  この問題は、2KB以上のファイル(特にその中に関数が含まれる場合)をrequireで読み込むと発生します。　同様の現象は、dofile、loadfileでも発生するようです。ご注意ください。

　→また、W3.00.01にアップデートすることで改善します。

--[[Arduino的にFlashAirのPIOを扱う。必ず、pinModeで入出力を設定後、digitalWriteもしくはdigitalReadで操作すること。各ピンの入出力選択、出力状態は記憶しているため、これらを使わずpio関数を直接触った後、これらの関数を使うと望み通りの動作をしない。入出力は、デフォルトでは全端子INPUT(0)、全LOW(0)である。s, indata = pinMode(port,mode)入出力設定OUTPUT(1)で出力INPUT(1以外)で入力に設定。sは制御可否(pio関数の戻り値参照)indataがくっついているのは、pioの返却値をそのまま返しているため。s, indata = digitalWrite(port,dat)出力。HIGH(0以外)で3,3VLOW(0)で0Vを出力。sは制御可否(pio関数の戻り値参照)indataがくっついているのは、pioの返却値をそのまま返しているため。dat , s = digitalRead(port)指定したピンの入力状態をHIGH(1)もしくはLOW(0)で返却する。sは制御可否(pio関数の戻り値参照)]]--

Airioでのピン対応
0:CMD   : 0x01 : SW1	D1	MOSI1:D0  	: 0x02 : Red	D0	MISO(直結)2:D1  	: 0x04 : Blue	DAT1	NC3:D2  	: 0x08 : Green	DAT2	NC4:D3  	: 0x10 : NONE	CS	CS→他の場合のピン対応は、FTLE内のIOテスターに表があります。
