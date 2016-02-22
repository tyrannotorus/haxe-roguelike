package com.roguelike;

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
	 * Roguelike 0.01c Goals
	 * - ESC to open/close edit mode
	 * - Initial tile.update() ignores updating neighbours
	 * - Map scrollrect follows active tile
	 * - Bugfix: Edging bug on righthand side
	 * Shift + drag draws tiles.
	 * Bugfix: Void tiles not drawn
	 * Remove mouse from map.
	 * Wheelmouse zoom centers on active tile
	 * Highlight only the tile top.
	 * Elevation difference > 0 shadows only tile top (not vertical plane of tile).
	 * Elevation difference > 1 shadows occupant.
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
		stage.quality = StageQuality.LOW;
		stage.scaleMode = StageScaleMode.EXACT_FIT;
		
		game = Game.getInstance();
		game.scrollRect = new Rectangle(0, 0, GAME_WIDTH, GAME_HEIGHT);
		game.scaleX = game.scaleY = GAME_SCALE;
		addChild(game);
		
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
