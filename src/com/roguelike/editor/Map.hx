package com.roguelike.editor;

import com.roguelike.Actor;
import com.roguelike.editor.MapData;
import com.roguelike.managers.ActorManager;
import com.roguelike.managers.TileManager;
import com.tyrannotorus.utils.KeyCodes;
import com.tyrannotorus.utils.OptimizedPerlin;
import motion.Actuate;
import motion.easing.Cubic;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.ui.Mouse;

/**
 * Map.as
 * - The game map.
 * - Allows dragging by click+drag
 */
class Map extends Sprite {
	
	public static inline var TILES_FROM_CENTER:Int = 4;
	public static inline var MAP_TWEEN_SPEED:Float = 0.2;
	
	public var mapLayer:Sprite;
	public var allActors:Array<Actor>;
	public var currentTile:Tile;
	
	private var mapData:MapData;
	private var currentScale:Float = 1;
	private var tileMap:Array<Array<Tile>>;
	private var viewRect:Rectangle;
	private var centerTile:Tile;
	private var dragDifferenceX:Int;
	private var dragDifferenceY:Int;
	private var originalX:Int;
	private var originalY:Int;
	private var isTransposing:Bool;
		
	/**
	 * Constructor.
	 * @param {MapData} mapData
	 */
	public function new(mapData:MapData = null) {
		
		super();
		
		tileMap = new Array<Array<Tile>>();
		allActors = new Array<Actor>();
		
		this.y = 4;
				
		viewRect = new Rectangle(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT - 8);
		scrollRect = viewRect;
		
		// Create the layer holding the map tiles.
		mapLayer = new Sprite();
		mapLayer.mouseEnabled = false;
		addChild(mapLayer);
		
		addListeners();
		
		if (mapData != null) {
			loadMap(mapData);
		}
	}
	
	public function moveToTile(tileKey:Int):Void {
		trace("map.moveToTile");
		if (currentTile == null) {
			return;
		}
		
		var neighbourTile:Tile = currentTile.getNeighbourTile(tileKey);
		setCurrentTile(neighbourTile);
	}
	
	public function setCurrentTile(tile:Tile):Void {
		
		if(tile != null) {
			
			if (currentTile != null) {
				currentTile.highlight(false);
			}
				
			currentTile = tile;
			currentTile.highlight(true);
		}
	}
	
	public function alignCameraToTile(tile:Tile, tileKey:Int):Void {
		
		if (centerTile == null) {
			centerTile = tile;
			centerTile.highlight(true);
		}
		
		// Always close follow the player at scales greater than 1.
		if (currentScale > 1) {
			setFocusToTile(centerTile.getNeighbourTile(tileKey));
		
		// Otherwise...
		} else {
		
			// Calculate number of blocks away.
			var halfWidth:Float = centerTile.width / 2;
			var halfHeight:Float = halfWidth / 2;
			var xDistance:Float = Math.abs(centerTile.x - tile.x);
			var yDistance:Float = Math.abs(centerTile.y - tile.y);
			var numBlocksX:Int = cast(Math.ceil(xDistance / halfWidth));
			var numBlocksY:Int = cast(Math.ceil(yDistance / halfHeight));
		
			if (numBlocksX +  numBlocksY > TILES_FROM_CENTER * 2) {
				setFocusToTile(centerTile.getNeighbourTile(tileKey));
			}
		}
	}
	
	/**
	 * Set the viewRect's focus to a specified tile.
	 * @param {Tile} tile
	 * @param {Float} tweenSpeed
	 */
	public function setFocusToTile(tile:Tile, tweenSpeed:Float = MAP_TWEEN_SPEED):Void {
		centerTile = tile;
		var viewRectX:Int = cast(centerTile.x * currentScale - (viewRect.width/2));
		var viewRectY:Int = cast((centerTile.y + centerTile.centerY) * currentScale - (viewRect.height/2));
		isTransposing = true;
		Actuate.tween(viewRect, tweenSpeed, { x:viewRectX, y:viewRectY } ).ease(Cubic.easeInOut).onUpdate(updateScrollRect);
	}
	
