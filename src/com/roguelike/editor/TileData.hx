package com.roguelike.editor;

import com.tyrannotorus.utils.Colors;
import com.tyrannotorus.utils.Utils;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.utils.Object;

/**
 * TileData.hx.
 * - Data for Tile.hx.
 */
class TileData {
	
	public var name:String;
	public var fileName:String;
	public var elevation:Int;
	public var fireAtk:Float;
	public var critAtk:Float;
	public var coldAtk:Float;
	public var magicAtk:Float;
	public var physAtk:Float;
	public var fireDef:Float;
	public var critDef:Float;
	public var coldDef:Float;
	public var magicDef:Float;
	public var physDef:Float;
	public var maxWeight:Int; // A maximum weight the tile can support before collapsing.
	public var tileBmd:BitmapData;
	public var tintBmd:BitmapData;
	public var highlightBmd:BitmapData;
	public var hitSprite:Sprite;
	public var centerX:Int;
	public var centerY:Int;
	
	/**
	 * Constructor.
	 * @param {String} jsonString
	 * @param {Dynamic} assetData
	 */
	public function new(jsonString:String, assetData:Dynamic) {
		deserialize(jsonString, assetData);
	}
	
	/**
	 * Returns tile data as a json string for saving.
	 * @return {String}
	 */
	public function serialize():String {
		return " ";
	}
	
	/**
	 * Deserializes json string into TileData.
	 * @param {String} jsonString
	 * @param {Dynamic} assetData
	 */
	private function deserialize(jsonString:String, assetData:Dynamic):Void {
		
		if(jsonString != null) {
			var jsonData:Object = Json.parse(jsonString);
			name = jsonData.name;
			fileName = jsonData.fileName;
			elevation = jsonData.elevation;
		}
		
		if (assetData != null && fileName != null) {
			var tile:Bitmap = Reflect.field(assetData, fileName);
			tileBmd = tile.bitmapData;
			tintBmd = Colors.tintBitmapData(tileBmd, Colors.TILE_OFFSET_COLOR);
			highlightBmd = Colors.tintBitmapData(tileBmd, Colors.TILE_HIGHLIGHT);
			hitSprite = Utils.getHitArea(tileBmd);
			centerX = cast(tileBmd.width / 2);
			centerY = cast(tileBmd.height - centerX);
		}
	}
	
}
