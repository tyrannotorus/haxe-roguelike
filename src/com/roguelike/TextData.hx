package com.roguelike;

import com.tyrannotorus.utils.Colors;
import com.tyrannotorus.utils.Constants;
import com.roguelike.managers.TextManager;

/**
 * TextObject.hx
 * Text Object parameter for use with TextManager.hx.
 */
class TextData {
	
	public var text:String = " ";
	public var fontSet:Int = TextManager.SMALL;
	public var upColor:Int = Colors.WHITE;
	public var overColor:Int = Colors.WHITE;
	public var downColor:Int = Colors.WHITE;
	public var selectedColor:Int = Colors.WHITE;
	public var secondaryColor:Int = Colors.GALLERY;
	public var shadowColor:Int = Colors.TRANSPARENT;
	public var shadowOffsetX:Int = 0;
	public var shadowOffsetY:Int = 1;
	public var scale:Int = 1;
	public var matteMarginX:Int = 0;
	public var matteMarginY:Int = 0;
	public var typingSpeed:Float = 0.2;
		
	/**
	 * Constructor.
	 * @param {Dynamic} parameters
	 */
	public function new(parameters:Dynamic = null) {
		
		// No parameters were passed. Use default values.
		if (parameters == null) {
			return;
		}
		
		// Set our local variables according the the parameters parameter.
		for (fieldName in Reflect.fields(parameters)) {

			if (!Reflect.hasField(this, fieldName)) {
				trace("TextObject.new() Uknown parameter " + fieldName + " passed.");
				continue;
			}
			
			Reflect.setField(this, fieldName, Reflect.field(parameters, fieldName));
		}
	}
}
