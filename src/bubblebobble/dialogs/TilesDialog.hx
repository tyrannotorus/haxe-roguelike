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
	private var tilesArray:Array<Bitmap>;
	private var tilesMap:ObjectMap<Dynamic,Bitmap>;
	private var selectedTileContainer:Sprite;
	private var selectedTile:Bitmap;
	
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
		selectedTileContainer.addChild(selectedTile = new Bitmap());
		selectedTileContainer.x = WIDTH - 20;
		selectedTileContainer.y = 2;
		selectedTileContainer.mouseChildren = false;
		selectedTileContainer.mouseEnabled = false;
		addChild(selectedTileContainer);
		
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
		
		// Swap in and position the new tile.
		selectedTile.bitmapData = tileBitmap.bitmapData;
		selectedTile.x = selectedTile.y = (16 - selectedTile.width) / 2;
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
		
		tilesMap = new ObjectMap<Dynamic,Bitmap>();
				
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
			var tileSprite:Sprite = new Sprite();
			tileBitmap.x = -tileBitmap.width / 2;
			tileBitmap.y = -tileBitmap.height / 2;
			tileSprite.addChild(tileBitmap);
			tileSprite.buttonMode = true;
			
			tilesContainer.addItem(tileSprite);
			tilesMap.set(tileSprite, tileBitmap);
		}
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