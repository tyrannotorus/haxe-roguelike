package com.roguelike;

import com.roguelike.editor.Editor;
import com.roguelike.editor.EditorEvent;
import com.roguelike.editor.Map;
import com.tyrannotorus.utils.KeyCodes;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

/**
 * Game.as.
 * - The main game stage.
 */
class Game extends Sprite {
		
	private var player:Actor;
	private var opponent:Actor;
	private var editor:Editor;
	private var map:Map;
	
	// Keyboard Controls
	private var zKey:Bool = false;
	private var xKey:Bool = false;
	private var cKey:Bool = false;
	private var upKey:Bool = false;
	private var downKey:Bool = false;
	private var leftKey:Bool = false;
	private var rightKey:Bool = false;
	private var shiftKey:Bool = false;
		
	// Music and sfx
	private var music:Sound;
	private var musicChannel:SoundChannel;
	private var musicTransform:SoundTransform;
	
	/**
	 * Constructor.
	 */
	public function new() {
		super();
	}
	
	/**
	 * Initiate load of the game.
	 */
	public function loadGame():Void {
		
		editor = new Editor();
		editor.addEventListener(EditorEvent.CLOSE_EDITOR, onCloseEditor);
		addChild(editor);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onGameKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onGameKeyUp);
			
		
		//musicTransform = new SoundTransform(0.1);
		//music = Assets.getSound("audio/title_music.mp3", true);
		//musicChannel = music.play();
		//musicChannel.soundTransform = musicTransform;
	}
	
	public function onCloseEditor(e:EditorEvent):Void {
		
		map = cast e.data;
				
		player = map.allActors[0];
		map.setCurrentTile(player.currentTile);
			
		editor.removeEventListener(EditorEvent.CLOSE_EDITOR, onCloseEditor);
		editor.parent.removeChild(editor);
		editor.cleanUp();
		editor = null;
		
		addChild(map);
	}
	

	
	private function onGameKeyDown(e:KeyboardEvent):Void {
		
		trace(e.keyCode + " " + e.shiftKey);
		
		//map.moveCurrentTile(e.keyCode);
		if(player != null) {
			player.moveToTile(e.keyCode);
		}
		
		switch(e.keyCode) {
			
			// Left key
			case KeyCodes.LEFT:
				if (leftKey == false) {
					leftKey = true;
				}
			
			// Up key
			case KeyCodes.UP:
				if (upKey == false) {
					upKey = true;
				}
			
			// Right Key
			case KeyCodes.RIGHT:
				if (rightKey == false) {
					rightKey = true;
				}
			
			// Down Key
			case KeyCodes.DOWN:
				if (downKey == false) {
					downKey = true;
				}
			
			// X Key
			case KeyCodes.X:
				if (xKey == false && zKey == false) {
					xKey = true;
					if (upKey == true) {
						//player.highPunchA();
					} else {
						//player.lowPunchA();
					}
				}
			
			// Z Key
			case KeyCodes.Z:
				if (zKey == false && xKey == false) {
					zKey = true;
					if (upKey == true) {
						//player.highPunchB();
					} else {
						//player.lowPunchB();
					}
				}
		}
			
	}
	
	private function onGameKeyUp(e:KeyboardEvent):Void {
				
		switch(e.keyCode) {
			case KeyCodes.LEFT:
				leftKey = false;
				//player.xMove(0, 0, player.IDLE);
			case KeyCodes.UP:
				upKey = false;
			case KeyCodes.RIGHT:
				rightKey = false;
				//player.xMove(0, 0, player.IDLE);
			case KeyCodes.DOWN:
				downKey = false;
				//player.duck(false);
			case KeyCodes.X:
				xKey = false;
			case KeyCodes.Z:
				zKey = false;
		}
		
	}
	
	
	
}
