package com.roguelike.editor;

import com.roguelike.dialogs.ContentContainer;
import com.roguelike.editor.EditorDispatcher;
import com.roguelike.editor.EditorEvent;
import com.roguelike.editor.Tile;
import com.roguelike.managers.ActorManager;
import com.roguelike.managers.TileManager;
import com.roguelike.TextData;
import com.tyrannotorus.utils.Colors;
import com.tyrannotorus.utils.Utils;
import haxe.ds.ObjectMap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
 * ActorsDialog.hx.
 * - Popup containing actors.
 */
class EditorSelectionBar extends Sprite {
	
	private static inline var WIDTH:Int = Main.GAME_WIDTH - 20;
	private static inline var HEIGHT:Int = 23;
		
	private var menuBar:MenuBar;
	private var helpBar:MenuBar;
	
	// Actor selection functionality.
	private var actorsContainer:ContentContainer;
	private var actorsArray:Array<Actor>;
	
	// Tile selection functionality.
	private var tilesContainer:ContentContainer;
	private var selectedTile:Tile;
	private var highlightMap:ObjectMap<Tile, Sprite>;
	private var highlightTile:Sprite;
	private var highlightColor:UInt = Colors.setAlpha(Colors.SCHOOL_BUS_YELLOW, 0.8);
	
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		
		highlightMap = new ObjectMap<Tile,Sprite>();
		
		var rect:Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
		
		// Create the backing matte.
		var matteData:MatteData = new MatteData();
		matteData.width = cast rect.width;
		matteData.height = cast rect.height;
		matteData.borderColor = Colors.TRANSPARENT;
		matteData.matteColor = Colors.setAlpha(Colors.BLACK, 0.7);
		var matteSprite:Sprite = Matte.toSprite(matteData);
		addChild(matteSprite);
		
		// Create the actor's section.
		actorsContainer = new ContentContainer(rect);
		actorsContainer.visible = false;
		addChild(actorsContainer);
		onActorsLoaded();
		
		// Create the tiles section.
		tilesContainer = new ContentContainer(rect);
		tilesContainer.y = 6;
		tilesContainer.visible = false;
		addChild(tilesContainer);
		onTilesLoaded();
		
		// Create the standard textData to be used for the menu bar.
		var menuData:TextData = new TextData();
		menuData.upColor = Colors.WHITE;
		menuData.overColor = Colors.SCHOOL_BUS_YELLOW;
		menuData.downColor = Colors.SCHOOL_BUS_YELLOW;
		menuData.shadowColor = Colors.BLACK;
				
		// Create the menubar.
		menuBar = new MenuBar(menuData);
		menuBar.x = 4;
		menuBar.y = -1;
		menuBar.addItem("File", EditorEvent.FILE);
		menuBar.addItem("Actors", EditorEvent.ACTORS, true);
		menuBar.addItem("Tiles", EditorEvent.TILES);
		menuBar.addItem("Props", EditorEvent.PROPS);
		menuBar.addItem("Settings", EditorEvent.SETTINGS);
		menuBar.addItem("Play", EditorEvent.CLOSE_EDITOR);
		addChild(menuBar);
		
		// Create the standard textData to be used for the menu bar.
		var helpData:TextData = new TextData();
		helpData.upColor = Colors.WHITE;
		helpData.overColor = Colors.SCHOOL_BUS_YELLOW;
		helpData.downColor = Colors.SCHOOL_BUS_YELLOW;
		helpData.shadowColor = Colors.BLACK;
		
		helpBar = new MenuBar(helpData, false);
		helpBar.addItem("+", EditorEvent.ZOOM_IN);
		helpBar.addItem("-", EditorEvent.ZOOM_OUT);
		helpBar.addItem("?  ", EditorEvent.HELP);
		helpBar.x = WIDTH - helpBar.width;
		helpBar.y = -1;
		addChild(helpBar);
		
		this.cacheAsBitmap = true;
		
		var editorDispatcher:EditorDispatcher = EditorDispatcher.getInstance();
		editorDispatcher.addEventListener(Event.CHANGE, onEditorDispatch);
		
