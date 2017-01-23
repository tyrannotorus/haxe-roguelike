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
	public var smoothing:Int;
	public var tileMap:Array<String> = [];
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
	 * Deserializes json string into mapData.
	 * @param {String} jsonString
	 */
	private function deserialize(jsonString:String):Void {
		
		var jsonData:Object = Json.parse(jsonString);
		
		name = jsonData.name;
		fileName = jsonData.fileName;
		width = jsonData.width;
		height = jsonData.height;
		smoothing = jsonData.smoothing;
		tileArray = jsonData.tileArray;
				
		var tileFields:Array<String> = Reflect.fields(jsonData.tileMap);
		for (idxField in 0...tileFields.length) {
			var tileKey:Int = Std.parseInt(tileFields[idxField]);
			var tileValue:String = Reflect.field(jsonData.tileMap, Std.string(tileFields[idxField]));
			tileMap[tileKey] = tileValue;
		}
	}
}
