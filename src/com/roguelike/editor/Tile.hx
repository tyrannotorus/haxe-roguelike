package com.roguelike.editor;

import com.tyrannotorus.utils.KeyCodes;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.utils.Object;

/**
 * Tile.hx.
 * - A game tile.
 */
class Tile extends Sprite {
	
	public var tileData:TileData;
	public var neighbourTiles:Object;
	public var tileStackArray:Array<Bitmap>;
	public var tilesContainer:Sprite;
	public var tileBitmap:Bitmap;
	//public var tintBitmap:Bitmap;
	public var highlightBitmap:Bitmap;
	public var hitSprite:Sprite;
	public var occupant:Dynamic;
	public var elevation:Int;
	public var tinted:Bool;
		
	/**
	 * Constructor.
	 */
	public function new(tileData:TileData) {
		
		super();
		
		this.tileData = tileData;
		
		neighbourTiles = { };
		
		tilesContainer = new Sprite();
		tilesContainer.mouseChildren = false;
		tilesContainer.mouseEnabled = false;
		
		tileBitmap = new Bitmap(tileData.tileBmd);
		tilesContainer.addChild(tileBitmap);
		
		//tintBitmap = new Bitmap(tileData.tintBmd);
		//tintBitmap.visible = false;
		//tilesContainer.addChild(tintBitmap);
		
		tileStackArray = new Array<Bitmap>();
		tileStackArray.push(tileBitmap);
		
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
		
		if (tileData.fileName == "empty.png") {
			tileBitmap.bitmapData = null;
			//tintBitmap.bitmapData = null;
		}
		
		elevation = tileData.elevation;
	}
	
	/**
	 * Add an occupant to this tile (Actor, Treasure, etc);
	 * @param {Dynamic} occupant
	 */
	public function addOccupant(occupant:Dynamic, x:Float = 0, y:Float = 0):Void {
		
		// Occupant already occupies tile.
		if (this.occupant == occupant) {
			return;
		}
		
		// Remove occupant from previous tile.
		if (occupant.currentTile != null) {
			occupant.currentTile.removeOccupant();
		}
		
		// Add occupant to this tile.
		this.occupant = occupant;
		occupant.x = x;
		occupant.y = y;
		occupant.currentTile = this;
		occupant.mouseEnabled = false;
		highlight(true);
		addChild(occupant);
	}
	
	/**
	 * Remove an occupant from this tile (Actor, Treasure, etc);
	 */
	public function removeOccupant():Void {
		if(occupant != null) {
			removeChild(occupant);
			highlight(false);
			occupant = null;
		}
	}
		
	/**
	 * Add or subtract elevation from tile by modifier value
	 * @param {Int} modifier
	 */
	public function addElevation(modifier:Int):Void {
		
		if (modifier == 0) {
			return;
		}
		
		var newElevation:Int = elevation + modifier;
		var elevationIncrement:Int = cast (modifier / Math.abs(modifier));
		var topTile:Bitmap;
		var newTile:Bitmap;
		
		while (elevation != newElevation) {
			
			elevation += elevationIncrement;
			
			// Adding elevation to tile.
			if (elevationIncrement > 0) {
				topTile = tileStackArray[tileStackArray.length - 1];
				newTile = new Bitmap(topTile.bitmapData);
				newTile.y = topTile.y - (topTile.height - (topTile.width/2));
				tileStackArray.push(newTile);
				tilesContainer.addChild(newTile);
			
			// Subtracting elevation from tile.	
			} else if(tileStackArray.length > 1) {
				topTile = tileStackArray.pop();
				tilesContainer.removeChild(topTile);
			}
			
		}
		
		if (occupant != null) {
			occupant.y = tileStackArray[tileStackArray.length - 1].y;
		}
		
		
		
	}
	
	public function highlight(value:Bool):Void {
		highlightBitmap.visible = value;
	}
	
	/**
	 * Use the tinted bitmap for the tile.
	 * @param {Bool} value
	 */
	public function tint(value:Bool = true):Void {
		if(tileData.elevation != -1) {
			tinted = value;
			tileBitmap.bitmapData = tileData.tintBmd;
		}
		
		//tintBitmap.visible = value;
		//tileBitmap.visible = !value;
	}
	
	public function setNeighbourTile(tile:Tile, tileKey:Int):Void {
		neighbourTiles[tileKey] = tile;
	}
	
	public function getNeighbourTile(tileKey:Int):Tile {
		return neighbourTiles[tileKey];
	}
	
	/**
	 * Clone a tile, or return a clone of ourself.
	 * @param {Tile} tile
	 * @return {Tile}
	 */
	public function clone(tile:Tile = null):Tile {
		
		// This tile is becoming a clone of the tile parameter.
		if (tile != null) {
			this.tileData = tile.tileData;
			
			if(tinted) {
				tileBitmap.bitmapData = this.tileData.tintBmd;
			} else {
				tileBitmap.bitmapData = this.tileData.tileBmd;
			}
			
			//tintBitmap.bitmapData = this.tileData.tintBmd;
			highlightBitmap.bitmapData = this.tileData.highlightBmd;
			tilesContainer.x = tile.tilesContainer.x;
			tilesContainer.y = tile.tilesContainer.y;
			elevation = tile.elevation;
			
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
