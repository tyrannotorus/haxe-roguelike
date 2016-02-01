package com.roguelike.editor;

import com.roguelike.Actor;
import com.roguelike.editor.ActorSelectionBar;
import com.roguelike.dialogs.ItemContainer;
import com.roguelike.editor.EditorSelectionBar;
import com.roguelike.managers.MapManager;
import com.roguelike.MatteData;
import com.tyrannotorus.utils.Colors;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * MapEditor.as
 * - Like map, but editable.
 */
class MapEditor extends Map {
	
	// currentStates
	private static inline var DRAG_MAP:String = "DRAG_MAP";
		
	private var currentState:String;
	private var dialogLayer:Sprite;

	private var editorSelectionBar:EditorSelectionBar;
	private var selectedTile:Tile;
	private var selectedActor:Actor;
	private var dragStarted:Bool;
			
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		
		// Create the tiles layers.
		mapLayer.addEventListener(MouseEvent.CLICK, onTileClick);
				
		// Create the dialog layer.
		dialogLayer = new Sprite();
		addChild(dialogLayer);
		
		editorSelectionBar = new EditorSelectionBar();
		editorSelectionBar.x = 10;
		editorSelectionBar.y = Main.GAME_HEIGHT - 35;
		dialogLayer.addChild(editorSelectionBar);
				
		/*		
		actorSelectionBar = new ActorSelectionBar();
		actorSelectionBar.x = 10;
		actorSelectionBar.y = Main.GAME_HEIGHT - 35;
		actorSelectionBar.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
		actorSelectionBar.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
		dialogLayer.addChild(actorSelectionBar);
		actorSelectionBar.visible = false;
		*/
		
		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		this.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
		
		// Listen for dispatches from the editorDispatcher.
		var editorDispatcher:EditorDispatcher = EditorDispatcher.getInstance();
		editorDispatcher.addEventListener(Event.CHANGE, onEditorDispatch);
		
