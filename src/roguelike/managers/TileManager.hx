package roguelike.managers;

import com.tyrannotorus.assetloader.AssetEvent;
import com.tyrannotorus.assetloader.AssetLoader;
import com.tyrannotorus.utils.Utils;
import haxe.ds.ObjectMap;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import roguelike.editor.Tile;
import roguelike.editor.TileData;

class TileManager extends EventDispatcher {
	
	private static var tileManager:TileManager;
	
	private var tileCache:ObjectMap<String,Tile>;
	private var tileArray:Array<Tile>;
	
	/**
	 * Returns the instance of the tileManager.
	 * @return {TileManager}
	 */
	 public static function getInstance():TileManager {
		return (tileManager != null) ? tileManager : tileManager = new TileManager();
	}
	
	/**
	 * Constructor.
	 */
	public function new():Void {
		
		if (tileManager != null) {
			trace("TileManager.new() is already instantiated.");
			return;
		}
		
		super();
	}
		
	/**
	 * Returns whether the tileManager has loaded tiles yet.
	 * @return {Bool}
	 */
	 public function isReady():Bool {
		return (tileCache != null);
	}
	
	/**
	 * Shortcut for loading tiles
	 */
	public function init():Void {
		var assetLoader:AssetLoader = new AssetLoader();
		assetLoader.addEventListener(AssetEvent.LOAD_COMPLETE, onTilesLoaded);
		assetLoader.loadAsset("tiles/tiles.zip");
	}
	
	/**
	 * Tileset has loaded.
	 * @param {AssetEvent.LOAD_COMPLETE} e
	 */
	private function onTilesLoaded(e:AssetEvent):Void {
		
		var assetLoader:AssetLoader = cast(e.target, AssetLoader);
		assetLoader.removeEventListener(AssetEvent.LOAD_COMPLETE, onTilesLoaded);
		
		tileCache = new ObjectMap<String,Tile>();
		tileArray = new Array<Tile>();
		
		// Load the filename fields.
		var fieldsArray:Array<String> = Reflect.fields(e.assetData);
		fieldsArray.sort(Utils.sortAlphabetically);
		
		// Load the tiles by their filenames and save them to the tileCache.
		for (idxField in 0...fieldsArray.length) {
			
			var fieldString:String = fieldsArray[idxField];
			var fieldData:Dynamic = Reflect.field(e.assetData, fieldString);
			
			if (Std.is(fieldData, String)) {
				var jsonString:String = cast(fieldData, String);
				var tileData:TileData = new TileData(jsonString, e.assetData);
				var tile:Tile = new Tile(tileData);
				tileArray.push(tile);
				tileCache.set(tileData.fileName, tile);
			}
		}
		
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	/**
	 * Returns a tile from the tile cache by its tileName.
	 * @param {String} tileName
	 * @return {Tile}
	 */
	public function getTile(tileName:String):Tile {
		var tile:Tile = tileCache.get(tileName);
		return (tile != null) ? tile.clone() : null;
	}
	
	/**
	 * Returns an array of all the tiles.
	 * @return {Array<Tile>}
	 */
	public function getAllTiles():Array<Tile> {
		return tileArray.copy();
	}
	
}