		var editorEvent:EditorEvent = new EditorEvent(Event.CHANGE, EditorEvent.ACTORS);
		editorDispatcher.dispatchEvent(editorEvent);
	}
	
	/**
	 * Determine whether a specified tile is in the menu.
	 * @param {Tile} tile
	 * @return {Bool}
	 */
	public function isMenuTile(tile:Tile):Bool {
		return (tile.parent == tilesContainer);
	}
	
	/**
	 * Listen to EditorDispatcher events, mostly dispatching menu events.
	 * @param {EditorEvent} e
	 */
	private function onEditorDispatch(e:EditorEvent):Void {
		
		var eventType:String = e.data;
		
		switch(eventType) {
			
			case EditorEvent.TILES:
				this.removeEventListener(Event.ENTER_FRAME, animateActors);
				actorsContainer.visible = false;
				tilesContainer.visible = true;
				
			case EditorEvent.ACTORS:
				this.addEventListener(Event.ENTER_FRAME, animateActors);
				actorsContainer.visible = true;
				tilesContainer.visible = false;
								
			case EditorEvent.PROPS:
				this.removeEventListener(Event.ENTER_FRAME, animateActors);
				actorsContainer.visible = false;
				tilesContainer.visible = false;
		}
	}
	
	/**
	 * Animate the actors on the level.
	 * @param {Event.ENTER_FRAME} e
	 */	
	private function animateActors(e:Event):Void {
		for (idxActor in 0...actorsArray.length) {
			actorsArray[idxActor].animate();
		}
	}
	
	/**
	 * All Tiles were loaded by the TileManager
	 * @param {Event.COMPLETE} e
	 */
	private function onTilesLoaded(e:Event = null):Void {
		
		var tileManager:TileManager = TileManager.getInstance();
		
		if (!tileManager.isReady()) {
			tileManager.addEventListener(Event.COMPLETE, onTilesLoaded);
			return;
		}
		
		tileManager.removeEventListener(Event.COMPLETE, onTilesLoaded);
		
		var tileArray:Array<Tile> = tileManager.getAllTiles();
		for (i in 0...tileArray.length) {
			var tile:Tile = tileArray[i].clone();
			tile.buttonMode = true;
			tilesContainer.addItem(tile);
		}
		
		addListeners();		
	}
	
	/**
	 * All Actors have loaded. Load them into the container for display.
	 * @param {Event.COMPLETE} e
	 */
	private function onActorsLoaded(e:Event = null):Void {
		
		var actorManager:ActorManager = ActorManager.getInstance();
		
		if (!actorManager.isReady()) {
			actorManager.addEventListener(Event.COMPLETE, onActorsLoaded);
			return;
		} 
		
		actorManager.removeEventListener(Event.COMPLETE, onActorsLoaded);
		
		actorsArray = actorManager.getAllActors();
		for (idxActor in 0...actorsArray.length) {
			actorsContainer.addItem(actorsArray[idxActor]);
		}
	}
	
	/**
	 * Swallow mousedown clicks on tiles. We listen to clicks.
	 * @param {MouseEvent.MOUSE_DOWN} e
	 */
	private function onMouseDown(e:MouseEvent):Void {
		
		if (Std.is(e.target, Tile)) {
			e.stopImmediatePropagation();
			e.stopPropagation();
		}
	}
	
	/**
	 * User has clicked the editorSelectionBar
	 * @param {MouseEvent.CLICK} e
	 */
	private function onMouseClick(e:MouseEvent):Void {
		
		e.stopImmediatePropagation();
		e.stopPropagation();
		
		if (Std.is(e.target, Tile)) {
			
			if (highlightTile != null) {
				highlightTile.parent.removeChild(highlightTile);
			}
			
			selectedTile = cast e.target;
			
			// Create the tile highlight.
			highlightTile = highlightMap.get(selectedTile);
			
			if (highlightTile == null) {
				highlightTile = Utils.getOutline(selectedTile.tileBitmap, highlightColor);
				highlightTile.mouseEnabled = false;
				highlightTile.mouseChildren = false;
				highlightMap.set(selectedTile, highlightTile);
			}
			
			highlightTile.x = selectedTile.x;
			highlightTile.y = selectedTile.y;
			tilesContainer.addChild(highlightTile);
			
			var editorEvent:EditorEvent = new EditorEvent(Event.CHANGE, EditorEvent.TILE_SELECTED);
			EditorDispatcher.getInstance().dispatchEvent(editorEvent);
		}
	}
	
	public function getSelectedTile():Tile {
		return (selectedTile != null) ? selectedTile.clone() : null;
	}
	
	/**
	 * Add listeners.
	 */
	private function addListeners():Void {
		addEventListener(MouseEvent.CLICK, onMouseClick);
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}
	
	/**
	 * Removes listeners.
	 */
	private function removeListeners():Void {
		removeEventListener(MouseEvent.CLICK, onMouseClick);
		removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}

}