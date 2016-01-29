package roguelike.editor;

import roguelike.dialogs.ActorsDialog;
import roguelike.dialogs.ItemContainer;
import roguelike.dialogs.TilesDialog;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import roguelike.Actor;
import roguelike.Main;
import roguelike.managers.TileManager;

/**
 * LevelEditor.as
 * - A Level editor.
 */
class LevelEditor extends Sprite {
	
	// States
	private static inline var DRAG_ACTOR:String = "DRAG_ACTOR";
	private static inline var PLACE_TILE:String = "PLACE_TILE";
	
	private var state:String;
	private var levelLayer:Sprite;
	private var tilesLayer:Sprite;
	private var actorsLayer:Sprite;
	private var dialogLayer:Sprite;

	private var tilesDialog:TilesDialog;
	private var actorsDialog:ActorsDialog;
	private var selectedTile:Tile;
	private var selectedActor:Actor;
	private var selectedActorDragged:Bool;
	private var tilesArray:Array<Array<Tile>> = new Array<Array<Tile>>();
	private var allTiles:Array<Tile> = new Array<Tile>();
	private var tileWidth:Int;
	private var tileHeight:Int;
	private var halfWidth:Int;
	private var halfHeight:Int;
		
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		
		// Create the level layer with black background.
		levelLayer = new Sprite();
		levelLayer.mouseEnabled = false;
		addChild(levelLayer);
		
		// Create the tiles layers.
		tilesLayer = new Sprite();
		tilesLayer.addEventListener(MouseEvent.MOUSE_OUT, onTileRollOut);
		tilesLayer.addEventListener(MouseEvent.MOUSE_OVER, onTileRollOver);
		tilesLayer.addEventListener(MouseEvent.CLICK, onTileClick);
		levelLayer.addChild(tilesLayer);
		
		actorsLayer = new Sprite();
		actorsLayer.mouseEnabled = false;
		addChild(actorsLayer);
				
		// Create the dialog layer.
		dialogLayer = new Sprite();
		addChild(dialogLayer);
		
		// Create and add the tiles dialog.
		tilesDialog = new TilesDialog();
		tilesDialog.addEventListener(Event.COMPLETE, onTilesLoaded);
		tilesDialog.addEventListener(Event.SELECT, onTileSelected);
		dialogLayer.addChild(tilesDialog);
				
		// Create and add the actors dialog.
		actorsDialog = new ActorsDialog();
		dialogLayer.addChild(actorsDialog);
		
