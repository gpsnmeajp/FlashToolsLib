AE_FAIO_HTTP_IO  
Webブラウザやjavascriptから、秋月ＦｌａｓｈＡｉｒ ＤＩＰ ＩＯボードキット(K-10007 AE-FAIO)の出力を扱うのって  
意外と大変です。Luaスクリプトを書かなければなりません。  
  
FlashAir内臓のcommand.cgi互換の動作をするLuaスクリプトも作成しましたが、お世辞にも扱いやすいとはいえません。  
http://gpsnmeajp.blogspot.com/2016/04/flashair-dip-ioae-faio.html?spref=tw  
  
そこで、より簡易にIOポートを操作できるLuaスクリプト群を作成しました。  
  
構造を見るとわかりますが、使い方は非常に簡単です。  
出力したいポートのdigitalWriteを呼び出せば、その出力に。  
 http:/flashair/AE_FAIO_HTTP_IO/digitalWrite/0/HIGH.lua  
  
入力したいポートをdigitalReadを呼び出せば、状態が0/1で帰ってきます。  
 http:/flashair/AE_FAIO_HTTP_IO/digitalRead/0.lua  
  
簡単のためpinModeは自動で切り替わります。  
  
おまけで、lcd出力機能も搭載しています。print.lua?Hello%0AFlashAirのように指定するだけで、文字が出ます。  
 http:/flashair/AE_FAIO_HTTP_IO/lcd/print.lua?Hello%0AFlashAir  
  
例によって、自動セットアップ機能もついています。  
  
  
  
  
構造は以下のようになっています。  
└─AE_FAIO_HTTP_IO  
   ├─common  
   │  ├─libs  
   │  └─module  
   ├─digitalRead  
   │  ├─0.lua  
   │  ├─1.lua  
   │  ├─2.lua  
   │  └─3.lua  
   ├─digitalWrite  
   │  ├─0  
   │  │ ├HIGH.lua  
   │  │ └LOW.lua  
   │  ├─1  
   │  │ ├HIGH.lua  
   │  │ └LOW.lua  
   │  ├─2  
   │  │ ├HIGH.lua  
   │  │ └LOW.lua  
   │  └─3  
   │     ├HIGH.lua  
   │     └LOW.lua  
   └─lcd  
       ├─clear.lua  
       └─print.lua  
  
使い方は、同梱のhelp.htmを参照してください。  
  
※使用前にFlashAir本体のアップデートが必要です！  
（最近購入されたものでも例外なくアップデートの確認をしてください)