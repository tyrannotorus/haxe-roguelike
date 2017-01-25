package com.roguelike;

import com.roguelike.editor.Editor;
import com.roguelike.editor.Map;
import com.roguelike.editor.MapData;
import com.roguelike.editor.Tile;
import com.roguelike.managers.ActorManager;
import com.roguelike.managers.MapManager;
import com.roguelike.managers.TextManager;
import com.roguelike.managers.TileManager;
import com.tyrannotorus.utils.KeyCodes;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import openfl.ui.Mouse;
import openfl.utils.Object;

/**
 * Game.as.
 * - The main game stage.
 */
class Game extends Sprite {
	
	public static var game:Game;
	
	public var textManager:TextManager;
	public var mapManager:MapManager;
	public var tileManager:TileManager;
	public var actorManager:ActorManager;
	
	public var player:Actor;
	public var map:Map;
	public var keysDown:Array<Bool> = [];
	private var editor:Editor;
	
	// Music and sfx.
	private var music:Sound;
	private var musicChannel:SoundChannel;
	private var musicTransform:SoundTransform;
	
	/**
	 * Return static instance of Game.
	 * @return {Game}
	 */
	public static function getInstance():Game {
		return (game != null) ? game : game = new Game();
	}	
	
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		
		// Initialize the text manager (bitmap fonts).
		textManager = TextManager.getInstance();
		textManager.init();
		
		// Initialize the map manager (generates maps).
		mapManager = MapManager.getInstance();
		mapManager.addEventListener(Event.COMPLETE, init);
		mapManager.init();
		
		// Initialize the tile manager (manages individual tiles for maps).
		tileManager = TileManager.getInstance();
		tileManager.addEventListener(Event.COMPLETE, init);
		tileManager.init();
		
		// Initialize the game's actors.
		actorManager = ActorManager.getInstance();
		actorManager.addEventListener(Event.COMPLETE, init);
		actorManager.init();
	}
	
	/**
	 * Attempt to initialize the game (after assets are loaded).
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
		
		mapManager.removeEventListener(Event.COMPLETE, init);
		tileManager.removeEventListener(Event.COMPLETE, init);
		actorManager.removeEventListener(Event.COMPLETE, init);
		
		// Create the map and add it to the map editor.
		var mapData:MapData = mapManager.getMapData("hellmouth.txt");
		map = new Map(mapData);
		
		editor = new Editor(map);
		addChild(editor);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
		
		//musicTransform = new SoundTransform(0.1);
		//music = Assets.getSound("audio/title_music.mp3", true);
		//musicChannel = music.play();
		//musicChannel.soundTransform = musicTransform;
	}
		
	/**
	 * User has pressed a key.
	 * @param {KeyboardEvent.KEY_DOWN} e
	 */
	private function onKeyDown(e:KeyboardEvent):Void {
		
		if (keysDown[e.keyCode]) {
			return;
		}

		var keyDown:Int = e.keyCode;
		keysDown[keyDown] = true;
		
		switch(keyDown) {
			
			case KeyCodes.ESC:
				
				if (editor.parent == this) {
					editor.hide();
				} else {
					editor.show();
				}				
			
			case KeyCodes.LEFT, KeyCodes.LEFT_NUMLOCK:
				keyDown = KeyCodes.LEFT;
			
			case KeyCodes.RIGHT, KeyCodes.RIGHT_NUMLOCK:
				keyDown = KeyCodes.RIGHT;
			
			case KeyCodes.UP, KeyCodes.UP_NUMLOCK:
				keyDown = KeyCodes.UP;
			
			case KeyCodes.DOWN, KeyCodes.DOWN_NUMLOCK:
				keyDown = KeyCodes.DOWN;
			
			case KeyCodes.NE, KeyCodes.NE_NUMLOCK:
				keyDown = KeyCodes.NE;
			
			case KeyCodes.NW, KeyCodes.NW_NUMLOCK:
				keyDown = KeyCodes.NW;
			
			case KeyCodes.SE, KeyCodes.SE_NUMLOCK:
				keyDown = KeyCodes.SE;
			
			case KeyCodes.SW, KeyCodes.SW_NUMLOCK:
				keyDown = KeyCodes.SW;
				
		}
		
		if(player != null) {
			var actorTile:Tile = player.moveToTile(keyDown);
			if (actorTile != null) {
				map.alignCameraToTile(actorTile, keyDown);
			}
		
		} else {
			map.moveToTile(keyDown);
		}
	}
	
	/**
	 * User has released a key.
	 * @param {KeyboardEvent.KEY_UP} e
	 */
	private function onKeyUp(e:KeyboardEvent):Void {
		keysDown[e.keyCode] = false;
	}
	
}
