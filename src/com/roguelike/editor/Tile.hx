package com.roguelike.editor;

import com.tyrannotorus.utils.KeyCodes;
import motion.Actuate;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.utils.Object;
import com.tyrannotorus.utils.Colors;
import com.roguelike.managers.TileManager;

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
	public var highlightBitmap:Bitmap;
	public var hitSprite:Sprite;
	public var occupant:Dynamic;
	public var elevation:Int;
	public var smoothedElevation:Int = 0;
	public var tinted:Bool;
	public var tileHeight:Int;
	public var centerX:Int = 0;
	public var centerY:Int = 0;
	public var neEdge:Bitmap;
	public var nwEdge:Bitmap;
		
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
		
		tileStackArray = new Array<Bitmap>();
		tileStackArray.push(tileBitmap);
		
		highlightBitmap = new Bitmap(tileData.highlightBmd);
		highlightBitmap.visible = false;
		tilesContainer.addChild(highlightBitmap);
		
		tilesContainer.x = -tileBitmap.width / 2;
		tilesContainer.y = -tileBitmap.height / 2;
		
		nwEdge = new Bitmap(tileData.nwEdge);
		nwEdge.visible = false;
		addChild(nwEdge);
		
		neEdge = new Bitmap(tileData.neEdge);
		neEdge.visible = false;
		addChild(neEdge);
			
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
		}
		
		elevation = tileData.elevation;
	}
	
	/**
	 * Add an occupant to this tile (Actor, Treasure, etc);
	 * @param {Dynamic} occupant
	 */
	public function addOccupant(occupant:Dynamic, xOffset:Float = 0, yOffset:Float = 0):Void {
		
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
		occupant.x = xOffset + centerX;
		occupant.y = yOffset + centerY;
		occupant.currentTile = this;
		occupant.mouseEnabled = false;
		highlight(true);
		addChild(occupant);
		setChildIndex(occupant, numChildren -1);
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
		
	public function setElevation(newElevation:Int):Void {
		var elevationDifference:Int = newElevation - elevation;
		addElevation(elevationDifference);
	}
	
	/**
	 * Add or subtract elevation from tile by modifier value.
	 * @param {Int} modifier
	 */
	public function addElevation(value:Int):Void {
		
		var newElevation:Int = elevation + value;
		
		if (value == 0 || newElevation < 1) {
			return;
		}
		
		var elevationIncrement:Int = cast(value / Math.abs(value));
		var topTile:Bitmap;
		var newTile:Bitmap;
		
		while(elevation != newElevation) {
		
			elevation += elevationIncrement;
			centerX = 0;
			centerY = (elevation - 1) * -tileData.centerY;
			
			// Adding elevation to tile.
			if (elevationIncrement > 0) {
				topTile = tileStackArray[tileStackArray.length - 1];
				newTile = new Bitmap(topTile.bitmapData);
				newTile.y = centerY;
				tileStackArray.push(newTile);
				tilesContainer.addChild(newTile);
				
				//if (tileData.fileName == "water.png") {
				//	var terrainTile:Tile = TileManager.getInstance().getTile("terrain1.png");
				//	clone(terrainTile);
				//}
				
			// Subtracting elevation from tile.	
			} else if(tileStackArray.length > 1) {
				
				topTile = tileStackArray.pop();
				tilesContainer.removeChild(topTile);
				
				//if (elevation == 1) {
				//	var waterTile:Tile = TileManager.getInstance().getTile("water.png");
				//	clone(waterTile);				
				//}
			}
		}
			
		tilesContainer.setChildIndex(highlightBitmap, tileStackArray.length);
		highlightBitmap.x = centerX;
		highlightBitmap.y = centerY;
		
		if (occupant != null) {
			occupant.y = centerY;
		}
		
		update(true);
	}
	
	/**
	 * Smooth the elevation of the tile.
	 * If it has 5 neighbours of 1 lower elevation and 3 of equal, lower the elevation of this tile.
	 */
	public function smooth(doSmoothing:Bool = false):Void {
		
		if (doSmoothing && smoothedElevation != 0) {
			addElevation(smoothedElevation);
			smoothedElevation = 0;
			return;
		}
		
		var equalNeighbours:Int = 0;
		var lowerNeighbours:Int = 0;
		var higherNeighbours:Int = 0;
		var tileKeys:Array<String> = Reflect.fields(neighbourTiles);
		for (idxTile in 0...tileKeys.length) {
			var neighbourTile:Tile = neighbourTiles[cast(tileKeys[idxTile])];
			if (neighbourTile == null) {
				lowerNeighbours++;
			} else {
			
				var neighbourElevation:Int = neighbourTile.elevation;
				if (neighbourElevation == elevation) {
					equalNeighbours++;
				} else if (neighbourElevation + 1 == elevation) {
					lowerNeighbours++;
				} else if (neighbourElevation == elevation + 1) {
					higherNeighbours++;
				}
			}
		}
		
		if (lowerNeighbours > 6 || lowerNeighbours == 5 && equalNeighbours == 3 || equalNeighbours==1 && higherNeighbours==0) {
			smoothedElevation = -1;
		} else if (higherNeighbours > 6) {
			smoothedElevation = 1;
		}
	}
	
	public function highlight(value:Bool):Void {
		highlightBitmap.visible = value;
	}
	
	/**
	 * Update the look of the tile.
	 * @param {Bool} updateNeighbours
	 */
	public function update(updateNeighbours:Bool = false):Void {
		
		// Update this tile's edges/shadow.
		updateEdging();
		updateShadow();
		
		if(updateNeighbours) {
		
			var tile:Tile;
			var neighbours:Array<Int> = [KeyCodes.SW, KeyCodes.SE, KeyCodes.DOWN];
			
			// Update edges of this tile if it overshadows northernly neighbours.
			for (idxTile in 0...neighbours.length) {
				tile = getNeighbourTile(neighbours[idxTile]);
				if (tile != null) {
					tile.updateEdging();
				}
			}
		
			// Update the shadows of southernly neighbours.
			neighbours = [KeyCodes.SE, KeyCodes.DOWN, KeyCodes.SW];
			for (idxTile in 0...neighbours.length) {
				tile = getNeighbourTile(neighbours[idxTile]);
				if (tile != null) {
					tile.updateShadow();
				}
			}
		}
	}
	
	/**
	 * Update the edging on this tile.
	 */
	public function updateEdging():Void {
		
		nwEdge.x = tilesContainer.x;
		nwEdge.y = centerY - nwEdge.height - 2;
		nwEdge.visible = false;
		
		neEdge.x = tilesContainer.x + neEdge.width;
		neEdge.y = centerY - neEdge.height - 2;
		neEdge.visible = false;
		
		var nwTile:Tile = getNeighbourTile(KeyCodes.NW);
		var neTile:Tile = getNeighbourTile(KeyCodes.NE);
		
		if (nwTile == null && neTile == null) {
			nwEdge.visible = true;
			neEdge.visible = true;
			
		} else {
		
			if (nwTile == null && neTile != null && elevation == neTile.elevation && neTile.nwEdge.visible) {
				nwEdge.visible = true;
			} else if (nwTile != null && elevation > nwTile.elevation && tileData.fileName == nwTile.tileData.fileName) {
				nwEdge.visible = true;
			}
		
			if (neTile == null && nwTile != null && elevation == nwTile.elevation && nwTile.neEdge.visible) {
				neEdge.visible = true;
			} else if (neTile != null && elevation > neTile.elevation && tileData.fileName == neTile.tileData.fileName) {
				neEdge.visible = true;
			}
		
			if (neTile == null && nwEdge.visible) {
				neEdge.visible = true;
			}
		
			if (nwTile == null && neEdge.visible) {
				nwEdge.visible = true;
			}
			
			if (neTile != null && elevation == neTile.elevation) {
				neEdge.visible = false;
			}
			
			if (nwTile != null && elevation == nwTile.elevation) {
				nwEdge.visible = false;
			}
		}
	}
	
	/**
	 * Update the shadowing on this tile.
	 */
	public function updateShadow():Void {
		
		var tile:Tile;
		var neighbours:Array<Int> = [KeyCodes.NE, KeyCodes.UP, KeyCodes.NW];
			
		for (idxTile in 0...neighbours.length) {
			tile = getNeighbourTile(neighbours[idxTile]);
			if (tile != null && elevation < tile.elevation) {
				Actuate.transform(this, 0).color(Colors.BLACK, 0.6);
				return;
			}
		}
		
		Actuate.transform(this, 0).color(Colors.BLACK, 0);
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
		
		for (i in 0...tileStackArray.length) {
			tileStackArray[i].bitmapData = tileData.tintBmd;
		}
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
		
		// This tile is is cloning the tile parameter.
		if (tile != null) {
			this.tileData = tile.tileData;
			
			if(tinted) {
				tileBitmap.bitmapData = this.tileData.tintBmd;
			} else {
				tileBitmap.bitmapData = this.tileData.tileBmd;
			}
			
			// Set the bitmapDatas of all the tiles in the tile stack
			for (ii in 0...tileStackArray.length) {
				tileStackArray[ii].bitmapData = tileBitmap.bitmapData;
			}
			
			if(this.tileData.edgeColor > 0) {
				neEdge.bitmapData = this.tileData.neEdge;
				nwEdge.bitmapData = this.tileData.nwEdge;
			} else {
				neEdge.bitmapData = null;
				nwEdge.bitmapData = null;
			}
			
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
