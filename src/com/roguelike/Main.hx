package com.roguelike;

import com.roguelike.managers.ActorManager;
import com.roguelike.managers.MapManager;
import com.roguelike.managers.TextManager;
import com.roguelike.managers.TileManager;
import openfl.display.Sprite;
import openfl.display.StageDisplayState;
import openfl.display.StageQuality;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.geom.Rectangle;

/**
 * Main.as.
 */
class Main extends Sprite {
	
	/**
	 * GET FUNCTIONAL
	 * - Fix placing empty tiles
	 * - Save level
	 * - load level
	 * - starting point on map and player character.
	 * - Start game button
	 * - move from tile to tile
	 * 
	 * EXCITING STUFF
	 * - Use multiple maps for multiple levels of the same map
	 * - Stack tiles
	 * - Allow different tiles / no tiles in stacks.
	 * - Add liquid aquafer
	 * - consider 16x16 hitArea block for actors.
	 */
	
	public static inline var GAME_SCALE:Int = 1;
	public static inline var GAME_WIDTH:Int = 384;
	public static inline var GAME_HEIGHT:Int = 216;
	

	private var game:Game;
	
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		stage.quality = StageQuality.MEDIUM;
		stage.scaleMode = StageScaleMode.EXACT_FIT;
		
		TextManager.getInstance().init();
		
		var mapManager:MapManager = MapManager.getInstance();
		mapManager.addEventListener(Event.COMPLETE, init);
		mapManager.init();
		
		var tileManager:TileManager = TileManager.getInstance();
		tileManager.addEventListener(Event.COMPLETE, init);
		tileManager.init();
		
		var actorManager:ActorManager = ActorManager.getInstance();
		actorManager.addEventListener(Event.COMPLETE, init);
		actorManager.init();
	}
	
	/**
	 * Attempt to initialize the game (after assets are loaded)
	 * @param {Event.COMPLETE} e
	 */
	private function init(e:Event = null):Void {
		
		if (!MapManager.getInstance().isReady()) {
			return;
		} else if (!TileManager.getInstance().isReady()) {
			return;
		} else if (!ActorManager.getInstance().isReady()) {
			return;
		}
						
		game = new Game();
		game.scrollRect = new Rectangle(0, 0, GAME_WIDTH, GAME_HEIGHT);
		addChild(game);
		
		game.scaleX = game.scaleY = GAME_SCALE;
		game.loadGame();
		
		//var fps:FPS = new FPS(10, 10, Colors.RED);
		//addChild(fps);
				
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
	private function getStageWidth():UInt {
		
		var stageWidth:UInt = stage.stageWidth;
		
		#if flash
		if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
			stageWidth = stage.fullScreenWidth;
		}
		#end
		
		return stageWidth;
	}
	
	/**
	 * Returns height of stage in windowed or fullscreen
	 * @return {Int}
	 */
	private function getStageHeight():UInt {
		
		var stageHeight:UInt = stage.stageHeight;
		
		#if flash
		if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
			stageHeight = stage.fullScreenHeight;
		}
		#end
		
		return stageHeight;
	}
	
	/**
	 * Called automatically on resize of the swf. Scales and positions the game container
	 * @param {Event.RESIZE} e
	 */
	private function onGameResize(e:Event):Void {
		
		var scale:Float = 1;
		var stageWidth:UInt = getStageWidth();
		var stageHeight:UInt = getStageHeight();
				
		// Find which dimension to scale by
		if (GAME_WIDTH / stageWidth > GAME_HEIGHT / stageHeight) {
			scale = stageWidth / GAME_WIDTH;		
		} else {
			scale = stageHeight / GAME_HEIGHT;
		}
		
		scale = Math.floor(scale);
		game.scaleX = game.scaleY = scale;
		game.x = Std.int((stageWidth - (GAME_WIDTH * scale)) * 0.5);
		game.y = Std.int((stageHeight - (GAME_HEIGHT * scale)) * 0.5);
	}
}
