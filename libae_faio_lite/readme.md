libAE_FAIO_Lite  
libAE_FAIOのcore + gpio + i2c + lcdの機能を(一部削って)搭載したライブラリです。  
core + gpio + i2c + lcdの場合5555byteですが、  
libAE_FAIO_Liteは2546byteです。  
  
メモリのキツさが多少改善すると思います。  
LCDの自動改行機能は節約のため削っています。  
また、コメントなし、可読性は著しく低いので、改造はlibAE_FAIOの方をおすすめします。  
  
--サンプルコード--  
require("/libAE_FAIO_Lite");  
libAE_FAIO_Setup();  
lcdInit();  
lcdCont(0x20,1); --3.3V環境の場合はコメント外す。  
lcdPrint("Hello");  
  
pinMode(0,OUTPUT);  
  
for i=1,3 do  
    digitalWrite(0,HIGH);  
    lcdPos(0,1)  
    lcdPrint("SW:"..digitalRead(1));  
    delay(500);  
    digitalWrite(0,LOW);  
    lcdPos(0,1)  
    lcdPrint("SW:"..digitalRead(1));  
    delay(500);  
end  
  
  
・ libAE_FAIO_Setup(speed)  
ライブラリの初期化を行う。  
speedはfa.spiの速度。省略時は100で通信。  
秋月FlashAir DIP IOボードキットの場合、1で動きますので、試してみてください。  
速度的には100くらいで問題ないと思います。  
  
・ regWrite(adr,data)  
レジスタに書き込む。  
  
・ regRead(adr)  
レジスタから読み込む。  
  
・ digitalRead(pin)  
指定したピンの入力状態を読み取る。  
HIGH=1/LOW=0(どちらでも指定可能)  
  
・ digitalWrite(pin,stat)  
指定したピンの出力状態を設定する。  
HIGH=1/LOW=0(どちらでも指定可能)  
  
・ pinMode(pin,mode)  
指定したピンの入出力ステートを設定する。  
INPUT=1/OUTPUT=0  
  
・ delay(t)  
指定した時間待つ。  
(Sleepのラッパ関数。ついでに忘れがちなメモリ解放も行う。)  
  
・ setTris(TRIS)  
pio形式(1bit)の入出力設定を、2bit形式に変換する。  
0→01  
1→10  
  
・lcdInit(i2cadr)  
I2C液晶を初期化する。  
i2cadrはアドレス。省略すると0x7C(秋月I2C液晶)  
  
・lcdCont(cont,boost)  
コントラストを設定する。  
cont:コントラスト(0x00～0x3F)  
boost:倍電圧回路の有効無効  
  
・lcdPrint(s)  
指定した文字列を送信する。  
改行処理は行わない。  
  
・lcdClear()  
画面を消去する。  
  
・lcdPos(x,y)  
指定した位置にカーソルを移動する。  
  
・lcdData(data)  
データを1バイト送信する。  
  
・lcdCommand(data)  
コマンドを1バイト送信する。  
  
利用は自己責任で。