		actorsDialog.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
		actorsDialog.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
		//this.addEventListener(MouseEvent.CLICK, onMouseClick);
		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		this.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
	}
	
	private function onTileClick(e:MouseEvent):Void {
		
		var selectedTile:Tile = tilesDialog.getSelectedTile();
		if (selectedTile != null && Std.is(e.target, Tile)) {
			var tile:Tile = cast(e.target, Tile);
			tile.clone(selectedTile);
		}
	}
	
	private function onTileRollOver(e:MouseEvent):Void {
		e.stopImmediatePropagation();
		//trace("onTileRollOver " + e.target.name);
		if (Std.is(e.target, Tile)) {
			
			var tile:Tile = cast(e.target, Tile);
			
			if (state == PLACE_TILE) {
				var selectedTile:Tile = tilesDialog.getSelectedTile();
				if(selectedTile != null) {
					tile.clone(tilesDialog.getSelectedTile());
				}					
			}
			
			tile.highlight(true);
		}
	}
	
	private function onTileRollOut(e:MouseEvent):Void {
		e.stopImmediatePropagation();
		//trace("onTileRollOut " + e.target.name);
		if (Std.is(e.target, Tile)) {
			cast(e.target, Tile).highlight(false);
		}
	}
	
	private function onTileSelected(e:Event):Void {
		trace("onTileSelected");
	}
	
	private function onTilesLoaded(e:Event):Void {
		
		tilesDialog.removeEventListener(Event.COMPLETE, onTilesLoaded);
		
		var fillTile:Tile = TileManager.getInstance().getTile("empty.png");
		tileWidth = Math.floor(fillTile.width);
		halfWidth = Math.floor(tileWidth / 2);
		tileHeight = halfWidth;
		halfHeight = Math.floor(tileHeight / 2);
		var xPosition:Int = halfWidth;
		var yPosition:Int = halfHeight;
		
		while (yPosition + (2 * tileHeight) < Main.GAME_HEIGHT) {
			
			while (xPosition + tileWidth < Main.GAME_WIDTH) {
				var tile:Tile = fillTile.clone();
				tile.x = xPosition;
				tile.y = yPosition;
				allTiles.push(tile);
				tilesLayer.addChild(tile);
				xPosition += tileWidth;
				
				if (Math.floor(yPosition % tileHeight) == 0) {
					tile.tint();
				}
			}
			
			yPosition += halfHeight;
			
			if (Math.floor(yPosition % tileHeight) == 0) {
				xPosition = halfWidth;
			} else {
				xPosition = tileWidth;
			}
			xPosition = (Math.floor(yPosition % tileHeight) == 0) ? tileWidth : halfWidth;
			
			//trace(xPosition + " " + yPosition);
			
			
		}
		
	}
	
	/**
	 * If we're dragging an actor onto the actors dialog.
	 * @param {MouseEvent.ROLL_OVER} e
	 */
	private function onMouseRollOver(e:MouseEvent):Void {
				
		if (state == DRAG_ACTOR) {
			
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
			
		if (state == DRAG_ACTOR) {
			
			if (selectedActor != null) {
				selectedActor.stopDrag();
				actorsLayer.addChild(selectedActor);
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
			
			trace("onMouseDown actor selected");
			
			// Actor is being clicked in the level.
			if (e.target.parent == actorsLayer) {
				selectedActor = cast(e.target, Actor);
							
			// Actor is being clikced in the actors inventory dialog.
			} else {
				selectedActor = actorsDialog.getActor(e.target);
			}
						
			state = DRAG_ACTOR;
			selectedActorDragged = false;
			actorsDialog.mouseChildren = false;
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
		// A tile in the field was mouse downed upon.
		} else if (Std.is(e.target, Tile)) {
			var tile:Tile = cast(e.target, Tile);
			var selectedTile:Tile = tilesDialog.getSelectedTile();
			if (selectedTile != null) {
				tile.clone(selectedTile);
			}
			//mouseOverTile.clone(selectedTile);
			//state = PLACE_TILE;
		
			// We are eyedropping the tile.
			//if (e.shiftKey == true) {
				//trace("select tile");
				//tilesDialog.setSelectedTile(e.target);
			
			// We are setting the tile.
			/*} else *///if (selectedTile != null && Std.is(e.target, Tile)) {
				//var mouseOverTile:Tile = cast(e.target, Tile);
				//mouseOverTile.clone(selectedTile);
				state = PLACE_TILE;
			//}
					
		}
	}
	
	
	
	/**
	 * User has mouse upped.
	 * @param {MouseEvent.MOUSE_UP} e
	 */
	private function onMouseUp(e:Event):Void {
	//	trace("onMouseUp() " + e.type + " " + e.target + " " + e.currentTarget);
		
		actorsDialog.mouseChildren = true;
		
		if (state == DRAG_ACTOR) {
			
			// The character has been dragged.
			if (selectedActorDragged) {
				
				selectedActor.mouseEnabled = true;
				selectedActor.mouseChildren = true;
								
				// Drop the character back into the inventory.
				if (Std.is(e.target, ActorsDialog)) {
					destroyActor();
				
				// Drop character onto the level	
				}
			
			// Actor was clicked, not dragged. Flip him horizontally.
			} else if(!Std.is(selectedActor.parent, ItemContainer)){
				selectedActor.scaleX *= -1;
			}
			
			selectedActor = null;
			selectedActorDragged = false;
		}
		
		state = null;
	}
	
	private function destroyActor():Void {
		
		if (selectedActor != null) {
			
			if (selectedActor.parent != null) {
				selectedActor.parent.removeChild(selectedActor);
			}
				
			selectedActor.stopDrag();
			actorsDialog.removeActor(selectedActor);
		}
		
		selectedActor = null;
		selectedActorDragged = false;
	}
	
	/**
	 * A Tile was selected within the tiles dialog.
	 * @param {MouseEvent.CLICK} e
	 */
	private function onMouseMove(e:MouseEvent):Void {
		
		if (state == DRAG_ACTOR) {
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			// The user has begun dragging the character.
			if (!selectedActorDragged) {
				
				selectedActor.mouseEnabled = false;
				selectedActor.mouseChildren = false;
				selectedActorDragged = true;
				
				if (selectedActor.parent != actorsLayer) {
					selectedActor.startDrag(true);
					addChild(selectedActor);
				}
			}
			
			//**
			 // ADD ACTORS TO TILE
			if (selectedActor.parent == actorsLayer) {
				
				// Lock actor to a tile.
				if (Std.is(e.target, Tile)) {
					var tile:Tile = cast(e.target, Tile);
					selectedActor.x = tile.x;
					selectedActor.y = tile.y;
				
				} 
			}
		
		
		}
	}
	
		
}
