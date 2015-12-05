package bubblebobble.levels;

import bubblebobble.dialogs.TilesDialog;
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
	private var dialogLayer:Sprite;
	private var bub:Actor;
	private var tilesDialog:TilesDialog;
	private var selectedTile:Bitmap;
	private var tilesArray:Array<Array<Bitmap>>;
	
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
		
		// Create the dialog layer.
		dialogLayer = new Sprite();
		addChild(dialogLayer);
		
		// Create the tiles array holding the level data.
		tilesArray = new Array<Array<Bitmap>>();
		
		// Create and add the tiles dialog.
		tilesDialog = new TilesDialog();
		tilesDialog.loadTiles();
		tilesDialog.addEventListener(MouseEvent.CLICK, onTileSelected);
		dialogLayer.addChild(tilesDialog);
		
		// Create Bub.
		var bubSpritesheet:BitmapData = Assets.getBitmapData("actors/bub_spritesheet.png");
		var bubLogic:String = Assets.getText("actors/bub_logic.txt");
		var bubData:Dynamic = ActorUtils.parseActorData(bubSpritesheet, bubLogic);
		bub = new Actor(bubData);
		Utils.position(bub, 8, 8);
		dialogLayer.addChild(bub);
		
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
	 * User has mouse downed over the stage.
	 * @param {MouseEvent.MOUSE_DOWN} e
	 */
	private function onMouseDown(e:MouseEvent):Void {
		
		if (selectedTile == null) {
			e.stopImmediatePropagation();
			return;
		}
		
		placeTile(e.localX, e.localY);
		levelLayer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}
	
	/**
	 * User is placing tiles on the level.
	 * @param {MouseEvent.MOUSE_MOVE} e
	 */
	private function onMouseMove(e:MouseEvent):Void {
		placeTile(e.localX, e.localY);
		
	}
	
	/**
	 * Place our selected tile on the stage.
	 * @param {Float} x
	 * @param {Float} y
	 */
	private function placeTile(x:Float, y:Float):Void {
		
		var tileX:Int = Math.floor(x / 8) * 8;
		var tileY:Int = Math.floor(y / 8) * 8;
			
		if (tilesArray[tileX] == null) {
			tilesArray[tileX] = new Array<Bitmap>();
		}
		
		var tileBitmap:Bitmap = tilesArray[tileX][tileY];
		
		if (tileBitmap == null) {
			tileBitmap = new Bitmap();
			tileBitmap.x = tileX;
			tileBitmap.y = tileY;
			tilesArray[tileX][tileY] = tileBitmap;
			
			levelLayer.addChild(tileBitmap);
		}
		
		tileBitmap.bitmapData = selectedTile.bitmapData;
	}
	
	/**
	 * Kill out mouse move listener on mouse up.
	 * @param {MouseEvent.MOUSE_UP} e
	 */
	private function onMouseUp(e:MouseEvent):Void {
		levelLayer.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}
	
	/**
	 * Add listeners.
	 */
	private function addListeners():Void {
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		levelLayer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		levelLayer.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
	
	/**
	 * Remove Listeners.
	 */
	private function removeListeners():Void {
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		levelLayer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		levelLayer.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		levelLayer.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
	
	/**
	 * Animate an creatures on the level.
	 */	
	private function onEnterFrame(e:Event):Void {
		bub.animate();
	}
	
}
