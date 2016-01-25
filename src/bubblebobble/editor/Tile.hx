package bubblebobble.editor;

import com.tyrannotorus.utils.Colors;
import motion.Actuate;
import openfl.display.Bitmap;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.Vector;

/**
 * Tile.hx.
 * - A game tile.
 */
class Tile extends Sprite {
	
	public var bitmapStack:Array<Bitmap>;
	public var tileName:String;
	public var tilesContainer:Sprite;
	public var stackable:Bool = true;
	public var tinted:Bool = false;
	
	/**
	 * Constructor.
	 */
	public function new(tileName:String = null, buttonMode:Bool = false) {
		
		super();
		
		tilesContainer = new Sprite();
		addChild(tilesContainer);
		
		this.tileName = tileName;
		this.buttonMode = buttonMode;
		this.mouseChildren = false;
		this.cacheAsBitmap = true;
		
		this.addEventListener(MouseEvent.ROLL_OUT, onTileRollOut);
		this.addEventListener(MouseEvent.ROLL_OVER, onTileRollOver);
	}
	
	public function createTileFromBitmap(tileBitmap:Bitmap):Void {
		
		if (tileBitmap.bitmapData == null) {
			return;
		}
		
		var tileRect:Rectangle = tileBitmap.bitmapData.rect;
		var tileVector:Vector<UInt> = tileBitmap.bitmapData.getVector(tileRect);
		var tileWidth:Int = cast(tileRect.width, Int);
		var tileHeight:Int = cast(tileRect.height, Int);
		var idxPixel:Int = 0;
		
		for(yPosition in 0...tileHeight) {
		
			for (xPosition in 0...tileWidth) {
				
				if (tileVector[idxPixel] != Colors.TRANSPARENT) {
					tilesContainer.graphics.beginFill(tileVector[idxPixel], 1);
					tilesContainer.graphics.drawRect(xPosition, yPosition, 1, 1);
					tilesContainer.graphics.endFill();
				}
				idxPixel++;
			}
		}
		
		tilesContainer.x = -tileRect.width / 2;
		tilesContainer.y = -tileRect.height / 2;
	}
	
	private function onTileRollOver(e:MouseEvent):Void {
		highlight(true);
	}
	
	private function onTileRollOut(e:MouseEvent):Void {
		highlight(false);
	}
	
	public function increaseHeight():Void {
		/*
		if (stackable && bitmapStack.length > 0) {
			var lastTile:Bitmap = bitmapStack[bitmapStack.length - 1];
			var newTile:Bitmap = new Bitmap(lastTile.bitmapData);
			newTile.y = lastTile.y - (lastTile.height - (lastTile.width/2));
			bitmapStack.push(newTile);
			tilesContainer.addChild(newTile);
		}*/
	}
	
	public function reduceHeight():Void {
		/*trace("reduceHeight()");
		if (stackable && bitmapStack.length > 0) {
			var lastTile:Bitmap = bitmapStack.pop();
			tilesContainer.removeChild(lastTile);
		}*/
	}
	
	public function highlight(value:Bool):Void {
		
		// Highlight this tile.
		if (value == true) {
			Actuate.transform(tilesContainer).color(0x116611, 0.50);
		
		// Return tile to tinted state.	
		} else if (tinted == true) {
			Actuate.transform(tilesContainer).color(0x101010, 0.50);
		
		// Return tile to untinted state.
		} else {
			Actuate.transform(tilesContainer).color(0x000000, 0);
		}
	}
	
	public function tint(color:Int, amount:Float):Void {
		Actuate.transform(tilesContainer).color(0x101010, 0.50);
		tinted = true;
	}
	
	public function clone(tileToClone:Tile = null):Tile {
		
		// We're cloning the tile parameter.
		if (tileToClone != null) {
			tileName = tileToClone.tileName;
			tilesContainer.graphics.copyFrom(tileToClone.tilesContainer.graphics);
			tilesContainer.x = tileToClone.tilesContainer.x;
			tilesContainer.y = tileToClone.tilesContainer.y;
			return this;
		
		// We're returning a clone of ourself. 
		} else {
			var clonedTile:Tile = new Tile(tileName);
			clonedTile.tilesContainer.graphics.copyFrom(tilesContainer.graphics);
			clonedTile.tilesContainer.x = tilesContainer.x;
			clonedTile.tilesContainer.y = tilesContainer.y;
			return clonedTile;
		}
	}
}
