package com.roguelike.editor;

import com.roguelike.Actor;
import com.roguelike.editor.MapData;
import com.roguelike.managers.TileManager;
import com.tyrannotorus.utils.Colors;
import com.tyrannotorus.utils.KeyCodes;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import com.tyrannotorus.utils.OptimizedPerlin;
import openfl.utils.Object;
import openfl.Vector;
import motion.Actuate;

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
	
	public function reset():Void {
		allActors = new Array<Actor>();
		mapLayer.removeChildren();
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
				
		var mapSeed:Int = cast Math.random() * 6000;
		var optimizedPerlin:OptimizedPerlin = new OptimizedPerlin(mapSeed);
		var bmd:BitmapData = new BitmapData(mapData.width, mapData.height, true, Colors.TRANSPARENT);
		optimizedPerlin.fill(bmd, 0.2, 0.4, 1.0);
		var bitmap:Bitmap = new Bitmap(bmd);
		var perlinVector:Vector<UInt> = bmd.getVector(bmd.rect);
		var floatArray:Array<Float> = new Array<Float>();
		var lowestElevation:Float = 1;
		var highestElevation:Float = 0;
		
		for (ii in 0...perlinVector.length) {
			var float:Float = Std.int(optimizedPerlin.determineBrightness(perlinVector[ii]) * 100) / 100;
			lowestElevation = (float < lowestElevation) ? float : lowestElevation;
			highestElevation = (float > highestElevation) ? float : highestElevation;
			floatArray[ii] = Std.int(optimizedPerlin.determineBrightness(perlinVector[ii])*100)/100;
		}
				
		trace(lowestElevation + " to " + highestElevation);
		
		var elevationRange:Array<Float> = [0, 1, 2, 3, 4];
		var elevationIncrement:Float = (highestElevation - lowestElevation) / elevationRange.length;
		for (ii in 0...elevationRange.length) {
			elevationRange[ii] = Math.ceil((lowestElevation + ((ii + 1) * elevationIncrement)) * 100) / 100;
			trace(elevationRange[ii]);
		}
		
		var elevationMap:Object = {};
		var currentElevation:Int = 0;
		var currentIdx:Float = lowestElevation;
		var numberIndexes:Int = cast((highestElevation - lowestElevation) * 100);
		trace(elevationRange.join(","));
		for (i in 0...numberIndexes) {
			if (elevationRange.indexOf(currentIdx) != -1) {
				currentElevation++;
			}
			trace(currentIdx + ":" + currentElevation);
			elevationMap[Std.int(currentIdx*100)] = currentElevation;
			currentIdx = Std.int((currentIdx + 0.01)*100)/100;
		}
		
		for (yy in 0...mapData.height) {
			
			tileMap[yy] = new Array<Tile>();
						
			for (xx in 0...mapData.width) {
				
				var elevation:Int = elevationMap[Std.int(floatArray[idxTile]*100)];
				
				var tileNum:Int = tileArray[idxTile++];
				tileNum = 1;
				var tileName:String = (elevation > 0) ? mapData.tileMap[tileNum] : "water.png";
				var tile:Tile = tileManager.getTile(tileName);
				tile.x = xPosition;
				tile.y = yPosition;
				mapLayer.addChild(tile);
				tileMap[yy].push(tile);
				xPosition += tileWidth;
				
				if (Math.floor(yPosition % tileHeight) == 0) {
					tile.tint();
				}
				
				if(elevation > 0) {
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
				
				
				
				//var nNeighbour:Tile = tileMap[yy][xx].getNeighbourTile(KeyCodes.UP);
				//if (nNeighbour != null && tileMap[yy][xx].elevation > nNeighbour.elevation) {
				//	Actuate.transform(nNeighbour, 0).color(Colors.BLACK, 0.6);
				//}
				
				//var neNeighbour:Tile = tileMap[yy][xx].getNeighbourTile(KeyCodes.NE);
				//if (neNeighbour != null && tileMap[yy][xx].elevation > neNeighbour.elevation) {
				//	Actuate.transform(neNeighbour, 0).color(Colors.BLACK, 0.6);
				//}
				
				//var nwNeighbour:Tile = tileMap[yy][xx].getNeighbourTile(KeyCodes.NW);
				//if (nwNeighbour != null && tileMap[yy][xx].elevation > nwNeighbour.elevation) {
				//	Actuate.transform(nwNeighbour, 0).color(Colors.BLACK, 0.6);
				//}
			}
		}
		
		// NORMALIZING CODE:
		// EDGING CODE:
		// Edge the upper tiles if they cover lower tiles.
		for (yy in 0...tileMap.length) {
			
			for (xx in 0...tileMap[yy].length) {
				tileMap[yy][xx].showEdges(true);
			}
		}
		
		for (yy in 0...tileMap.length) {
			
			for (xx in 0...tileMap[yy].length) {
		
		var swNeighbour:Tile = tileMap[yy][xx].getNeighbourTile(KeyCodes.SW);
				if (swNeighbour != null && tileMap[yy][xx].elevation > swNeighbour.elevation) {
					Actuate.transform(swNeighbour, 0).color(Colors.BLACK, 0.6);
				}
				
				var sNeighbour:Tile = tileMap[yy][xx].getNeighbourTile(KeyCodes.DOWN);
				if (sNeighbour != null && tileMap[yy][xx].elevation > sNeighbour.elevation) {
					Actuate.transform(sNeighbour, 0).color(Colors.BLACK, 0.6);
				}
				
				var seNeighbour:Tile = tileMap[yy][xx].getNeighbourTile(KeyCodes.SE);
				if (seNeighbour != null && tileMap[yy][xx].elevation > seNeighbour.elevation) {
					Actuate.transform(seNeighbour, 0).color(Colors.BLACK, 0.6);
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
