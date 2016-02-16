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
import openfl.ui.Keyboard;

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
		
		var keyCode:Int = e.keyCode;
		
		
		
		
		switch(keyCode) {
			
			case KeyCodes.LEFT, KeyCodes.LEFT_NUMLOCK:
				keyCode = KeyCodes.LEFT;
			
			case KeyCodes.RIGHT, KeyCodes.RIGHT_NUMLOCK:
				keyCode = KeyCodes.RIGHT;
			
			case KeyCodes.UP, KeyCodes.UP_NUMLOCK:
				keyCode = KeyCodes.UP;
			
			case KeyCodes.DOWN, KeyCodes.DOWN_NUMLOCK:
				keyCode = KeyCodes.DOWN;
			
			case KeyCodes.NE, KeyCodes.NE_NUMLOCK:
				keyCode = KeyCodes.NE;
			
			case KeyCodes.NW, KeyCodes.NW_NUMLOCK:
				keyCode = KeyCodes.NW;
			
			case KeyCodes.SE, KeyCodes.SE_NUMLOCK:
				keyCode = KeyCodes.SE;
			
			case KeyCodes.SW, KeyCodes.SW_NUMLOCK:
				keyCode = KeyCodes.SW;
		}
		
		//map.moveCurrentTile(e.keyCode);
		if(player != null) {
			player.moveToTile(keyCode);
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
