package bubblebobble.editor;

import bubblebobble.dialogs.TilesDialog;
import bubblebobble.dialogs.ActorsDialog;
import com.tyrannotorus.utils.ActorUtils;
import com.tyrannotorus.utils.Colors;
import com.tyrannotorus.utils.Utils;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * LevelEditor.as
 * - A Level editor.
 */
class LevelEditor extends Sprite {
	
	private var levelLayer:Sprite;
	private var largeTilesLayer:Sprite;
	private var smallTilesLayer:Sprite;
	private var dialogLayer:Sprite;
	private var bub:Actor;
	private var tilesDialog:TilesDialog;
	private var actorsDialog:ActorsDialog;
	private var selectedTile:Bitmap;
	private var largeTilesArray:Array<Array<Sprite>>;
	private var smallTilesArray:Array<Array<Sprite>>;
	
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
		addChild(largeTilesLayer);
		smallTilesLayer = new Sprite();
		addChild(smallTilesLayer);
				
		// Create the dialog layer.
		dialogLayer = new Sprite();
		addChild(dialogLayer);
		
		// Create the tiles array holding the level data.
		smallTilesArray = new Array<Array<Sprite>>();
		largeTilesArray = new Array<Array<Sprite>>();
		
		//actorPool = new Array<Actor>();
		
		// Create and add the tiles dialog.
		tilesDialog = new TilesDialog();
		tilesDialog.loadTiles();
		tilesDialog.addEventListener(MouseEvent.CLICK, onTileSelected);
		dialogLayer.addChild(tilesDialog);
		
		// Create and add the actors dialog.
		actorsDialog = new ActorsDialog();
		actorsDialog.loadActors();
		actorsDialog.addEventListener(MouseEvent.MOUSE_DOWN, onActorSelected);
		dialogLayer.addChild(actorsDialog);
		
		addListeners();
	}
	
	/**
	 * A Tile was selected within the tiles dialog.
	 * @param {MouseEvent.CLICK} e
	 */
	private function onTileSelected(e:MouseEvent):Void {
		selectedTile = tilesDialog.getSelectedTile();
	}
	
	/**
	 * Mouse Downed over an actor.
	 * @param {MouseEvent.CLICK} e
	 */
	private function onActorSelected(e:MouseEvent):Void {
		
		var selectedActor:Actor = actorsDialog.getActor(e.target);
		
		if (selectedActor != null) {
			selectedTile = null;
			addChild(selectedActor);
			selectedActor.startDrag(true);
			selectedActor.addEventListener(MouseEvent.MOUSE_UP, onStopActorDrag);
			removePlaceTileListeners();
		}
	}
	
	private function onStopActorDrag(e:MouseEvent):Void {
		trace("onMouseUp");
		var actor:Actor = cast(e.target, Actor);
		actor.stopDrag();
	}
	
	/**
	 * User has mouse downed over the stage.
	 * @param {MouseEvent.MOUSE_DOWN} e
	 */
	private function onMouseDown(e:MouseEvent):Void {
		
		if (selectedTile == null) {
			e.stopImmediatePropagation();
			return;
		}
				
		placeTile(levelLayer.mouseX, levelLayer.mouseY);
		this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		this.stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
	}
	
	/**
	 * User is placing tiles on the level.
	 * @param {MouseEvent.MOUSE_MOVE} e
	 */
	private function onMouseMove(e:MouseEvent):Void {
		placeTile(levelLayer.mouseX, levelLayer.mouseY);
	}
	
	private function removePlaceTileListeners():Void {
		levelLayer.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		this.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
		this.stage.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
	}
	
	/**
	 * Place our selected tile on the stage.
	 * @param {Float} x
	 * @param {Float} y
	 */
	private function placeTile(x:Float, y:Float):Void {
		
		var tileWidth:Int = Std.int(selectedTile.width);
		var tileX:Int = Math.floor(x / tileWidth) * tileWidth;
		var tileY:Int = Math.floor(y / tileWidth) * tileWidth;
		var tilesArray:Array<Array<Sprite>>;
		var tilesLayer:Sprite;
		
		if (tileWidth == 8) {
			tilesArray = smallTilesArray;
			tilesLayer = smallTilesLayer;
		
		} else {
			tilesArray = largeTilesArray;
			tilesLayer = largeTilesLayer;
		}
		
		if (tilesArray[tileX] == null) {
			tilesArray[tileX] = new Array<Sprite>();
		}
		
		var tileSprite:Sprite = tilesArray[tileX][tileY];
		var tileBitmap:Bitmap;
				
		if (tileSprite == null) {
			tileBitmap = new Bitmap();
			tileSprite = new Sprite();
			tileSprite.mouseChildren = false;
			tileSprite.mouseEnabled = true;
			tileSprite.addChild(tileBitmap);
			tileSprite.x = tileX;
			tileSprite.y = tileY;
			tilesArray[tileX][tileY] = tileSprite;
			tilesLayer.addChild(tileSprite);
		
		} else {
			tileBitmap = cast(tileSprite.getChildAt(0), Bitmap);
		}
		
		if (tileWidth == 16) {
			removeTile(smallTilesArray, smallTilesLayer, tileX, tileY);
			removeTile(smallTilesArray, smallTilesLayer, tileX + 8, tileY);
			removeTile(smallTilesArray, smallTilesLayer, tileX, tileY + 8);
			removeTile(smallTilesArray, smallTilesLayer, tileX + 8, tileY + 8);
		}
		
		tileBitmap.bitmapData = selectedTile.bitmapData;
	}
	
	/**
	 * Removes a tile at from paramters position.
	 * @param {Int} tileX
	 * @param {Int} tileY
	 */
	private function removeTile(tilesArray:Array<Array<Sprite>>, tilesLayer:Sprite, tileX:Int, tileY:Int):Void {
		if (tilesArray[tileX] != null && tilesArray[tileX][tileY] != null) {
			tilesLayer.removeChild(tilesArray[tileX][tileY]);
			tilesArray[tileX][tileY] = null;
		}
	}
	
	/**
	 * Kill out mouse move listener on mouse up.
	 * @param {MouseEvent.MOUSE_UP} e
	 */
	private function onMouseUp(e:Event):Void {
		this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		this.stage.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
	}
	
	/**
	 * Add listeners.
	 */
	private function addListeners():Void {
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
	
	/**
	 * Remove Listeners.
	 */
	private function removeListeners():Void {
		this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		levelLayer.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		this.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
		this.stage.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
	}
	
	/**
	 * Animate an creatures on the level.
	 */	
	private function onEnterFrame(e:Event):Void {
		//bub.animate();
	}
	
}
