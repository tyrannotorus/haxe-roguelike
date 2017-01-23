package com.roguelike.editor;

import com.roguelike.Actor;
import com.roguelike.editor.EditorSelectionBar;
import com.roguelike.Game;
import com.tyrannotorus.utils.KeyCodes;
import motion.Actuate;
import motion.easing.Cubic;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Mouse;
import openfl.utils.Object;

/**
 * MapEditor.as
 * - Like map, but editable.
 */
class MapEditor extends Sprite {
	
	private var currentState:String;
	private var dialogLayer:Sprite;
	private var map:Map;
	private var editorSelectionBar:EditorSelectionBar;
	private var selectedTile:Tile;
	private var selectedActor:Actor;
	private var dragStarted:Bool;
	private var mouseDown:Bool;
	private var keysDown:Array<Bool> = [];
		
	/**
	 * Constructor.
	 * @param {Map} map
	 */
	public function new(map:Map) {
		
		super();
		
		// Listen for dispatches from the editorDispatcher.
		var editorDispatcher:EditorDispatcher = EditorDispatcher.getInstance();
		editorDispatcher.addEventListener(EditorEvent.DISPATCH, onEditorDispatch);
		
		// Add the map to the editor.
		this.map = map;
		this.addChild(map);
		
		// Create the dialog layer.
		dialogLayer = new Sprite();
		dialogLayer.mouseEnabled = false;
		addChild(dialogLayer);
		
		editorSelectionBar = new EditorSelectionBar();
		editorSelectionBar.x = 10;
		editorSelectionBar.y = Main.GAME_HEIGHT - 35;
		dialogLayer.addChild(editorSelectionBar);
		
		addListeners();
	}
	
	/**
	 * Listen to EditorDispatcher events, mostly dispatching menu events.
	 * @param {EditorEvent} e
	 */
	private function onEditorDispatch(e:EditorEvent):Void {
		
		var editorEvent:String = e.data;
		
		switch(editorEvent) {
			
			case EditorEvent.TILES:
				currentState = EditorEvent.TILES;
				enableActorsOnMap(false);
				
			case EditorEvent.ACTORS:
				currentState = EditorEvent.ACTORS;
				enableActorsOnMap(true);
				
			case EditorEvent.PROPS:
				currentState = EditorEvent.PROPS;
				enableActorsOnMap(false);
				
			case EditorEvent.TILE_SELECTED:
				selectedTile = editorSelectionBar.getSelectedTile();
				enableActorsOnMap(false);
				
			case EditorEvent.ZOOM_OUT:
				map.modifyScale(-0.5);
				
			case EditorEvent.ZOOM_IN:
				map.modifyScale(0.5);
				
			case EditorEvent.RESET_MAP:
				map.reset();
				
			//case EditorEvent.CLOSE_EDITOR:
			//	enableActorsOnMap(false);
			//	map.addListeners();
			//	dispatchEvent(new EditorEvent(EditorEvent.CLOSE_EDITOR, map, true));
				
			case EditorEvent.HELP:
				trace("EditorEvent.HELP");
		}
	}
	
	/**
	 * Something on-screen has been moused over.
	 * @param {MouseEvent.MOUSE_OVER} e
	 */
	private function onMouseOver(e:MouseEvent):Void {
		
		// An actor as been dragged from the field back to the EditorSelectionBar.
		if (Std.is(e.target, EditorSelectionBar)) {
			
			Mouse.show();
			
			if (currentState == EditorEvent.ACTORS && selectedActor != null) {
				if (selectedActor.currentTile != null) {
					selectedActor.currentTile.removeOccupant();
					selectedActor.currentTile.highlight(false);
					selectedActor.startDrag(true);
					addChild(selectedActor);
				}
			}
		
		// Otherwise
		} else {
			e.stopImmediatePropagation();
			
			if (Std.is(e.target, Tile)) {
				
				var tile:Tile = cast(e.target);
				
				if (keysDown[KeyCodes.A]) {
					tile.addElevation(1);
				} else if (keysDown[KeyCodes.S]) {
					tile.addElevation(-1);
				} else if (keysDown[KeyCodes.D]) {
					tile.clone(selectedTile);
				}
			}	
			
		}
	}
	
