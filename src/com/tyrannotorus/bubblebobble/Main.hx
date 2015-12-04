package com.tyrannotorus.bubblebobble;

import com.tyrannotorus.bubblebobble.utils.Constants;
import openfl.display.Sprite;
import openfl.display.StageDisplayState;
import openfl.events.Event;

class Main extends Sprite {

	private var game:Game;
	
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
				
		game = new Game();
		addChild(game);
		addListeners();
		
		game.loadGame();
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
		var gameWidth:Int = Constants.GAME_WIDTH;
		var gameHeight:Int = Constants.GAME_HEIGHT;
				
		// Find which dimension to scale by
		if (gameWidth / stageWidth > gameHeight / stageHeight) {
			scale = stageWidth / gameWidth;		
		} else {
			scale = stageHeight / gameHeight;
		}
					
		game.scaleX = game.scaleY = scale;
		game.x = Std.int((stageWidth - (gameWidth * scale)) * 0.5);
		game.y = Std.int((stageHeight - (gameHeight * scale)) * 0.5);
	}
}
