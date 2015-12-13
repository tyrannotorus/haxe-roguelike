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
	private var largeTilesLayer:Sprite;
	private var smallTilesLayer:Sprite;
	private var actorsLayer:Sprite;
	private var dialogLayer:Sprite;

	private var tilesDialog:TilesDialog;
	private var actorsDialog:ActorsDialog;
	private var selectedTile:Tile;
	private var selectedActor:Actor;
	private var selectedActorDragged:Bool;
	private var originalMouseX:Int = 0;
	private var originalMouseY:Int = 0;
	private var largeTilesArray:Array<Array<Tile>> = new Array<Array<Tile>>();
	private var smallTilesArray:Array<Array<Tile>> = new Array<Array<Tile>>();
	
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
		largeTilesLayer = new Sprite();
		levelLayer.addChild(largeTilesLayer);
		smallTilesLayer = new Sprite();
		levelLayer.addChild(smallTilesLayer);
		
		actorsLayer = new Sprite();
		addChild(actorsLayer);
				
		// Create the dialog layer.
		dialogLayer = new Sprite();
		addChild(dialogLayer);
		
		// Create and add the tiles dialog.
		tilesDialog = new TilesDialog();
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
		this.addEventListener(MouseEvent.ROLL_OUT, onMouseUp);
		this.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
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
		trace(e.shiftKey );
		destroyActor();
		
		originalMouseX = (Math.floor(levelLayer.mouseX / 8) * 8) % 16;
		originalMouseY = (Math.floor(levelLayer.mouseY / 8) * 8) % 16;
		
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
			
		// A tile in the field was mouse downed upon.
		} else if (e.target.parent != null && e.target.parent.parent == levelLayer) {
		
			// We are eyedropping the tile.
			if (e.shiftKey == true) {
				trace("select tile");
				tilesDialog.setSelectedTile(e.target);
			
			// We are setting the tile.
			} else {
				placeTile(levelLayer.mouseX, levelLayer.mouseY, selectedTile);
				state = PLACE_TILE;
			}
					
		// An empty space in the level layer was mouse downed upon. Place a tile.
		} else if (e.target == levelLayer) {
		
			if(selectedTile != null) {
				placeTile(levelLayer.mouseX, levelLayer.mouseY, selectedTile);
				state = PLACE_TILE;
			}
		}
	}
	
	
	/**
	 * User has mouse upped.
	 * @param {MouseEvent.MOUSE_UP} e
	 */
	private function onMouseUp(e:Event):Void {
		trace("onMouseUp() " + e.type + " " + e.target + " " + e.currentTarget);
		
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
				} else {
					var selectedActorX:Int = Std.int(selectedActor.x - 8);
					var selectedActorY:Int = Std.int(selectedActor.y - 8);
					eraseQuadrant(selectedActorX, selectedActorY);
					eraseTile(selectedActorX, selectedActorY, largeTilesArray);
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
			
			if (selectedActor.parent == actorsLayer) {
				
				// Position the actor in 8 pixel increments.
				var halfWidth:Int = Std.int(selectedActor.width / 2);
				var x:Float = Math.floor(actorsLayer.mouseX / halfWidth) * halfWidth;
				var y:Float = Math.floor(actorsLayer.mouseY / halfWidth) * halfWidth;
				
				// Ensure the actor is inside the ounds of the level.
				selectedActor.x = (x <= 0) ? halfWidth : (x < Main.GAME_WIDTH) ? x : Main.GAME_WIDTH - halfWidth;
				selectedActor.y = (y < this.y) ? this.y : (y >= Main.GAME_HEIGHT - this.y - halfWidth) ? Main.GAME_HEIGHT - this.y - halfWidth : y;
			}
		
		// We are placing tiles.
		} else if (state == PLACE_TILE) {
			placeTile(levelLayer.mouseX, levelLayer.mouseY, selectedTile);
		}
	}
	
	/**
	 * Place our selected tile on the stage.
	 * @param {Float} x
	 * @param {Float} y
	 * @param {Tile} tile
	 */
	private function placeTile(x:Float, y:Float, tile:Tile):Void {
		
		if (tile == null && selectedTile == null) {
			trace("placeTile() selectedTile == null");
			state = null;
			return;
		}
		
		var tileWidth:Int = Std.int(tile.width);
		var tileX:Int = Math.floor(x / 8) * 8;
		var tileY:Int = Math.floor(y / 8) * 8;
		var tilesArray:Array<Array<Tile>>;
		var tilesLayer:Sprite;
		
		if (tileWidth == 8) {
			tilesArray = smallTilesArray;
			tilesLayer = smallTilesLayer;
		
		} else {
			tilesArray = largeTilesArray;
			tilesLayer = largeTilesLayer;
			tileX += (originalMouseX - tileX) % 16;
			tileY += (originalMouseY - tileY) % 16;
		}
		
		if (tilesArray[tileX] == null) {
			tilesArray[tileX] = new Array<Tile>();
		}
		
		var existingTile:Tile = tilesArray[tileX][tileY];
				
		if (existingTile == null) {
			existingTile = new Tile();
			existingTile.clone(tile);
			existingTile.mouseChildren = false;
			existingTile.mouseEnabled = true;
			existingTile.x = tileX;
			existingTile.y = tileY;
			tilesArray[tileX][tileY] = existingTile;
			tilesLayer.addChild(existingTile);
		
		} else {
			existingTile.clone(tile);
		}
		
		if (tileWidth == 16) {
			eraseQuadrant(tileX, tileY);
		}
		
		//trace("placing " + existingTile.name);
	}
	
	private function eraseQuadrant(tileX:Int, tileY:Int):Void {
		eraseTile(tileX, tileY, smallTilesArray);
		eraseTile(tileX + 8, tileY, smallTilesArray);
		eraseTile(tileX, tileY + 8, smallTilesArray);
		eraseTile(tileX + 8, tileY + 8, smallTilesArray);
	}
	
	private function eraseTile(tileX:Int, tileY:Int, tilesArray:Array<Array<Tile>>):Void {
		if (tilesArray[tileX] != null && tilesArray[tileX][tileY] != null) {
			var tile:Tile = tilesArray[tileX][tileY];
			tile.parent.removeChild(tile);
			tilesArray[tileX][tileY] = null;
		}
	}

	
	private function setQuadrantToTile(tileX:Int, tileY:Int, tile:Tile = null):Void {
		
		if (tile == null) {
			tile = tilesDialog.getTileByName("000a.png");
		}
		trace(tile.width);
		placeTile(tileX, tileY, tile);
		placeTile(tileX + 8, tileY, tile);
		placeTile(tileX, tileY + 8, tile);
		placeTile(tileX + 8, tileY + 8, tile);
	}
	
	
	
	/**
	 * User mouse clicked.
	 * @param {MouseEvent.CLICK} e
	 */
	private function onMouseClick(e:MouseEvent):Void {
		
		// A tile in the tiles dialog was selected.
		if (tilesDialog.getSelectedTile(e.target) != null) {
			trace("onMouseClick selectedTile " + selectedTile);
			selectedTile = tilesDialog.getSelectedTile(e.target, true);
			//selectedTile.name = e.target.name;
			
		}
	}
	
	
	
}
