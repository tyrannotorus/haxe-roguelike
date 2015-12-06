package bubblebobble;

import openfl.display.Sprite;
import openfl.display.StageDisplayState;
import openfl.events.Event;
import openfl.geom.Rectangle;

class Main extends Sprite {
	
	public static inline var GAME_WIDTH:Int = 384;
	public static inline var GAME_HEIGHT:Int = 216;
	//public static inline var GAME_OFFSET_Y:Int = 8;
	public static inline var GAME_SCALE:Int = 1;

	private var game:Game;
	
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
				
		game = new Game();
		//game.y = GAME_OFFSET_Y;
		//game.scrollRect = new Rectangle(0, 0, GAME_WIDTH, GAME_HEIGHT);
		addChild(game);
		
		game.scaleX = game.scaleY = GAME_SCALE;
		game.loadGame();
				
		addListeners();
	}
	
	/**
	 * Adds Listeners necessary to game.
	 */
	private function addListeners():Void {
		stage.addEventListener(Event.RESIZE, onGameResize);
	}
	
	/**
	 * Returns width of stage in windowed or fullscreen
	 * @return {Int}
	 */
	private function getStageWidth():Int {
		return (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) ? stage.fullScreenWidth : stage.stageWidth;
	}
	
	/**
	 * Returns height of stage in windowed or fullscreen
	 * @return {Int}
	 */
	private function getStageHeight():Int {
		return (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) ? stage.fullScreenHeight : stage.stageHeight;
	}
	
	/**
	 * Called automatically on resize of the swf. Scales and positions the game container
	 * @param {Event.RESIZE} e
	 */
	private function onGameResize(e:Event):Void {
		
		var scale:Float = 1;
		var stageWidth:Int = getStageWidth();
		var stageHeight:Int = getStageHeight();
				
		// Find which dimension to scale by
		if (GAME_WIDTH / stageWidth > GAME_HEIGHT / stageHeight) {
			scale = stageWidth / GAME_WIDTH;		
		} else {
			scale = stageHeight / GAME_HEIGHT;
		}
					
		game.scaleX = game.scaleY = scale;
		game.x = Std.int((stageWidth - (GAME_WIDTH * scale)) * 0.5);
		game.y = Std.int((stageHeight - (GAME_HEIGHT * scale)) * 0.5);
	}
}
