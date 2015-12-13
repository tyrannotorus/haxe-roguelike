package bubblebobble.editor;

import bubblebobble.editor.LevelEditor;
import openfl.display.Bitmap;
import openfl.display.Sprite;

/**
 * Tile.hx.
 * - A game tile.
 */
class Tile extends Sprite {
	
	public var bitmap:Bitmap;
					
	/**
	 * Constructor.
	 */
	public function new(tileName:String = null, tileBitmap:Bitmap = null, buttonMode:Bool = false) {
		
		super();
		
		addChild(bitmap = new Bitmap());
		
		this.buttonMode = buttonMode;
		
		if (tileName != null && tileBitmap != null) {
			update(tileName, tileBitmap);
		}
	}
	
	public function update(tileName:String, tileBitmap:Bitmap) {
		name = tileName;
		bitmap.bitmapData = tileBitmap.bitmapData;
	}
	
	public function clone(tile:Tile = null):Tile {
		
		// We're cloning the parameter.
		if (tile != null) {
			update(tile.name, tile.bitmap);
			return this;
		
		// We're returning a clone of ourself. 
		} else {
			return new Tile(name, bitmap);
		}
	}
}
