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
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

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
	private var editor:Editor;
		
	// Music and sfx
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
		
		textManager = TextManager.getInstance();
		mapManager = MapManager.getInstance();
		mapManager.addEventListener(Event.COMPLETE, init);
		tileManager = TileManager.getInstance();
		tileManager.addEventListener(Event.COMPLETE, init);
		actorManager = ActorManager.getInstance();
		actorManager.addEventListener(Event.COMPLETE, init);
		
		textManager.init();
		mapManager.init();
		tileManager.init();
		actorManager.init();
	}
	
	/**
	 * Attempt to initialize the game (after assets are loaded)
	 * @param {Event.COMPLETE} e
	 */
	private function init(e:Event = null):Void {
		
		if (!mapManager.isReady()) {
			return;
		} else if (!tileManager.isReady()) {
			return;
		} else if (!actorManager.isReady()) {
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
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onGameKeyDown);
			
		
		//musicTransform = new SoundTransform(0.1);
		//music = Assets.getSound("audio/title_music.mp3", true);
		//musicChannel = music.play();
		//musicChannel.soundTransform = musicTransform;
	}
		
	private function onGameKeyDown(e:KeyboardEvent):Void {
		
		var keyCode:Int = e.keyCode;
			
		switch(keyCode) {
			
			case KeyCodes.ESC:
				
				if (editor.parent == this) {
					trace("editor.hide();");
					editor.hide();
				} else {
					trace("editor.show();");
					editor.show();
				}				
			
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
			var actorTile:Tile = player.moveToTile(keyCode);
			if (actorTile != null) {
				map.alignViewRect(actorTile, keyCode);
			}
		}
			
	}
	
	
}
