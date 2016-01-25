package bubblebobble.editor;

import bubblebobble.dialogs.ActorsDialog;
import bubblebobble.dialogs.TilesDialog;
import bubblebobble.dialogs.ItemContainer;
import com.tyrannotorus.utils.Colors;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

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
		levelLayer.graphics.beginFill(Colors.BLACK);
		levelLayer.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
		levelLayer.graphics.endFill();
		addChild(levelLayer);
		
		// Create the tiles layers.
		tilesLayer = new Sprite();
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
		tilesDialog.loadTiles();
		dialogLayer.addChild(tilesDialog);
		
		// Create and add the actors dialog.
		actorsDialog = new ActorsDialog();
		actorsDialog.loadActors();
		dialogLayer.addChild(actorsDialog);
		
		actorsDialog.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
		actorsDialog.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
		this.addEventListener(MouseEvent.CLICK, onMouseClick);
		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		this.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
	}
	
	private function onTilesLoaded(e:Event):Void {
		
		tilesDialog.removeEventListener(Event.COMPLETE, onTilesLoaded);
		
		//Fill tiles layer with tiles.
		var fillTile:Tile = tilesDialog.getTileByName("terrain1.png");
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
					tile.tint(Colors.BUBBLEGUM, 1);
				}
			}
			
			yPosition += halfHeight;
			
			if (Math.floor(yPosition % tileHeight) == 0) {
				xPosition = halfWidth;
			} else {
				xPosition = tileWidth;
			}
			xPosition = (Math.floor(yPosition % tileHeight) == 0) ? tileWidth : halfWidth;
			
			
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
			
			//trace("onMouseDown actor selected");
			
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
			
		// A tile in the field was mouse downed upon.
		} else if (e.target.parent != null && e.target.parent.parent == levelLayer) {
		
			// We are eyedropping the tile.
			//if (e.shiftKey == true) {
				//trace("select tile");
				//tilesDialog.setSelectedTile(e.target);
			
			// We are setting the tile.
			/*} else */if (selectedTile != null && Std.is(e.target, Tile)) {
				var mouseOverTile:Tile = cast(e.target, Tile);
				mouseOverTile.clone(selectedTile);
				state = PLACE_TILE;
			}
					
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
				
				// Position the actor in 8 pixel increments.
				if (Std.is(e.target, Tile)) {
					var tile:Tile = cast(e.target, Tile);
					selectedActor.x = tile.x;
					selectedActor.y = tile.y;
				}
				
				// Ensure the actor is inside the ounds of the level.
				//selectedActor.x = (x <= 0) ? halfWidth : (x < Main.GAME_WIDTH) ? x : Main.GAME_WIDTH - halfWidth;
				//selectedActor.y = (y < this.y) ? this.y : (y >= Main.GAME_HEIGHT - this.y - halfWidth) ? Main.GAME_HEIGHT - this.y - halfWidth : y;
			}
		
		// We are placing tiles.
		} else if (state == PLACE_TILE && Std.is(e.target, Tile)) {
			var mouseOverTile:Tile = cast(e.target, Tile);
			mouseOverTile.clone(selectedTile);
		}
	}
	
	/**
	 * User mouse clicked.
	 * @param {MouseEvent.CLICK} e
	 */
	private function onMouseClick(e:MouseEvent):Void {
		
		if (Std.is(e.target, Tile)) {
			
			var tile:Tile = cast(e.target, Tile);
			
			if (e.shiftKey == true) {
				tile.reduceHeight();
			} else {
				tile.increaseHeight();
			}
		}

		
		// A tile in the tiles dialog was selected.
		if (tilesDialog.getSelectedTile(e.target) != null) {
			//trace("onMouseClick selectedTile " + selectedTile);
			selectedTile = tilesDialog.getSelectedTile(e.target, true);
			//selectedTile.name = e.target.name;
			
		}
	}
	
	
	
}
