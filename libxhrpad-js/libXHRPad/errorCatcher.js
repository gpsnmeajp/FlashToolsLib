	//スマートフォン上など、コンソール外でもエラーをキャッチできる。
	window.onerror = function (message, url, line, column, errorObj) {
		alert("--- javascript error ---\nmessage : " + message
			+ "\nurl : " + url
			+ "\nline : " + line 
			+ "\ncolumn : " + column 
 			+ "\nerror : " + (errorObj ? errorObj.stack : ""));
		return true; 
	};