"use strict"; //C言語並みの文法チェックを有効化

/*
 * ～　処理落ちのない快適なゲームをあなたに　～
 * libXHRPad.js v0.18
 *  
 * このコードは3条項BSDライセンスとします。
 * FlashAir

Copyright (c) 2016, GPS_NMEA (@Seg_faul)
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


--日本語訳--
Copyright (c) 2016, GPS_NMEA (@Seg_faul)
All rights reserved.

ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に限り、再頒布および使用が許可されます。

1.ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
2.バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
3.書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、本ソフトウェアの名前またはコントリビューターの名前を使用してはならない。

本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、明示黙示を問わず、商業的な使用可能性、
および特定の目的に対する適合性に関する暗黙の保証も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューターも、
事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失その他の）不法行為であるかを問わず、
仮にそのような損害が発生する可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サービスの調達、使用の喪失、データの喪失、
利益の喪失、業務の中断も含め、またそれに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害について、一切責任を負わないものとします。

*/

var xhrPad = (function () {
	var request = new XMLHttpRequest();

	var res = {"STATUS":"OK","CTRL":"0x00","DATA":"0x1F"}; //初期化
	var db_all_start_time = new Date();
	var requset_timeout = 600;

	var started = false;

	var db_xhr_start = new Date();
	var db_xhr_end = 0;
	var db_xhr_time = 0;
	var db_sum_xhr_time = 0;
//	var db_cnt = 0;
	var db_request_ok = 0;
	var db_request_err = 0;
	var db_request_cnt = 0;
	var db_request_timeout = 0;
	var db_request_err_cont = 0;
	
	var db_not_include_of_time = true;
	
	var old_keys;
	var old_keys_bool;
	var old_keys_callback;
	
	var key_pressed_callback;
	
	//通信失敗時はなにか起きてることが多いのであえてディレイを入れる。
	var err_delay = 40;
	var suc_delay = 5;
	

	var read_pad = function(){
		return {
			"up": ((res.DATA & 0x07)==0x6),
			"down": ((res.DATA & 0x07)==0x5),
			"left": ((res.DATA & 0x07)==0x1),
			"right": ((res.DATA & 0x07)==0x2),
			"b": ((res.DATA & 0x10)==0x0),
			"a": ((res.DATA & 0x08)==0x0)
		};
	};
	
	var call_backer = function(){
		if(key_pressed_callback == null) //コールバック関数が設定されてなければ無用
		{
			return;
		}

		if(old_keys_callback == null){
			old_keys_callback = read_pad();
		}
		var keys = read_pad();
		var changedKeys = {
			"up": (old_keys_callback.up != keys.up),
			"down": (old_keys_callback.down != keys.down),
			"left": (old_keys_callback.left != keys.left),
			"right": (old_keys_callback.right != keys.right),
			"b": (old_keys_callback.b != keys.b),
			"a":(old_keys_callback.a != keys.a) 
		};
		old_keys_callback = keys;
		
		for (var key in changedKeys) {
			if (changedKeys.hasOwnProperty(key)) {
				if((changedKeys[key])&&(keys[key])) //変化があり、そして押されている時
				{
					try{
						key_pressed_callback(key);
					}catch (e) {
						console.log("Callback: Call failed");
						console.log(e);
					}
				}
			}
		}
	}
	
	var pad_getter = function(){
		if(!started){
			db_not_include_of_time = true;
			return;
		}
		
		db_xhr_end = new Date();
		var db_xhr_time = db_xhr_end.getTime() - db_xhr_start.getTime();

		if(!db_not_include_of_time){ //エラーは含まない。
//		db_sum_xhr_time += db_xhr_time;
			db_sum_xhr_time = db_sum_xhr_time * 0.90 + db_xhr_time * 0.10;
		}else{
			db_not_include_of_time = false; //毎度解除する
		}
		db_xhr_start = new Date();
		
		//受信処理イベント
		//メモ: AddEventListenerを使ったらブラクラと化した
		request.onloadend=function(){
			if(request.status == 200){
			//success
				var tmp_res;
				try{
					tmp_res = JSON.parse(request.responseText);					
				}catch (e) {
					tmp_res = res; //JSON解釈できなかった時は1つ前の情報を保持
				}
				res = tmp_res;

				db_request_ok++;
				db_request_err_cont = 0;
				setTimeout(pad_getter, suc_delay);
				call_backer(); //コールバック処理		
			}else{
				//fail - ex.504
				db_request_err++;
				db_request_err_cont++;
				db_not_include_of_time = true;
				setTimeout(pad_getter, err_delay);				
			}
		};
		//タイムアウトイベント(リトライ処理はstatus==0で行われるのでこっちではしない)
		request.ontimeout = function () {
			db_request_timeout++;
			db_not_include_of_time = true;
		};
		
		
		//非同期要求
		var url = "/command.cgi?op=190&CTRL=0x00&DATA=0x00&TIME="+(new Date().getTime());
		
		request.open("GET", url);
		request.timeout = requset_timeout; //200msをタイムアウトに
		request.send(null);

		db_request_cnt++;
	};

//----ソースにリファレンス----
    return {
		//public
		
		//通信処理および状態取得
		
		//タイマーを起動し、非同期取得処理を開始します。
		start: function( bar ) {
			if(!started){
				setTimeout(pad_getter, 1);
				started = true;
			}
		},
		//非同期取得処理を停止します。
		stop: function( bar ) {
			started = false;
		},
		
		//FlashAirでのエラー情報を確認できます。
		//ゲーム中で注意喚起をする場合などで使えます。
		//ホスト機器に刺さっている場合
		isSDErr: function(){
			return (res.STATUS == "SDERR");
		},
		//IFMODEが1ではない場合。
		isConfigErr: function(){
			return (res.STATUS == "CONFIGERR");
		},

		//パッドの生情報を取得します。
		//DATA項目まんまです。互換性のために用意していますが、
		//基本的には下部のreadPadを利用することをおすすめします。
		readRaw: function(){
			return res.DATA;
		},
		
		//読み込みにかかった平均時間を取得します。
		//v0.17より、ローパスフィルタ方式にしました。これにより長時間の際に異常値にならずに済むはずですが、
		//代わりに開始から十秒ほどは信頼出来ない値を吐きます。
		//基本、PCの場合で80ms、iPadで50msほどでした。
		//FlashAirへの接続台数*20 + 80と考えるといいようです。
		getAverageTimeMs: function(){
//			return Math.round(db_sum_xhr_time/db_request_cnt);
			return Math.round(db_sum_xhr_time);
		},
		
		//通信エラーの積算回数を取得します。
		//割と増えますが、基本的に問題ありません。
		getErrorCount: function(){
			return db_request_err;
		},
		
		//連続したエラー回数を取得します。
		//これが3を超えると不安定、50を超えると確実に切断されています。
		//接続が落ちた際のゲームの中断などに。
		getContinuousErrorCount: function(){
			return db_request_err_cont;
		},
		
		//タイムアウト時間を設定します。
		//基本的に200msですが、回線状態が悪い場合は長くすると安定します。
		setTimeout: function(t){
			requset_timeout = t;
		},

		//追加ディレイ時間を設定します。
		//通常だとFlashAirがリクエストに溺れて、IO以外のコンテンツが処理できなくなるため
		//動的にコンテンツを読み込む場合などはsetAddDelay(500)などしてあげると溺れなくなります。
		//ただしボタンに対する反応が悪くなります。
		setAddDelay: function(t){
			err_delay = 40 + t;
			suc_delay = 5 + t;
		},

		//パッド情報

		//現在のパッドの情報をオブジェクトで返却します。
		//var key = read_pad();のように受け取り、
		//key.a、key.b、key.up、key.down、key.left、key.rightとboolで取り出せます。
		read: function(){
			return read_pad();
		},
		
		//何らかのキーが押されているかどうかboolで返却します。
		isAnyKey: function(){
			var keys = read_pad();
			return (keys.up||keys.down||keys.left||keys.right||keys.b||keys.a);
		},
		
		//パッドの情報の変化をオブジェクトで返却します。
		//範囲は、前回readPadChangedを呼び出した時から、次にreadPadChangedを呼び出すまでの間です。
		//立ち上がり、あるいは、立ち下がりを検出した場合に各キーがtrueになります。
		//チョン押しを検出したい場合にどうぞ。
		readChanged: function(){
			if(old_keys == null){
					old_keys = read_pad();
			}
			var keys = read_pad();
			var changedKeys = {
				"up": (old_keys.up != keys.up),
				"down": (old_keys.down != keys.down),
				"left": (old_keys.left != keys.left),
				"right": (old_keys.right != keys.right),
				"b": (old_keys.b != keys.b),
				"a":(old_keys.a != keys.a) 
			};
			old_keys = keys;
			
			return changedKeys;
		},

		//パッドの情報の変化をbool値で返します。
		//範囲は、前回isPadChangedを呼び出した時から、次にisPadChangedを呼び出すまでの間です。
		//立ち上がり、あるいは、立ち下がりを検出した場合に各キーがtrueになります。
		isChanged: function(){
			if(old_keys_bool == null){
					old_keys_bool = read_pad();
			}
			var keys = read_pad();
			var change_flag =  ((old_keys_bool.up != keys.up)||(old_keys_bool.down != keys.down)||(old_keys_bool.left != keys.left)||(old_keys_bool.right != keys.right)||(old_keys_bool.b != keys.b)||(old_keys_bool.a != keys.a));
			old_keys_bool = keys;
			
			return change_flag;
		},
		
		setKeyPressedCallback: function(func){
			key_pressed_callback = func;
		}

	};
})();