	private function updateScrollRect():Void {
		scrollRect = viewRect;
	}
	
	public function reset():Void {
		allActors = new Array<Actor>();
		mapLayer.removeChildren();
		mapLayer.x = 0;
		mapLayer.y = 0;
		loadMap(mapData);
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
		
		// Create the elevation array of the map using perlin noise.
		var mapSeed:Int = cast(Math.random() * 2000000000);
		var optimizedPerlin:OptimizedPerlin = new OptimizedPerlin(mapSeed);
		var elevationArray:Array<Array<Int>> = optimizedPerlin.getElevationArray(mapData, [0,1,2,3,4,5], 0.9, 0.4, 0.4);
	
		var tile:Tile;
		
		for (yy in 0...mapData.height) {
			
			tileMap[yy] = new Array<Tile>();
						
			for (xx in 0...mapData.width) {
				
				var elevation:Int = elevationArray[yy][xx];
				var tileNum:Int = tileArray[idxTile++];
				
				// All tiles are terrain1 currently
				tileNum = 1;
				
				var tileName:String = (elevation > 0) ? mapData.tileMap[tileNum] : "water.png";
				tile = tileManager.getTile(tileName);
				tile.x = xPosition;
				tile.y = yPosition;
				mapLayer.addChild(tile);
				tileMap[yy].push(tile);
				xPosition += tileWidth;
				
				if (Math.floor(yPosition % tileHeight) == 0) {
					tile.tint();
				}
				
				if (elevation > 0) {
					tile.addElevation(elevation);
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
		var thisTileRow:Array<Tile>;
		var nextTileRow:Array<Tile>;
		
		for (yy in 0...tileMap.length) {
			
			thisTileRow = tileMap[yy];
			nextTileRow = (yy + 1 < tileMap.length) ? tileMap[yy + 1] : null;
			
			for (xx in 0...tileMap[yy].length) {
				
				tile = thisTileRow[xx];
				tile.setNeighbourTile(thisTileRow[xx - 1], KeyCodes.LEFT);
				
				if(xx > 0) {
					thisTileRow[xx - 1].setNeighbourTile(tile, KeyCodes.RIGHT);
				}
				
				if (nextTileRow != null) {
					if(yy % 2 == 0) {
						
						if(xx > 0) {
							tile.setNeighbourTile(nextTileRow[xx - 1], KeyCodes.SW);
							nextTileRow[xx - 1].setNeighbourTile(tile, KeyCodes.NE);
						}
						tile.setNeighbourTile(nextTileRow[xx], KeyCodes.SE);
						nextTileRow[xx].setNeighbourTile(tile, KeyCodes.NW);
					} else {
						
						if (xx + 1 < tileMap[yy].length) {
							tile.setNeighbourTile(nextTileRow[xx + 1], KeyCodes.SE);
							nextTileRow[xx + 1].setNeighbourTile(tile, KeyCodes.NW);
						}
						tile.setNeighbourTile(nextTileRow[xx], KeyCodes.SW);
						nextTileRow[xx].setNeighbourTile(tile, KeyCodes.NE);
					}
				}
				
				if (yy + 2 < tileMap.length) {
					tileMap[yy][xx].setNeighbourTile(tileMap[yy + 2][xx], KeyCodes.DOWN);
					tileMap[yy + 2][xx].setNeighbourTile(tileMap[yy][xx], KeyCodes.UP);
				}
			}
		}
		
		if (mapData.smoothing > 0) {
			
			for (ii in 0...mapData.smoothing) {
				smooth(true);
			}
			
		} else {
		
			for (yy in 0...tileMap.length) {
				for (xx in 0...tileMap[yy].length) {
					tileMap[yy][xx].update();
				}
			}
		}
		
		// Populate map with actors.
		var actors:Array<Actor> = ActorManager.getInstance().getAllActors();
		for (idxActor in 0...100) {
			var randomActor:Actor = actors[Std.int(Math.random() * actors.length)].clone();
			var xx:Int = cast(Math.random() * mapData.width);
			var yy:Int = cast(Math.random() * mapData.height);
			if (tileMap[yy][xx].occupant == null) {
				randomActor.scaleX = Std.int(Math.random() * 2) == 0 ? -1 : 1;
				randomActor.currentFrame = Std.int(Math.random() * 3);
				randomActor.tick = Std.int(Math.random() * 6);
				allActors.push(randomActor);
				tileMap[yy][xx].addOccupant(randomActor);
				tileMap[yy][xx].highlight(false);
			}
		}
		
		addEventListener(Event.ENTER_FRAME, animateActors);
	}
	
	public function smooth(andUpdate:Bool = true):Void {
		
		for (yy in 0...tileMap.length) {
			for (xx in 0...tileMap[yy].length) {
				tileMap[yy][xx].smooth();
			}
		}
		
		// Update shadows and edging of all tiles.
		for (yy in 0...tileMap.length) {
			for (xx in 0...tileMap[yy].length) {
				tileMap[yy][xx].smooth(true);
			}
		}
		
		if(andUpdate) {
			for (yy in 0...tileMap.length) {
				for (xx in 0...tileMap[yy].length) {
					tileMap[yy][xx].update();
				}
			}
		}
	}
	
	/**
	 * Modifies the scale of the map.
	 * @param {Float} scaleIncrement
	 */
	public function modifyScale(scaleIncrement:Float):Void {
		
		if (currentScale + scaleIncrement < 0.5) {
			return;
		}
		
		currentScale += scaleIncrement;
		mapLayer.scaleX = mapLayer.scaleY = Std.int(currentScale*10)/10;
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
		
		if (Std.is(e.target, Tile)) {
			setCurrentTile(cast(e.target));
		}
	}
	
	/**
	 * A Tile on the map has been rolled off. Unhighlight it.
	 * @param {MouseEvent.ROLL_OUT} e
	 */
	private function onTileRollOut(e:MouseEvent):Void {
		
		e.stopImmediatePropagation();
		
		//if (Std.is(e.target, Tile)) {
		//	cast(e.target, Tile).highlight(false);
		//}
	}
	
	public function onMouseDown(e:MouseEvent):Void {
		if(Std.is(e.target, Tile)) {
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
			addEventListener(Event.MOUSE_LEAVE, onMouseUp);
			mapLayer.buttonMode = true;
			originalX = cast viewRect.x;
			originalY = cast viewRect.y;
			dragDifferenceX = cast e.stageX;
			dragDifferenceY = cast e.stageY;
			mapLayer.removeEventListener(MouseEvent.MOUSE_OUT, onTileRollOut);
			mapLayer.removeEventListener(MouseEvent.MOUSE_OVER, onTileRollOver);
		}
	}
	
	public function onMouseMove(e:MouseEvent):Void {
		
		if (!e.buttonDown) {
			onMouseUp();
			return;
		}
		
		viewRect.x = originalX + (dragDifferenceX - e.stageX);
		viewRect.y = originalY + (dragDifferenceY - e.stageY);
		scrollRect = viewRect;
	}
	
	public function onMouseUp(e:Event = null):Void {
		//smooth();
		// Stop the drag and set the scrollRect.
		viewRect.x = Std.int(viewRect.x);
		viewRect.y = Std.int(viewRect.y);
		scrollRect = viewRect;
		
		mapLayer.buttonMode = false;
		removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
		removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
		removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
		mapLayer.addEventListener(MouseEvent.MOUSE_OUT, onTileRollOut);
		mapLayer.addEventListener(MouseEvent.MOUSE_OVER, onTileRollOver);
	}
	
	private function onRollOver(e:MouseEvent):Void {
		Mouse.hide();
	}
	
	public function addListeners():Void {
		addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		mapLayer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		mapLayer.addEventListener(MouseEvent.MOUSE_OUT, onTileRollOut);
		mapLayer.addEventListener(MouseEvent.MOUSE_OVER, onTileRollOver);
	}
	
	public function removeListeners():Void {
		mapLayer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		mapLayer.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		mapLayer.removeEventListener(MouseEvent.MOUSE_OUT, onTileRollOut);
		mapLayer.removeEventListener(MouseEvent.MOUSE_OVER, onTileRollOver);
	}
	
}
