package com.roguelike.dialogs;

import com.roguelike.dialogs.DraggableDialog;
import com.tyrannotorus.assetloader.AssetEvent;
import com.tyrannotorus.assetloader.AssetLoader;
import com.tyrannotorus.utils.Colors;
import com.tyrannotorus.utils.Utils;
import haxe.ds.ObjectMap;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
 * TilesDialog.hx.
 * - A draggable dialog with for use within the level editor.
 * - Loads a selection of tiles.
 */
class ContentContainer extends Sprite {
	
	private var itemsArray:Array<Array<Dynamic>>;
	private var maxWidth:Int;
	private var xPadding:Int = 2;
	private var yPadding:Int = 2;
			
	/**
	 * Constructor.
	 */
	public function new(rect:Rectangle, xPadding:Int = 2, yPadding:Int = 2) {
		
		super();
		
		itemsArray = new Array<Array<Dynamic>>();
		itemsArray.push(new Array<Dynamic>());
		maxWidth = Std.int(rect.width);
		
		this.x = rect.x;
		this.y = rect.y;
		this.xPadding = xPadding;
		this.yPadding = yPadding;
	}
	
	/**
	 * Makes the tile publically accessible.
	 * @return {Bitmap}
	 */
	public function addItem(item:Dynamic):Void {
		
		var xPosition:Int = 0;
		var yPosition:Int = 0;
		var thisItemRect:Rectangle = item.getBounds(item);
		var rowArray:Array<Dynamic> = itemsArray[itemsArray.length - 1];
		
		if (rowArray.length > 0) {
						
			var lastItem:Dynamic = rowArray[rowArray.length - 1];
			var lastItemRect:Rectangle = lastItem.getBounds(lastItem);
			xPosition = Std.int(lastItem.x + lastItemRect.width);
			yPosition = Std.int(lastItem.y + lastItemRect.y);
			
			var testWidth:Int = Std.int(lastItem.x + lastItemRect.right + xPadding + thisItemRect.width);
			var widthDifference:Int = testWidth - maxWidth;	
			
			// Make a new row.
			if (widthDifference > 0) {
				
				xPosition = 0;
								
				for (idxItem in 0...rowArray.length) {
					var testHeight:Int = Std.int(rowArray[idxItem].height/2 + rowArray[idxItem].y + yPadding);
					yPosition = (yPosition < testHeight) ? testHeight : yPosition;
				}
							
			// Append to current row.
			} else {
				xPosition = Std.int(lastItem.x + lastItemRect.right + xPadding);
			}
		}
		
		
		item.x = xPosition - thisItemRect.x;
		item.y = yPosition - thisItemRect.y;
		rowArray.push(item);
		addChild(item);
	}
	
}