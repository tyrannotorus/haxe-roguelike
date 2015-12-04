package com.tyrannotorus.bubblebobble.utils;

import motion.Actuate;

class Colors {
	
	public static var TRANSPARENT:Int = 0x00000000;
	public static var MAGENTA:Int = 0xFFFF00FF;
	public static var WHITE:Int = 0xFFFFFFFF;
	public static var BLACK:Int = 0xFF000000;
	public static var YELLOW:Int = 0xFFFFFF00;
	public static var CYAN:Int = 0xFF00FFFF;
	public static var GREEN:Int = 0xFF00FF00;
	
	/**
	 * Tweens the color of an object, with on optional callback function on complete
	 * @param	object
	 * @param	callBackFunction
	 */
	public static function tweenColor(object:Dynamic, callBackFunction:Dynamic = null):Void {
		var i:Int = Math.floor(Math.random() * Constants.colors.length);
		Actuate.transform(object, 1).color(Constants.colors[i], 0.5).onComplete(callBackFunction);
	}
	
	/**
	* Parses hex string to equivalent integer, with safety checks
	* From:  haxe-flx-ui/flixel/addons/ui/U.hx
	* @param {String} str - In format 0xRRGGBB or 0xAARRGGBB
	* @return {Int}
	*/
	public static inline function hexToInt(str:String, cast32Bit:Bool=false):Int {
		if (str.indexOf("0x") != 0) { //if it doesn't start with "0x"
			throw "U.parseHex() string(" + str + ") does not start with \"0x\"!";
		}
		if (str.length != 8 && str.length != 10) {
			throw "U.parseHex() string(" + str + ") must be 8(0xRRGGBB) or 10(0xAARRGGBB) characters long!";
		}	
		str = str.substr(2, str.length - 2); //chop off the "0x"
		if (cast32Bit && str.length == 6) { //add an alpha channel if none is given and we're casting
			str = "FF" + str;
		}
		return convertHexToInt(str);
	}

	/**
	* Parses hex string to equivalent integer
	* From:  haxe-flx-ui/flixel/addons/ui/U.hx
	* @param hex_str string in format RRGGBB or AARRGGBB (no "0x")
	* @return integer value
	*/
	private static inline function convertHexToInt(hexString:String):Int {
		var length:Int = hexString.length;
		var place_mult:Int = 1;
		var sum:Int = 0;
		var i:Int = length - 1;
		while (i >= 0) {
			var char_hex:String = hexString.substr(i, 1);
			var char_int:Int = hexChar2dec(char_hex);
			sum += char_int * place_mult;
			place_mult *= 16;
			i--;
		}
		return sum;
	}

	/**
	* Parses an individual hexadecimal string character to the equivalent decimal integer value
	* From:  haxe-flx-ui/flixel/addons/ui/U.hx
	* @param hex_char hexadecimal character (1-length string)
	* @return decimal value of hex_char
	*/
	public static inline function hexChar2dec(hex_char:String):Int {
		var val:Int = -1;
		switch(hex_char) {
			case "0","1","2","3","4","5","6","7","8","9","10":val = Std.parseInt(hex_char);
			case "A","a": val = 10;
			case "B", "b": val = 11;
			case "C", "c": val = 12;
			case "D", "d": val = 13;
			case "E", "e": val = 14;
			case "F", "f": val = 15;
		}
		if(val == -1){
			throw "U.hexChar2dec() illegal char(" + hex_char + ")";
		}
		return val;
	}

}
