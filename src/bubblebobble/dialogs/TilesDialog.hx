package bubblebobble.dialogs;

import bubblebobble.dialogs.DraggableDialog;
import com.tyrannotorus.assetloader.AssetEvent;
import com.tyrannotorus.assetloader.AssetLoader;
import com.tyrannotorus.utils.Colors;
import com.tyrannotorus.utils.Utils;
import haxe.ds.ObjectMap;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

/**
 * TilesDialog.hx.
 * - A draggable dialog with for use within the level editor.
 * - Loads a selection of tiles.
 */
class TilesDialog extends DraggableDialog {

	private var tilesContainer:Sprite;
	private var tilesArray:Array<Bitmap>;
	private var tilesMap:ObjectMap<Dynamic,Bitmap>;
	private var selectedTile:Bitmap;
	
	/**
	 * Constructor.
	 */
	public function new() {
		
		var dialogData:DialogData = new DialogData();
		dialogData.headerText = "Tiles";
		dialogData.headerHeight = 12;
		dialogData.headerTextShadowColor = Colors.BLACK;
		dialogData.width = 64;
		dialogData.height = 96;
		dialogData.shadowColor = Colors.MIDNIGHT_BLUE;
		dialogData.shadowOffsetX = -3;
		dialogData.shadowOffsetY = 2;
		
		super(dialogData);
				
		tilesContainer = new Sprite();
		tilesContainer.x = 4;
		tilesContainer.y = headerContainer.height + 2;
		tilesContainer.mouseChildren = true;
		addChild(tilesContainer);
		
		selectedTile = new Bitmap();
		selectedTile.x = this.width - 14;
		selectedTile.y = 2;
		addChild(selectedTile);
		
		addListeners();
	}
	
	/**
	 * Makes the tile publically accessible.
	 * @return {Bitmap}
	 */
	public function getSelectedTile():Bitmap {
		return selectedTile;
	}
	
	/**
	 * User has clicked the tiles container.
	 * @return {MouseEvent.CLICK} e
	 */
	private function onTileClick(e:MouseEvent):Void {

		var tileBitmap:Bitmap = tilesMap.get(e.target);
		
		// Invalid. Something was clicked, but it wasn't a tile.
		if (tileBitmap == null) {
			e.stopImmediatePropagation();
			return;
		}
		
		selectedTile.bitmapData = tileBitmap.bitmapData;
	}
		
	/**
	 * Initiate load of the tileset.
	 */
	public function loadTiles():Void {
		var assetLoader:AssetLoader = new AssetLoader();
		assetLoader.addEventListener(AssetEvent.LOAD_COMPLETE, onTilesLoaded);
		assetLoader.loadAsset("https://sites.google.com/site/tyrannotorus/tileset.zip");
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
		
		tilesMap = new ObjectMap<Dynamic,Bitmap>();
				
		var xPosition:Float = 0;
		
		// Load the fields.
		var fieldsArray:Array<String> = Reflect.fields(e.assetData);
		fieldsArray.sort(Utils.sortAlphabetically);
		
		for (idxField in 0...fieldsArray.length) {
			var fieldString:String = fieldsArray[idxField];
			var tileBitmap:Bitmap = Reflect.field(e.assetData, fieldString);
			trace("tile " + tileBitmap.width + "x" + tileBitmap.height);
			var tileSprite:Sprite = new Sprite();
			tileSprite.addChild(tileBitmap);
			tileSprite.buttonMode = true;
			tileSprite.x = xPosition;
			xPosition += tileBitmap.width;
			tilesMap.set(tileSprite, tileBitmap);
			tilesContainer.addChild(tileSprite);
		}
		
		addChild(tilesContainer);
	}

	/**
	 * Add listeners.
	 */
	override private function addListeners():Void {
		tilesContainer.addEventListener(MouseEvent.CLICK, onTileClick);
		headerContainer.addEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.addEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}

	/**
	 * Removes listeners.
	 */
	override private function removeListeners():Void {
		tilesContainer.removeEventListener(MouseEvent.CLICK, onTileClick);
		headerContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.removeEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}

	
}