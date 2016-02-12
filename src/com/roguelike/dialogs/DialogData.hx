package com.roguelike.dialogs;

import com.roguelike.MatteData;
import com.tyrannotorus.utils.Colors;

/**
 * DialogObject.hx.
 * Includes all aspects of matteData, and additional properties related to dialogs.
 * DialogData for use when constructing GenericDialogs.hx.
 */
class DialogData extends MatteData {
	
	public var headerText:String = "Generic Dialog";
	public var headerTextColor:Int = Colors.WHITE;
	public var headerTextShadowColor:Int = Colors.BLACK;
	public var headerMatteColor:Int = Colors.MIDNIGHT_BLUE;
	public var headerBorderColor:Int = Colors.TRANSPARENT;
	public var headerHeight:Int = 16;
	public var dialogPositionX:Float = 0.5;
	public var dialogPositionY:Float = 0.5;
				
	/**
	 * Constructor.
	 * @param {Dynamic} parameters
	 */
	public function new(parameters:Dynamic = null) {
		
		super(parameters);
		
		// Set up the default dialog shadow.
		shadowColor = Colors.setAlpha(Colors.BLACK, 0.4);
		shadowOffsetX = 4;
		shadowOffsetY = 6;
		
		// No parameters were passed. Use default values.
		if (parameters == null) {
			return;
		}
		
		// Set our local variables according the the parameters parameter.
		for (fieldName in Reflect.fields(parameters)) {

			if (!Reflect.hasField(this, fieldName)) {
				trace("DialogData.new() Uknown parameter " + fieldName + " passed.");
				continue;
			}
			
			Reflect.setField(this, fieldName, Reflect.field(parameters, fieldName));
		}
	}
}
