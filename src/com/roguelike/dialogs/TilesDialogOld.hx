package com.roguelike.dialogs;

import com.roguelike.dialogs.DraggableDialog;
import com.roguelike.editor.Tile;
import com.roguelike.managers.TileManager;
import com.tyrannotorus.utils.Colors;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
 * TilesDialog.hx.
 * - A draggable dialog with for use within the level editor.
 * - Loads a selection of tiles.
 */
class TilesDialogOld extends DraggableDialog {
	
	private static inline var WIDTH:Int = 96;
	private static inline var HEIGHT:Int = 128;
	private static inline var XMARGIN:Int = 6;

	private var tilesContainer:ItemContainer;
	private var selectedTileContainer:Sprite;
	private var selectedTile:Tile;
	
	/**
	 * Constructor.
	 */
	public function new() {
		
		var dialogData:DialogData = new DialogData();
		dialogData.headerText = "Tiles";
		dialogData.headerHeight = 14;
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
		selectedTileContainer.x = WIDTH - 22;
		selectedTileContainer.y = 2;
		selectedTileContainer.mouseEnabled = false;
		selectedTileContainer.mouseChildren = false;
		addChild(selectedTileContainer);
		
		var tileManager:TileManager = TileManager.getInstance();
		if (!tileManager.isReady()) {
			tileManager.addEventListener(Event.COMPLETE, onTilesLoaded);
		} else {
			onTilesLoaded();
		}
				
		addListeners();
	}
	
	/**
	 * All Tiles were loaded by the TileManager
	 * @param {Event.COMPLETE} e
	 */
	private function onTilesLoaded(e:Event = null):Void {
		trace("onTilesLoaded");
		var tileManager:TileManager = TileManager.getInstance();
		tileManager.removeEventListener(Event.COMPLETE, onTilesLoaded);
		
		var tileArray:Array<Tile> = tileManager.getAllTiles();
		for (i in 0...tileArray.length) {
			var tile:Tile = tileArray[i].clone();
			tile.buttonMode = true;
			tilesContainer.addItem(tile);
		}
		
		addListeners();		
		
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function onMouseDown(e:MouseEvent):Void {
		e.stopImmediatePropagation();
		e.stopPropagation();
	}
	
	private function onMouseClick(e:MouseEvent):Void {
		
		e.stopImmediatePropagation();
		e.stopPropagation();
		
		if (Std.is(e.target, Tile)) {
			
			var tile:Tile = cast(e.target, Tile);
			
			if (selectedTile == null) {
				selectedTile = new Tile(tile.tileData);
				selectedTile.x = selectedTile.width / 2;
				selectedTile.y = selectedTile.height / 2;
				selectedTileContainer.addChild(selectedTile);
			}
				
			selectedTile.clone(tile);
			
			selectedTile.tileBitmap.visible = (selectedTile.tileData.fileName == "empty.png") ? false : true;
		}
	}
	
	public function getSelectedTile():Tile {
		return (selectedTile != null) ? selectedTile.clone() : null;
	}
	
		
	/**
	 * Add listeners.
	 */
	override private function addListeners():Void {
		this.addEventListener(MouseEvent.CLICK, onMouseClick);
		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		headerContainer.addEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.addEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}
	
	/**
	 * Removes listeners.
	 */
	override private function removeListeners():Void {
		this.removeEventListener(MouseEvent.CLICK, onMouseClick);
		this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		headerContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.removeEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}

	
}