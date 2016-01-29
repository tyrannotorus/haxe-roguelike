package roguelike.editor;

import com.tyrannotorus.utils.Colors;
import openfl.display.Bitmap;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.Vector;

/**
 * Tile.hx.
 * - A game tile.
 */
class Tile extends Sprite {
	
	public var tileData:TileData;
	public var bitmapStack:Array<Bitmap>;
	public var tilesContainer:Sprite;
	public var tileBitmap:Bitmap;
	public var tintBitmap:Bitmap;
	public var highlightBitmap:Bitmap;
	public var hitSprite:Sprite;
	public var stackable:Bool = true;
		
	/**
	 * Constructor.
	 */
	public function new(tileData:TileData) {
		
		super();
		
		this.tileData = tileData;
		
		
		
		tilesContainer = new Sprite();
		tilesContainer.mouseChildren = false;
		tilesContainer.mouseEnabled = false;
		
		tileBitmap = new Bitmap(tileData.tileBmd);
		tilesContainer.addChild(tileBitmap);
		
		tintBitmap = new Bitmap(tileData.tintBmd);
		tintBitmap.visible = false;
		tilesContainer.addChild(tintBitmap);
		
		highlightBitmap = new Bitmap(tileData.highlightBmd);
		highlightBitmap.visible = false;
		tilesContainer.addChild(highlightBitmap);
		
		tilesContainer.x = -tileBitmap.width / 2;
		tilesContainer.y = -tileBitmap.height / 2;
		
		addChild(tilesContainer);
				
		// HitAreas only work in flash apparently.
		#if flash
			hitSprite = new Sprite();
			hitSprite.graphics.copyFrom(tileData.hitSprite.graphics);
			hitSprite.mouseEnabled = false;
			hitSprite.visible = false;
			hitSprite.x = tilesContainer.x;
			hitSprite.y = tilesContainer.y;
			addChild(hitSprite);
			this.hitArea = hitSprite;
		#end
				
		this.mouseChildren = false;
		this.cacheAsBitmap = true;
		this.blendMode = BlendMode.LAYER;
		
		if (tileData.fileName == "empty.png") {
			tileBitmap.bitmapData = null;
			tintBitmap.bitmapData = null;
		}
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
		highlightBitmap.visible = value;
	}
	
	/**
	 * Use the tinted bitmap for the tile.
	 * @param {Bool} value
	 */
	public function tint(value:Bool = true):Void {
		tintBitmap.visible = value;
		tileBitmap.visible = !value;
	}
	
	/**
	 * Clone a tile, or return a clone of ourself.
	 * @param {Tile} tile
	 * @return {Tile}
	 */
	public function clone(tile:Tile = null):Tile {
		
		// We're cloning the tile parameter.
		if (tile != null) {
			this.tileData = tile.tileData;
			tileBitmap.bitmapData = this.tileData.tileBmd;
			tintBitmap.bitmapData = this.tileData.tintBmd;
			highlightBitmap.bitmapData = this.tileData.highlightBmd;
			tilesContainer.x = tile.tilesContainer.x;
			tilesContainer.y = tile.tilesContainer.y;
			
			#if flash
				hitSprite.graphics.copyFrom(this.tileData.hitSprite.graphics);
				hitSprite.x = tile.hitSprite.x;
				hitSprite.y = tile.hitSprite.y;
				this.hitArea = hitSprite;
			#end
			
			return null;
		
		// We're returning a clone of ourself. 
		} else {
			return new Tile(tileData);
		}
	}
}