	/**
	 * Something on-screen has been moused out.
	 * @param {MouseEvent.MOUSE_OUT} e
	 */
	private function onMouseOut(e:MouseEvent):Void {
		e.stopImmediatePropagation();
	}

	/**
	 * Highlight/Unhighlight a tile.
	 * @param {Dynamic} displayObject
	 * @param {Bool} value
	 */
	private function highlightTile(displayObject:Dynamic, value:Bool):Void {
		
		switch(currentState) {
			
			// Highlight the tile an actor is on.
			case EditorEvent.ACTORS:
				if (Std.is(displayObject, Actor)) {
					var actor:Actor = cast displayObject;
					if (actor.currentTile != null) {
						actor.currentTile.highlight(value);
					}
				} else if (Std.is(displayObject, Tile)) {
					var tile:Tile = cast displayObject;
					if (Std.is(tile.occupant, Actor)) {
						tile.highlight(value);
					}
				}
				
			// Highlight the tile.
			case EditorEvent.TILES:
				if (Std.is(displayObject, Tile)) {
					var tile:Tile = cast displayObject;
					map.setCurrentTile(tile);
					//if (mouseDown) {
					//	tile.clone(selectedTile);
					//}
					
					//tile.highlight(value);
				}
		}
	}
	
	/**
	 * User has mouse downed. Determine the user's intention.
	 * @param {MouseEvent.MOUSE_DOWN} e
	 */
	private function onMouseDown(e:MouseEvent):Void {
		
		mouseDown = true;

		switch(currentState) {
			
			case EditorEvent.ACTORS:
				
				destroyActor();
		
				// Mousedown upon an actor.
				if (Std.is(e.target, Actor)) {
					var actor:Actor = cast e.target;
					if (actor.currentTile != null) {
						selectedActor = actor;
					} else {
						selectedActor = actor.clone();
						map.allActors.push(selectedActor);
					}
				
				// Mousedown upon a tile.
				} else if (Std.is(e.target, Tile)) {
					var tile:Tile = cast e.target;
					if (tile.occupant != null) {
						selectedActor = tile.occupant;
					}
				}
				
				if(selectedActor != null) {
					dragStarted = false;
					selectedActor.mouseEnabled = false;
					editorSelectionBar.mouseChildren = false;
					addEventListener(MouseEvent.MOUSE_MOVE, onActorMove);
				}
			
			case EditorEvent.TILES:
						
				if (Std.is(e.target, Tile)) {
					dragStarted = false;
					addEventListener(MouseEvent.MOUSE_MOVE, onTileMove);
					//var tile:Tile = cast e.target;
			
					//if (e.shiftKey == true) {
					//	currentState = DRAG_MAP;
					//	map.mapLayer.mouseChildren = false;
					//	map.mapLayer.startDrag();
			
					//} else if (selectedTile != null) {
					//	tile.clone(selectedTile);
					//}
				}
		}
	}
	
	/**
	 * The mouse is held and being dragged on the screen.
	 * @param {MouseEvent.MOUSE_MOVE} e
	 */
	private function onTileMove(e:MouseEvent):Void {
		
		removeEventListener(MouseEvent.MOUSE_MOVE, onTileMove);
		dragStarted = true;
		
		if (Std.is(e.target, Tile)) {
			var tile:Tile = cast e.target;
			//tile.clone(selectedTile);
		}
	}
	
	/**
	 * User has mouse upped.
	 * @param {MouseEvent.MOUSE_UP} e
	 */
	private function onMouseUp(e:Event):Void {
			
		editorSelectionBar.mouseChildren = true;
		
		mouseDown = false;
		
		switch(currentState) {
			
			case EditorEvent.ACTORS:
			
				// The character has been dragged.
				if (dragStarted) {
					selectedActor.mouseEnabled = true;
					selectedActor.mouseChildren = true;
					
					if(selectedActor.currentTile != null) {
						selectedActor.currentTile.highlight(false);
					}
								
					// Drop the character back into the inventory.
					if (Std.is(e.target, EditorSelectionBar)) {
						destroyActor();
					}
			
				// Actor was clicked, not dragged. Flip him horizontally.
				} else if (selectedActor != null && selectedActor.currentTile != null) {
					selectedActor.scaleX *= -1;
				}
			
				enableActorsOnMap(true);
				
				removeEventListener(MouseEvent.MOUSE_MOVE, onActorMove);
			
				selectedActor = null;
				dragStarted = false;
		}
	}
	
