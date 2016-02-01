package com.roguelike.managers;

import com.roguelike.editor.MapData;
import com.tyrannotorus.assetloader.AssetEvent;
import com.tyrannotorus.assetloader.AssetLoader;
import com.tyrannotorus.utils.Utils;
import haxe.ds.ObjectMap;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class MapManager extends EventDispatcher {
	
	private static var mapManager:MapManager;
	
	private var mapCache:ObjectMap<String,MapData>;
		
	/**
	 * Returns the instance of the mapManager.
	 * @return {MapManager}
	 */
	 public static function getInstance():MapManager {
		return (mapManager != null) ? mapManager : mapManager = new MapManager();
	}
	
	/**
	 * Constructor.
	 */
	public function new():Void {
		
		if (mapManager != null) {
			trace("MapManager.new() is already instantiated.");
			return;
		}
		
		super();
	}
		
	/**
	 * Returns whether the mapManager has loaded maps yet.
	 * @return {Bool}
	 */
	 public function isReady():Bool {
		return (mapCache != null);
	}
	
	/**
	 * Shortcut for loading maps
	 */
	public function init():Void {
		var assetLoader:AssetLoader = new AssetLoader();
		assetLoader.addEventListener(AssetEvent.LOAD_COMPLETE, onMapLoaded);
		assetLoader.loadAsset("tiles/map.zip");
	}
	
	/**
	 * The Map has loaded.
	 * @param {AssetEvent.LOAD_COMPLETE} e
	 */
	private function onMapLoaded(e:AssetEvent):Void {
		
		var assetLoader:AssetLoader = cast(e.target, AssetLoader);
		assetLoader.removeEventListener(AssetEvent.LOAD_COMPLETE, onMapLoaded);
		
		mapCache = new ObjectMap<String,MapData>();
				
		// Load the filename fields.
		var fieldsArray:Array<String> = Reflect.fields(e.assetData);
		fieldsArray.sort(Utils.sortAlphabetically);
		
		// Load the maps by their filenames and save them to the mapCache.
		for (idxField in 0...fieldsArray.length) {
			
			var fieldString:String = fieldsArray[idxField];
			var fieldData:Dynamic = Reflect.field(e.assetData, fieldString);
			
			if (Std.is(fieldData, String)) {
				var jsonString:String = cast(fieldData, String);
				trace(jsonString);
				var mapData:MapData = new MapData(jsonString);
				mapCache.set(mapData.fileName, mapData);
			}
		}
		
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	/**
	 * Returns a map from the map cache by its mapName.
	 * @param {String} mapName
	 * @return {Tile}
	 */
	public function getMapData(mapName:String):MapData {
		return mapCache.get(mapName);
	}
	
	
}
