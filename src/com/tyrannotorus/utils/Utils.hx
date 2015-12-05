package com.tyrannotorus.utils;

import bubblebobble.Main;
import openfl.display.DisplayObject;
import openfl.geom.Rectangle;

class Utils {
	
	public static function centerX(displayObject:DisplayObject):Int {
		var bounds:Rectangle = displayObject.getRect(displayObject);
		return Std.int((Main.GAME_WIDTH - bounds.width) * 0.5);
	}
	
	public static function centerY(displayObject:DisplayObject):Int {
		var rect:Rectangle = displayObject.getRect(displayObject);
		return Std.int((Main.GAME_HEIGHT - rect.height) * 0.5);
	}
	
	public static function sortAlphabetically(a:String, b:String):Int {
        a = a.toLowerCase();
        b = b.toLowerCase();
       
        if (a < b) return -1;
        if (a > b) return 1;
        return 0;
    }
	
	/**
	 * Positions a display object on the screen
	 * @param {DisplayObject} displayObject
	 * @param {Dynamic} x
	 * @param {Dynamic} y
	 */
	public static function position(displayObject:DisplayObject, x:Dynamic = null, y:Dynamic = null):Void {
		
		var rect:Rectangle = displayObject.getRect(displayObject);
		
		if (x == Constants.CENTER) {
			displayObject.x = Std.int((Main.GAME_WIDTH - rect.width) * 0.5);
		} else if (Std.is(x, Float)) {
			displayObject.x = x;
		}
		
		if (y == Constants.CENTER) {
			displayObject.y = Std.int((Main.GAME_HEIGHT - rect.height) * 0.5);
		} else if (Std.is(x, Float)) {
			displayObject.y = y;
		}
	}
	
	/**
	 * Returns field of object if it exists, otherwise returns defaultField
	 * @param	object
	 * @param	field
	 * @param	defaultField
	 * @return Dynamic
	 */
	public static function getField(object:Dynamic, field:Dynamic, defaultField:Dynamic):Dynamic {
		return Reflect.hasField(object, field) ? Reflect.field(object, field) : defaultField;
	}
	
	
	
}