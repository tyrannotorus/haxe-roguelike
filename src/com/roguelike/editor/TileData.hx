package com.roguelike.editor;

import com.tyrannotorus.utils.Colors;
import com.tyrannotorus.utils.Utils;
import haxe.Json;
import lime.math.Rectangle;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.utils.Object;
import openfl.geom.Rectangle;

/**
 * TileData.hx.
 * - Data for Tile.hx.
 */
class TileData {
	
	public var name:String;
	public var fileName:String;
	public var edgeColor:Int = -1;
	public var elevation:Int;
	//public var fireAtk:Float;
	//public var critAtk:Float;
	//public var coldAtk:Float;
	//public var magicAtk:Float;
	//public var physAtk:Float;
	//public var fireDef:Float;
	//public var critDef:Float;
	//public var coldDef:Float;
	//public var magicDef:Float;
	//public var physDef:Float;
	//public var maxWeight:Int; // A maximum weight the tile can support before collapsing.
	public var tileBmd:BitmapData;
	public var tintBmd:BitmapData;
	public var nwEdge:BitmapData;
	public var neEdge:BitmapData;
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
			
			if(jsonData.edgeColor != null) {
				edgeColor = Colors.hexToInt(jsonData.edgeColor, true);
			}
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
		
		// Create the edge
		var edgeBmd:BitmapData = tileBmd.clone();
		edgeBmd.threshold(edgeBmd, edgeBmd.rect, new Point(), "!=", Colors.TRANSPARENT, Colors.TILE_GREEN);
		
		var cookieBmd:BitmapData = tileBmd.clone();
		cookieBmd.threshold(cookieBmd, cookieBmd.rect, new Point(), "!=", Colors.TRANSPARENT, Colors.MAGENTA);
		
		edgeBmd.copyPixels(cookieBmd, cookieBmd.rect, new Point(0, 1), null, null, true);
		edgeBmd.threshold(edgeBmd, edgeBmd.rect, new Point(), "==", Colors.MAGENTA, Colors.TRANSPARENT);
		
		var halfWidth:Int = cast(tileBmd.width / 2);
		var halfHeight:Int = cast(halfWidth / 2) + 1;
		nwEdge = new BitmapData(halfWidth, halfHeight, true, Colors.TRANSPARENT);
		nwEdge.copyPixels(edgeBmd, nwEdge.rect, new Point(), null, null, true);
				
		neEdge = new BitmapData(halfWidth, halfHeight, true, Colors.TRANSPARENT);
		neEdge.copyPixels(edgeBmd, new Rectangle(halfWidth, 0, halfWidth, halfHeight), new Point(), null, null, true);
	}
	
}
