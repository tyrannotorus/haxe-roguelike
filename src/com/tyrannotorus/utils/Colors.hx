package com.tyrannotorus.utils;

import openfl.Vector;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

/**
 * Color.as
 * An assortment of colors and color utils.
 */
class Colors {
	
	public static inline var TRANSPARENT:Int = 0x00000000;
	public static inline var BLACK:Int = 0xFF000000;
	public static inline var WHITE:Int = 0xFFFFFFFF;
	public static inline var MAGENTA:Int = 0xFFFF00FF;
	public static inline var YELLOW:Int = 0xFFFFFF00;
	public static inline var CYAN:Int = 0xFF00FFFF;
	public static inline var FUCHSIA:Int = 0xFFFF3366;
	public static inline var PALE_FUCHSIA:Int = 0xFFCC6680;
	public static inline var LIGHT_GREY:Int = 0xFFCCCCCC;
	public static inline var DARK_GREY:Int = 0xFF333333;
	public static inline var DUSTY_GREY:Int = 0xFF999999;
	public static inline var RED:Int = 0xFFFF0000;
	public static inline var PIZAZZ:Int = 0xFFFF9600; // Orangish
	public static inline var SCHOOL_BUS_YELLOW:Int = 0xFFFFCC00;
	public static inline var GREEN_APPLE:Int = 0xFF33CC33;
	public static inline var AQUA:Int = 0xFF27F2FF;
	public static inline var KLEIN_BLUE:Int = 0xFF0033CC;
	public static inline var SCIENCE_BLUE:Int = 0xFF0077DD;
	public static inline var MIDNIGHT_BLUE:Int = 0xFF002060;
	public static inline var MEDIUM_PURPLE:Int = 0xFF9C4FEB;
	public static inline var BUBBLEGUM:Int = 0xFFFF6089;
	public static inline var BRIGHT_RED:Int = 0xFFAA0000;
	public static inline var TUATARA:Int = 0xFF343432; // Dark greyish
	public static inline var SILVER:Int = 0xFFAAAAAA;
	public static inline var MELROSE:Int = 0xFF9999FF;
	public static inline var LOCHMARA:Int = 0xFF0084D2; // Lagoon blue
	public static inline var GALLERY:Int = 0xFFEAEAEA; // Light silver
	public static inline var MILAN:Int = 0xFFFEFFA4;
	public static inline var GARYS_PINK_LACE:Int = 0xFFFFCFE9;
	public static inline var BLUE:Int = 0xFF0000FF;
	public static inline var TILE_GREEN:Int = 0xFF005D28;
	//public static inline var TILE_GREEN:Int = 0xFF007B2C;
	
	
	public static var ACTOR_SHADOW:Int = setAlpha(BLACK, 0.3);
	public static var TILE_HIGHLIGHT:UInt = setAlpha(PIZAZZ, 0.7);
	public static var TILE_OFFSET_COLOR:UInt = setAlpha(BLACK, 0.08);

	/**
	 * Converts an Int color (like those in this class) to a 16 bit hex string.
	 * @param {Int} color
	 * @return {String}
	 */
	public static function intToHex(intColor:Int):String {
		var hexColor:String = StringTools.hex(intColor, 16);
		while (hexColor.length < 6) {
			hexColor = "0" + hexColor;
		}
		hexColor = "#" + hexColor.toUpperCase();
		return hexColor;
	}
	
	/**
	 * Set the alpha for a 32-bit color by a decimal. Return the new color.
	 * @param {Int} color
	 * @param {Float} alpha
	 * @return {Int}
	 */
	public static function setAlpha(color:Int, alpha:Float = 1):Int {
		var rgb:Int = 0xFFFFFF & color;
		var argb:Int = cast(alpha * 255, Int) << 24 | rgb;
		return argb;
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
	
	/**
	* Tints and returns a copy of the bitmapData.
	* @param {BitmapData} bmd
	* @param {Int} color (32-bit)
	* @return {BitmapData}
	*/
	public static inline function tintBitmapData(bmd:BitmapData, color:Int):BitmapData {
				
		var tintAmount:Float = (color >> 24 & 0xFF) / 255;
		var origAmount:Float = 1 - tintAmount;
		var tintR:Int = cast((color >> 16 & 0xFF) * tintAmount, Int);
		var tintG:Int = cast((color >> 8 & 0xFF) * tintAmount, Int);
		var tintB:Int = cast((color & 0xFF) * tintAmount, Int);
		
		var rect:Rectangle = bmd.rect;
		var bmdWidth:Int = Math.floor(rect.width);
		var bmdHeight:Int = Math.floor(rect.height);
		
		var bmdVector:Vector<UInt> = bmd.getVector(rect);
		var idxPixel:Int = 0;
		for(yPosition in 0...bmdHeight) {
			for (xPosition in 0...bmdWidth) {
				if (bmdVector[idxPixel] != TRANSPARENT) {
					var pixelColor:UInt = bmdVector[idxPixel];
					var a:Int = pixelColor >> 24 & 0xFF;
					var r:Int = cast(tintR + ((pixelColor >> 16 & 0xFF) * origAmount), Int);
					var g:Int = cast(tintG + ((pixelColor >> 8 & 0xFF) * origAmount), Int);
					var b:Int = cast(tintB + ((pixelColor & 0xFF) * origAmount), Int);
					bmdVector[idxPixel] = a << 24 | r << 16 | g << 8 | b;
				}
				idxPixel++;
			}
		}
		
		var tintBmd:BitmapData = new BitmapData(bmdWidth, bmdHeight, true);
		tintBmd.setVector(rect, bmdVector);
		
		return tintBmd;
	}
		
	

}
