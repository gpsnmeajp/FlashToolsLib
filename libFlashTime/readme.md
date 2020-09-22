FlashAirのRTCを使う  
FlashAirにはRTC(リアルタイムクロック)が積まれているようです。  
これを使用すると、通常Luaから操作すると空白になるファイル変更日時を、任意の時刻に設定できます。  
また、FlashAirが起動している間、設定した任意の時刻から2秒ごとに時間を刻みます。  
  
これを設定するには、通常、upload.cgiの機能を使うのでしょうが、隠し関数fa.SetCurrentTimeにて同じことが出来ましたので  
それをLuaスクリプトから扱うライブラリlibFlashTimeとサンプルを作りました。  
  
ファイルの更新日時(例えばデジカメの撮影日時)を、実際の日時情報に変換する機能付きです。  
  
PR(私の作成したFlashAirの開発が便利になるツール)  
FlashTools Tiny Lua Editor  
FlashAir Unofficial Configurator  
FlashTools GPIO Tester & Checker  
  
---サンプル---  
--libFlashTimeを取り込む。好きな変数に取り込むことができる(Luaの仕様)  
t = require "libFlashTime"  
  
--現在時刻を表示する  
t.ShowTime();  
  
--任意の時間をRTCに書き込む。電源を切るまで有効(スクリプトが終了しても動き続ける)  
t.SetTime(2009,5,30,8,30,00);  
--現在時刻を表示する  
t.ShowTime();  
  
--現在時刻を得る(一時的にファイルを生成→更新時間を取得→削除している)  
Year,Month,Day,Hour,min,sec = t.GetTime();  
print(Year.."年"..Month.."月"..Day.."日"..Hour.."時"..min.."分"..sec.."秒");  
  
-- ※ファイルを生成せずに(Flashの寿命を縮めずに)、時刻を取得できることがわかりました。  
-- こちらを参照 : 電子工作記録: FlashAirのレジスタから時刻を得る   
-- http://gpsnmeajp.blogspot.com/2016/06/flashair.html?spref=tw  
  
--NICT 国立研究開発法人 情報通信研究機構の日本標準時配信サーバー(HTTP版)を使って時刻合わせする。(要STAモード)  
t.SetNICT();  
t.ShowTime();  
  
sleep(10000);  
t.ShowTime();  
  
--FAT形式のファイルタイムスタンプを生成する  
fattime,fattime2 = t.GetFATtimeFromLocalTime(2009,5,30,8,30,00);  
print(fattime,fattime2);  
  
--FAT形式のファイルタイムスタンプから時刻に変換する  
--通常は以下のようにLuaFSから得た日時を変換する(撮影日時の取得など)  
--Year,Month,Day,Hour,min,sec = t.GetLocalTimeFromFATtime(file.modification);  
  
--ここでは先ほど生成したタイムスタンプを結合して渡している。  
Year,Month,Day,Hour,min,sec = t.GetLocalTimeFromFATtime(bit32.bor(bit32.lshift(fattime,16),fattime2));  
print(Year.."年"..Month.."月"..Day.."日"..Hour.."時"..min.."分"..sec.."秒");  
  
--[[  
実行結果は以下のようになる  
1980年0月0日0時0分0秒2009年5月30日8時30分0秒2009年5月30日8時30分0秒2015年12月19日23時42分12秒2015年12月19日23時42分22秒15038	173442009年5月30日8時30分0秒  
時刻情報が残っていると以下のようになる。  
2015年12月19日22時59分44秒2009年5月30日8時30分0秒2009年5月30日8時30分0秒2015年12月19日22時59分44秒2015年12月19日22時59分54秒15038	173442009年5月30日8時30分0秒  
]]--  
更新履歴v0.1 公開v0.2 NICTサーバーへの接続時、10回ほど再試行するように。　　　文字コードをUTF-8に。  
