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
	
	
}
