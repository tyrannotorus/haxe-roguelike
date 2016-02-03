package com.roguelike.editor;

import com.roguelike.Actor;
import com.roguelike.editor.MapData;
import com.roguelike.Main;
import com.roguelike.managers.TileManager;
import haxe.ds.ObjectMap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * Map.as
 * - The game map..
 */
class Map extends Sprite {
	
	private var mapData:MapData;
	private var mapLayer:Sprite;
	private var currentScale:Float = 1;
	private var allTiles:Array<Tile>;
	private var allActors:Array<Actor>;
		
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		
		allTiles = new Array<Tile>();
		allActors = new Array<Actor>();
		
		// Create the layer holding the map tiles.
		mapLayer = new Sprite();
		mapLayer.mouseEnabled = false;
		//mapLayer.addEventListener(MouseEvent.MOUSE_OUT, onTileRollOut);
		//mapLayer.addEventListener(MouseEvent.MOUSE_OVER, onTileRollOver);
		mapLayer.cacheAsBitmap = true;
		addChild(mapLayer);
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
			
			for (xx in 0...mapData.width) {
				var tileNum:Int = tileArray[idxTile++];
				var tileName:String = mapData.tileMap[tileNum];
				var tile:Tile = tileManager.getTile(tileName);
				tile.x = xPosition;
				tile.y = yPosition;
				allTiles.push(tile);
				mapLayer.addChild(tile);
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
	private function animateActors(e:Event):Void {
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
	
}
