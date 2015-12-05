package bubblebobble;

import com.tyrannotorus.assetloader.AssetEvent;
import com.tyrannotorus.assetloader.AssetLoader;
import com.tyrannotorus.utils.Utils;
import com.tyrannotorus.utils.Colors;
import haxe.ds.ObjectMap;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

/**
 * TilesDialog.hx.
 * - A draggable dialog with .
 * - DraggableDialogs maintain independent positioning for both windowed/fullscreen display states, which auto-restore upon switching display state.
 * - Advised: Override the addListeners/removeListeners functions in order to add drag clicking to a specified part of the dialog.
 */
class TilesDialog extends DraggableDialog {

	private var headerContainer:Sprite;
	private var tilesContainer:Sprite;
	private var tilesArray:Array<Bitmap>;
	private var tilesMap:ObjectMap<Dynamic,Bitmap>;
	private var selectedTile:Bitmap;

	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		
		// Create the backing matte for the header.
		var matteObject:MatteObject = new MatteObject();
		matteObject.width = 64;
		matteObject.height = 8;
		matteObject.bottomRadius = 0;
		matteObject.borderColor = Colors.DUSTY_GREY;
		matteObject.primaryColor = Colors.LOCHMARA;
		matteObject.shadowColor = Colors.MIDNIGHT_BLUE;
		matteObject.shadowOffsetX = -3;
		matteObject.shadowOffsetY = 2;
		
		headerContainer = Matte.toSprite(matteObject);
		headerContainer.buttonMode = true;
		addChild(headerContainer);
		
		var textObject:TextObject = new TextObject();
		textObject.text = "Tiles";
		textObject.primaryColor = Colors.GALLERY;
		textObject.shadowColor = Colors.TUATARA;
		var headerText:Bitmap = TextManager.getInstance().toBitmap(textObject);
		headerContainer.addChild(headerText);
		
		// Create the backing matte for the container.
		matteObject.height = 56;
		matteObject.topRadius = 0;
		matteObject.bottomRadius = 1;
		var tilesBackground:Sprite = Matte.toSprite(matteObject);
		tilesBackground.y = headerContainer.height - 2;
		addChild(tilesBackground);
		
		tilesContainer = new Sprite();
		tilesContainer.x = 4;
		tilesContainer.y = tilesBackground.y + 4;
		tilesContainer.mouseChildren = true;
		addChild(tilesContainer);
		
		selectedTile = new Bitmap();
		selectedTile.x = tilesBackground.width - 12;
		selectedTile.y = tilesContainer.y - 12;
		addChild(selectedTile);
		
		addListeners();
	}
	
	private function onTileClick(e:MouseEvent):Void {
		trace(e.target);
		var tileBitmap:Bitmap = tilesMap.get(e.target);
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
		
		trace("onTilesLoaded");
		
		var assetLoader:AssetLoader = cast(e.target, AssetLoader);
		assetLoader.removeEventListener(AssetEvent.LOAD_COMPLETE, onTilesLoaded);
		
		if (e.assetData == null) {
			trace("onTilesetLoaded() Failure.");
			return;
		}
		
		tilesMap = new ObjectMap<Dynamic,Bitmap>();
				
		var xPosition:Float = 0;
		
		// Load the fields.
		var fieldsArray:Array<String> = Reflect.fields(e.assetData);
		fieldsArray.sort(Utils.sortAlphabetically);
		
		for (idxField in 0...fieldsArray.length) {
			var fieldString:String = fieldsArray[idxField];
			var bitmap:Bitmap = Reflect.field(e.assetData, fieldString);
			var tileSprite:Sprite = new Sprite();
			tileSprite.addChild(bitmap);
			tileSprite.buttonMode = true;
			tileSprite.x = xPosition;
			xPosition += bitmap.width;
			tilesMap.set(tileSprite, bitmap);
			tilesContainer.addChild(tileSprite);
		}
		
		addChild(tilesContainer);
	}

	/**
	 * Adds the drag listeners. By default, you can drag the entire dialog by clicking anywhere.
	 * Override this function to add drag listeners to the appropriate part of the dialog (the title bar, for instance).
	 */
	override private function addListeners():Void {
		tilesContainer.addEventListener(MouseEvent.CLICK, onTileClick);
		headerContainer.addEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.addEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}

	/**
	 * Removes the drag listeners. Override this function as well.
	 */
	override private function removeListeners():Void {
		tilesContainer.removeEventListener(MouseEvent.CLICK, onTileClick);
		headerContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.removeEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}

	
}