	/**
	 * Enable all the actors in the field for dragging.
	 * @param {Bool} value
	 */
	private function enableActorsOnMap(value:Bool):Void {
		for (i in 0...map.allActors.length) {
			map.allActors[i].currentTile.mouseChildren = value;
			map.allActors[i].currentTile.buttonMode = value;
		}
	}
	
	private function destroyActor():Void {
		
		if (selectedActor != null) {
			
			if (selectedActor.parent != null) {
				selectedActor.parent.removeChild(selectedActor);
			}
				
			selectedActor.stopDrag();
			
			var actorIndex:Int = map.allActors.indexOf(selectedActor);
			if (actorIndex != -1) {
				map.allActors.splice(actorIndex, 1);
			}
			
			if (map.allActors.length == 0) {
				this.removeEventListener(Event.ENTER_FRAME, map.animateActors);
			}
		}
		
		selectedActor = null;
		dragStarted = false;
	}
	
	/**
	 * The mouse is held and being dragged on the screen.
	 * @param {MouseEvent.MOUSE_MOVE} e
	 */
	private function onActorMove(e:MouseEvent):Void {

		if (currentState == EditorEvent.ACTORS) {
			
			editorSelectionBar.mouseChildren = false;
			
			// The user has now started to drag an actor.
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
				if (Std.is(e.target, Tile)) {
					var tile:Tile = cast e.target;
					if(tile.occupant == null) {
						selectedActor.stopDrag();
						tile.addOccupant(selectedActor);
					}
				}
			}
		}
	}
	
	public function hide():Void {
		Actuate.tween(editorSelectionBar, 0.3, { y:Main.GAME_HEIGHT + 3 } ).ease(Cubic.easeOut).onComplete(onEditorClosed);
	}
	
	public function show():Void {
		addChildAt(map, 0);
		Actuate.tween(editorSelectionBar, 0.3, { y:Main.GAME_HEIGHT - 35 } ).ease(Cubic.easeOut);
	}
	
	private function onEditorClosed():Void {
		removeListeners();
		editorSelectionBar.removeListeners();
		var editorDispatcher:EditorDispatcher = EditorDispatcher.getInstance();
		editorDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DISPATCH, EditorEvent.CLOSED));
	}
	
	/**
	 * User has pressed a key.
	 * @param {KeyboardEvent.KEY_DOWN} e
	 */
	private function onKeyDown(e:KeyboardEvent):Void {
		
		if (keysDown[e.keyCode] || map.currentTile == null) {
			return;
		}
			
		var keyDown:Int = e.keyCode;
		keysDown[keyDown] = true;
		
		if (keysDown[KeyCodes.A]) {
			map.currentTile.addElevation(1);
			
		} else if (keysDown[KeyCodes.S]) {
			map.currentTile.addElevation( -1);
		
		} else if (keysDown[KeyCodes.D]) {
			map.currentTile.clone(selectedTile);
		}
	}
		
	/**
	 * User has released a key.
	 * @param {KeyboardEvent.KEY_UP} e
	 */
	private function onKeyUp(e:KeyboardEvent):Void {
		keysDown[e.keyCode] = false;
	}
	
	/**
	 * Add Listeners required for editing maps.
	 */
	private function addListeners():Void {
		
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		addEventListener(Event.MOUSE_LEAVE, onMouseUp);
		
		// Listen for keyDowns.
		var game:Game = Game.getInstance();
		game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, -1);
		game.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, -1);
	}
	
	/**
	 * Remove listeners.
	 */
	private function removeListeners():Void {
		
		removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
		
		// Listen for keyDowns.
		var game:Game = Game.getInstance();
		game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		game.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	public function cleanUp():Void {
		EditorDispatcher.getInstance().removeEventListener(EditorEvent.DISPATCH, onEditorDispatch);
		removeListeners();
		removeEventListener(MouseEvent.MOUSE_MOVE, onActorMove);
	}
}
