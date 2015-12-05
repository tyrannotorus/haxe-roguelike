package bubblebobble.dialogs;

import bubblebobble.MatteData;
import com.tyrannotorus.utils.Colors;

/**
 * DialogObject.hx.
 * Includes all aspects of matteData, and additional properties related to dialogs.
 * DialogData for use when constructing GenericDialogs.hx.
 */
class DialogData extends MatteData {
	
	public var headerText:String = "Generic Dialog";
	public var headerTextColor:Int = Colors.WHITE;
	public var headerTextShadowColor:Int = Colors.TRANSPARENT;
	public var headerMatteColor:Int = Colors.MIDNIGHT_BLUE;
	public var headerBorderColor:Int = Colors.TRANSPARENT;
	public var headerHeight:Int = 16;
	
	
			
	/**
	 * Constructor.
	 * @param {Dynamic} parameters
	 */
	public function new(parameters:Dynamic = null) {
		
		super(parameters);
		
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
