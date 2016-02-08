package com.roguelike.editor;

import haxe.ds.ObjectMap;
import haxe.Json;
import openfl.utils.Object;

/**
 * MapData.hx.
 * - Data for Map.hx.
 */
class MapData {
	
	public var name:String;
	public var fileName:String;
	public var width:Int;
	public var height:Int;
	public var tileMap:Object;
	public var tileArray:Array<Int>;
	public var actorArray:Array<Int>;
	public var propArray:Array<Int>;
			
	/**
	 * Constructor.
	 * @param {String} jsonString
	 */
	public function new(jsonString:String) {
		deserialize(jsonString);
	}
	
	/**
	 * Saves actors and props placed on tiles during map edit.
	 * @param {Array<Tile>} allTiles
	 */
	public function save(allTiles:Array<Tile>):Void {
		
		var idxTile:Int = 0;
		
		tileArray = new Array<Int>();
		actorArray = new Array<Int>();
		propArray = new Array<Int>();
		
		
		// Save the changes to the tiles with a new tile:file map
		// loop throught the tiles and create an actor#:actorfile map array<int>
		for (yy in 0...height) {
			
			for (xx in 0...width) {
				var tile:Tile = allTiles[idxTile];
				
				//if(tile.)
				
			}
		}
	}
	
	/**
	 * Deserializes json string into mapData.
	 * @param {String} jsonString
	 */
	private function deserialize(jsonString:String):Void {
		
		var jsonData:Object = Json.parse(jsonString);
		
		name = jsonData.name;
		fileName = jsonData.fileName;
		width = jsonData.width;
		height = jsonData.height;
		tileMap = jsonData.tileMap;
		tileArray = jsonData.tileArray;
	}
}