		// Load the map.
		var mapData:MapData = MapManager.getInstance().getMapData("hellmouth.txt");
		loadMap(mapData);
	}
	
	/**
	 * Listen to EditorDispatcher events, mostly dispatching menu events.
	 * @param {EditorEvent} e
	 */
	private function onEditorDispatch(e:EditorEvent):Void {
		
		var eventType:String = e.data;
		
		switch(eventType) {
			
			case EditorEvent.TILES:
				currentState = EditorEvent.TILES;
				enableActorsOnMap(false);
								
			case EditorEvent.ACTORS:
				currentState = EditorEvent.ACTORS;
				enableActorsOnMap(true);
								
			case EditorEvent.PROPS:
				currentState = EditorEvent.PROPS;
				enableActorsOnMap(false);
				
			case EditorEvent.ZOOM_OUT:
				modifyScale(-0.1);
				
			case EditorEvent.ZOOM_IN:
				modifyScale(0.1);
				
			case EditorEvent.HELP:
				trace("EditorEvent.HELP");
		}
		
	}
	
	private function onTileClick(e:MouseEvent):Void {
		
		var selectedTile:Tile = editorSelectionBar.getSelectedTile();
		if (selectedTile != null && Std.is(e.target, Tile)) {
			var tile:Tile = cast(e.target, Tile);
			tile.clone(selectedTile);
		}
	}
	
	/**
	 * A Tile on the map has been rolled over. Highlight it.
	 * @param {MouseEvent.ROLL_OVER} e
	 */
	override private function onTileRollOver(e:MouseEvent):Void {
		
		e.stopImmediatePropagation();
		
		if (Std.is(e.target, Tile)) {
			
			var tile:Tile = cast(e.target, Tile);
			
			if (currentState == EditorEvent.TILES) {
				var selectedTile:Tile = editorSelectionBar.getSelectedTile();
				if(selectedTile != null) {
					tile.clone(editorSelectionBar.getSelectedTile());
				}					
			}
			
			tile.highlight(true);
		}
	}
		
	/**
	 * If we're dragging an actor onto the actors dialog.
	 * @param {MouseEvent.ROLL_OVER} e
	 */
	private function onMouseRollOver(e:MouseEvent):Void {
				
		if (currentState == EditorEvent.ACTORS) {
			
			if (selectedActor != null) {
				selectedActor.startDrag(true);
				addChild(selectedActor);
			}
		}		
	}
	
	/**
	 * If we're dragging an actor from the actors dialog.
	 * @param {MouseEvent.ROLL_OUT} e
	 */
	private function onMouseRollOut(e:MouseEvent):Void {
			
		if (currentState == EditorEvent.ACTORS) {
			
			if (selectedActor != null) {
				//selectedActor.stopDrag();
			//	actorsLayer.addChild(selectedActor);
			}
		}		
	}
	
	/**
	 * User has mouse downed. Determine the user's intention.
	 * @param {MouseEvent.MOUSE_DOWN} e
	 */
	private function onMouseDown(e:MouseEvent):Void {

		destroyActor();
		
		// User has mouseDowned on an actor - on stage or in the inventory dialog.
		if (Std.is(e.target, Actor)) {
			
			// Actor is being clicked in the level.
			if (Std.is(e.target.parent, Tile)) {
				selectedActor = cast(e.target, Actor);
							
			// Actor is being clikced in the actors inventory dialog. Duplicate him.
			} else {
				var actor:Actor = cast(e.target, Actor);
				selectedActor = actor.clone();
				allActors.push(selectedActor);
				addEventListener(Event.ENTER_FRAME, animateActors);
			}
						
			currentState = EditorEvent.ACTORS;
			dragStarted = false;
			editorSelectionBar.mouseChildren = false;
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
						
		// A tile in the field was mouse downed upon.
		} else if (Std.is(e.target, Tile)) {
			
			if (e.shiftKey == true) {
				currentState = DRAG_MAP;
				mapLayer.mouseChildren = false;
				mapLayer.startDrag();
			
			} else {		
				currentState = EditorEvent.TILES;
				var tile:Tile = cast(e.target, Tile);
				var selectedTile:Tile = editorSelectionBar.getSelectedTile();
				if (selectedTile != null) {
					tile.clone(selectedTile);
				}
			}
		}
	}
	
	/**
	 * User has mouse upped.
	 * @param {MouseEvent.MOUSE_UP} e
	 */
	private function onMouseUp(e:Event):Void {
			
		editorSelectionBar.mouseChildren = true;
		
		switch(currentState) {
			
			case DRAG_MAP:
				mapLayer.mouseChildren = true;
				mapLayer.stopDrag();
				mapLayer.x = Math.floor(mapLayer.x);
				mapLayer.y = Math.floor(mapLayer.y);
				currentState = null;			
					
			case EditorEvent.ACTORS:
			
				// The character has been dragged.
				if (dragStarted) {
					selectedActor.mouseEnabled = true;
					selectedActor.mouseChildren = true;
								
					// Drop the character back into the inventory.
					if (Std.is(e.target, EditorSelectionBar)) {
						destroyActor();
					}
			
				// Actor was clicked, not dragged. Flip him horizontally.
				} else if(!Std.is(selectedActor.parent, ItemContainer)){
					selectedActor.scaleX *= -1;
				}
			
				enableActorsOnMap(true);
				
				removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
				selectedActor = null;
				dragStarted = false;
		}
		
		currentState = null;
	}
	
	/**
	 * Enable all the actors in the field for dragging.
	 * @param {Bool} value
	 */
	private function enableActorsOnMap(value:Bool):Void {
		for (i in 0...allActors.length) {
			allActors[i].currentTile.mouseChildren = value;
			allActors[i].buttonMode = value;
		}
	}
	
	private function destroyActor():Void {
		
		if (selectedActor != null) {
			
			if (selectedActor.parent != null) {
				selectedActor.parent.removeChild(selectedActor);
			}
				
			selectedActor.stopDrag();
			
			var actorIndex:Int = allActors.indexOf(selectedActor);
			if (actorIndex != -1) {
				allActors.splice(actorIndex, 1);
			}
			
			if (allActors.length == 0) {
				this.removeEventListener(Event.ENTER_FRAME, animateActors);
			}
		}
		
		selectedActor = null;
		dragStarted = false;
	}
	
	/**
	 * The mouse is held and being dragged on the screen.
	 * @param {MouseEvent.MOUSE_MOVE} e
	 */
	private function onMouseMove(e:MouseEvent):Void {
		trace("onMouseMove");
		if (currentState == EditorEvent.ACTORS) {
			
			// The user has now started dragging the character.
			if (!dragStarted) {
				selectedActor.mouseEnabled = false;
				selectedActor.mouseChildren = false;
				dragStarted = true;
				if(selectedActor.currentTile == null){
					selectedActor.startDrag(true);
					addChild(selectedActor);
				}
			}
			
			// Add actor to a tile.
			if (e.target != selectedActor.currentTile) {
				if(Std.is(e.target, Tile)) {
					selectedActor.stopDrag();
					var tile:Tile = cast(e.target, Tile);
					tile.addOccupant(selectedActor);
				}
			}
		}
	}
	
		
}
