package com.roguelike.editor;

import com.roguelike.Actor;
import com.roguelike.editor.MapData;
import com.roguelike.managers.TileManager;
import com.tyrannotorus.utils.KeyCodes;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * Map.as
 * - The game map..
 */
class Map extends Sprite {
	
	public var mapLayer:Sprite;
	public var allActors:Array<Actor>;
	
	private var mapData:MapData;
	private var currentScale:Float = 1;
	private var tileMap:Array<Array<Tile>>;
	private var currentTile:Tile;
			
	/**
	 * Constructor.
	 * @param {MapData} mapData
	 */
	public function new(mapData:MapData = null) {
		
		super();
		
		tileMap = new Array<Array<Tile>>();
		allActors = new Array<Actor>();
		
		// Create the layer holding the map tiles.
		mapLayer = new Sprite();
		mapLayer.mouseEnabled = false;
		mapLayer.cacheAsBitmap = true;
		addChild(mapLayer);
		
		addListeners();
		
		if (mapData != null) {
			loadMap(mapData);
		}
	}
	
	public function setCurrentTile(tile:Tile):Void {
		currentTile = tile;
		currentTile.highlight(true);
	}
	
	public function moveCurrentTile(tileCode:Int = 0):Void {

		if (tileCode != 0) {
			
			var neighbourTile:Tile = currentTile.getNeighbourTile(tileCode);
			trace(neighbourTile);
			if (neighbourTile != null) {
				currentTile.highlight(false);
				currentTile = neighbourTile;
				currentTile.highlight(true);
			}		
			
		} else {
			currentTile = tileMap[0][0];
			currentTile.highlight(true);
		}
	}
	
	
	
	/**
	 * Load a map with mapData
	 * @param {MapData} mapData
	 */
	public function loadMap(mapData:MapData):Void {
		
		this.mapData = mapData;
			
		var tileManager:TileManager = TileManager.getInstance();
		var emptyTile:Tile = tileManager.getTile("empty.png");
		var tileWidth:Int = Math.floor(emptyTile.width);
		var halfWidth:Int = Math.floor(tileWidth / 2);
		var tileHeight:Int = halfWidth;
		var halfHeight:Int = Math.floor(tileHeight / 2);
		var xPosition:Int = halfWidth;
		var yPosition:Int = halfHeight;
		var tileArray:Array<Int> = mapData.tileArray;
		var idxTile:Int = 0;
		
		
		for (yy in 0...mapData.height) {
			
			tileMap[yy] = new Array<Tile>();
						
			for (xx in 0...mapData.width) {
				
				var tileNum:Int = tileArray[idxTile++];
				var tileName:String = mapData.tileMap[tileNum];
				var tile:Tile = tileManager.getTile(tileName);
				tile.x = xPosition;
				tile.y = yPosition;
				mapLayer.addChild(tile);
				tileMap[yy].push(tile);
				xPosition += tileWidth;
				
				if (Math.floor(yPosition % tileHeight) == 0) {
					tile.tint();
				}				
			}
			
			yPosition += halfHeight;
			
			if (Math.floor(yPosition % tileHeight) == 0) {
				xPosition = halfWidth;
			} else {
				xPosition = tileWidth;
			}
			xPosition = (Math.floor(yPosition % tileHeight) == 0) ? tileWidth : halfWidth;
		}
		
		// Populate each tile with their direct neighbours.
		for (yy in 0...tileMap.length) {
			
			for (xx in 0...tileMap[yy].length) {
				
				tileMap[yy][xx].setNeighbourTile(tileMap[yy][xx - 1], KeyCodes.LEFT);
				
				if(xx > 0) {
					tileMap[yy][xx - 1].setNeighbourTile(tileMap[yy][xx], KeyCodes.RIGHT);
				}
				
				if (yy + 1 < tileMap.length) {
					if(yy % 2 == 0) {
						
						if(xx > 0) {
							tileMap[yy][xx].setNeighbourTile(tileMap[yy + 1][xx - 1], KeyCodes.SW);
							tileMap[yy + 1][xx - 1].setNeighbourTile(tileMap[yy][xx], KeyCodes.NE);
						}
						tileMap[yy][xx].setNeighbourTile(tileMap[yy + 1][xx], KeyCodes.SE);
						tileMap[yy + 1][xx].setNeighbourTile(tileMap[yy][xx], KeyCodes.NW);
					} else if(xx + 1 < tileMap[yy].length){
						tileMap[yy][xx].setNeighbourTile(tileMap[yy + 1][xx], KeyCodes.SW);
						tileMap[yy + 1][xx].setNeighbourTile(tileMap[yy][xx], KeyCodes.NE);
						tileMap[yy][xx].setNeighbourTile(tileMap[yy + 1][xx+1], KeyCodes.SE);
						tileMap[yy + 1][xx+1].setNeighbourTile(tileMap[yy][xx], KeyCodes.NW);
					}
				}
				
				if (yy + 2 < tileMap.length) {
					tileMap[yy][xx].setNeighbourTile(tileMap[yy + 2][xx], KeyCodes.DOWN);
					tileMap[yy + 2][xx].setNeighbourTile(tileMap[yy][xx], KeyCodes.UP);
				}
			}
		}
	}
	
	/**
	 * Modifies the scale of the map.
	 * @param {Float} scaleIncrement
	 */
	public function modifyScale(scaleIncrement:Float):Void {
		currentScale += scaleIncrement;
		
		var oldWidth:Float = mapLayer.width;
		var oldHeight:Float = mapLayer.height;
		
		mapLayer.scaleX = mapLayer.scaleY = currentScale;
		mapLayer.x += (oldWidth - mapLayer.width) / 2;
		mapLayer.y += (oldHeight - mapLayer.height) / 2;
	}
	
	/**
	 * Animate the actors on the level.
	 * @param {Event.ENTER_FRAME} e
	 */	
	public function animateActors(e:Event):Void {
		for (idxActor in 0...allActors.length) {
			allActors[idxActor].animate();
		}
	}
	
	/**
	 * A Tile on the map has been rolled over. Highlight it.
	 * @param {MouseEvent.ROLL_OVER} e
	 */
	private function onTileRollOver(e:MouseEvent):Void {
		
		e.stopImmediatePropagation();
		
		if (Std.is(e.target, Tile)) {
			cast(e.target, Tile).highlight(true);
		}
	}
	
	/**
	 * A Tile on the map has been rolled off. Unhighlight it.
	 * @param {MouseEvent.ROLL_OUT} e
	 */
	private function onTileRollOut(e:MouseEvent):Void {
		
		e.stopImmediatePropagation();
		
		if (Std.is(e.target, Tile)) {
			cast(e.target, Tile).highlight(false);
		}
	}
	
	public function addListeners():Void {
		mapLayer.addEventListener(MouseEvent.MOUSE_OUT, onTileRollOut);
		mapLayer.addEventListener(MouseEvent.MOUSE_OVER, onTileRollOver);
	}
	
	public function removeListeners():Void {
		mapLayer.removeEventListener(MouseEvent.MOUSE_OUT, onTileRollOut);
		mapLayer.removeEventListener(MouseEvent.MOUSE_OVER, onTileRollOver);
	}
	
}
