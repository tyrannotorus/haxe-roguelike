package bubblebobble.dialogs;

import bubblebobble.dialogs.DraggableDialog;
import bubblebobble.editor.Tile;
import com.tyrannotorus.assetloader.AssetEvent;
import com.tyrannotorus.assetloader.AssetLoader;
import com.tyrannotorus.utils.Colors;
import com.tyrannotorus.utils.Utils;
import haxe.ds.ObjectMap;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
 * TilesDialog.hx.
 * - A draggable dialog with for use within the level editor.
 * - Loads a selection of tiles.
 */
class TilesDialog extends DraggableDialog {
	
	private static inline var WIDTH:Int = 96;
	private static inline var HEIGHT:Int = 128;
	private static inline var XMARGIN:Int = 6;

	private var tilesContainer:ItemContainer;
	private var tilesMap:ObjectMap<String,Tile> = new ObjectMap<String,Tile>();
	private var selectedTileContainer:Sprite;
	private var selectedTile:Tile;
	
	/**
	 * Constructor.
	 */
	public function new() {
		
		var dialogData:DialogData = new DialogData();
		dialogData.headerText = "Arcade\nTiles";
		dialogData.headerHeight = 20;
		dialogData.headerTextShadowColor = Colors.BLACK;
		dialogData.width = WIDTH;
		dialogData.height = HEIGHT;
				
		super(dialogData);
				
		headerText.y += 1;
		var tilesContainerY:Int = Std.int(headerContainer.y + headerContainer.height - 4);
		var tilesRectangle:Rectangle = new Rectangle(XMARGIN, tilesContainerY, WIDTH - 2 * XMARGIN, 50);
		tilesContainer = new ItemContainer(tilesRectangle);
		addChild(tilesContainer);
		
		selectedTileContainer = new Sprite();
		selectedTileContainer.x = WIDTH - 20;
		selectedTileContainer.y = 2;
		selectedTileContainer.mouseEnabled = false;
		selectedTileContainer.mouseChildren = false;
		
		selectedTile = new Tile();
		selectedTileContainer.addChild(selectedTile);
		addChild(selectedTileContainer);
		
		addListeners();
	}
	
	public function setSelectedTile(possibleTile:Sprite):Void {
		var tileName:String = possibleTile.name;
		getTileByName(tileName, true);
	}
	
	public function getSelectedTile(possibleTile:Sprite, autoSelectTile:Bool = false):Tile {
		var tileName:String = possibleTile.name;
		return getTileByName(tileName, autoSelectTile);
	}
	
	public function getTileByName(tileName:String, autoSelectTile:Bool = false):Tile {
		trace("getTileByName() " + tileName + " " + autoSelectTile);
		var tile:Tile = tilesMap.get(tileName);
		
		// This is not a tile.
		if (tile == null) {
			return null;
		}
		
		// Swap in and position the new tile.
		if(autoSelectTile == true) {
			selectedTile.clone(tile);
			selectedTile.x = selectedTile.y = (16 - selectedTile.width) / 2;
		}
		
		return tile;
	}
	
	/**
	 * Initiate load of the tileset.
	 */
	public function loadTiles():Void {
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
		
		if (e.assetData == null) {
			trace("TilesDialog.onTilesLoaded() Failure.");
			return;
		}
		
		var xPosition:Float = 0;
		var yPosition:Float = 0;
		var rowHeight:Float = 0;
		var maxWidth:Float = WIDTH - 13;
		
		// Load the fields.
		var fieldsArray:Array<String> = Reflect.fields(e.assetData);
		fieldsArray.sort(Utils.sortAlphabetically);
		
		for (idxField in 0...fieldsArray.length) {
			var fieldString:String = fieldsArray[idxField];
			var tileBitmap:Bitmap = Reflect.field(e.assetData, fieldString);
			var tile:Tile = new Tile(fieldString, tileBitmap, true);
			tile.bitmap.x = -tileBitmap.width / 2;
			tile.bitmap.y = -tileBitmap.height / 2;
			
			tilesContainer.addItem(tile);
			tilesMap.set(fieldString, tile);
		}
	}
	
	/**
	 * Add listeners.
	 */
	override private function addListeners():Void {
		headerContainer.addEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.addEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}
	
	/**
	 * Removes listeners.
	 */
	override private function removeListeners():Void {
		headerContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.removeEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}

	
}