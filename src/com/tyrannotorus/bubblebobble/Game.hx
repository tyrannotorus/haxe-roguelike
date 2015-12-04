package com.tyrannotorus.bubblebobble;

import com.tyrannotorus.bubblebobble.utils.Utils;
import com.tyrannotorus.bubblebobble.utils.ActorUtils;
import com.tyrannotorus.assetloader.AssetEvent;
import com.tyrannotorus.assetloader.AssetLoader;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

class Game extends Sprite {
		
	private var screen:Sprite;
	private var ring:Ring;
	private var player:Actor;
	private var opponent:Actor;
	private var healthBars:HealthBars;
	private var menu:Menu;
	
	// Keyboard Controls
	private var zKey:Bool = false;
	private var xKey:Bool = false;
	private var cKey:Bool = false;
	private var upKey:Bool = false;
	private var downKey:Bool = false;
	private var leftKey:Bool = false;
	private var rightKey:Bool = false;
		
	// Fonts and text typing
	public var textManager:TextManager;
		
	// Music and sfx
	private var music:Sound;
	private var musicChannel:SoundChannel;
	private var musicTransform:SoundTransform;
	
	public function new() {
		
		super();
		
		screen = new Sprite();
		
		// Add Mike Tyson Welcome Screen
		var intro:Bitmap = new Bitmap();
		intro.bitmapData = Assets.getBitmapData("img/intro.png");
		screen.addChild(intro);
		addChild(screen);
		
		ring = new Ring();
		addChild(ring);
		
		// Create Little Mac
		var macSpritesheet:BitmapData = Assets.getBitmapData("actors/mac_spritesheet.png");
		var macLogic:String = Assets.getText("actors/mac_logic.txt");
		var macData:Dynamic = ActorUtils.parseActorData(macSpritesheet, macLogic);
		player = new Actor(macData);
		
		healthBars = new HealthBars();
		textManager = new TextManager();
		menu = new Menu(this);
		addChild(menu);
		
		var testText:Dynamic = { };
		testText.text = "Mike Tysons\nPunch\nout!!";
		testText.fontColor1 = Colors.WHITE;
		testText.fontSet = 4;
		addChild(textManager.typeText(testText));
		
		var assetLoader:AssetLoader = new AssetLoader();
		assetLoader.addEventListener(AssetEvent.LOAD_COMPLETE, parseExternalAsset);
		assetLoader.loadAsset("http://sites.google.com/site/tyrannotorus/01-glassjoe.zip");
				
		musicTransform = new SoundTransform(0.1);
		music = Assets.getSound("audio/title_music.mp3", true);
		musicChannel = music.play();
		musicChannel.soundTransform = musicTransform;
	}
	
	/**
	 * External Asset has been loaded and extracted from the zip. Parse it.
	 * @param {AssetEvent.LOAD_COMPLETE}	e
	 */
	private function parseExternalAsset(e:AssetEvent):Void {
		trace("parseExternalAsset");
		var assetLoader:AssetLoader = cast(e.target, AssetLoader);
		assetLoader.removeEventListener(AssetEvent.LOAD_COMPLETE, parseExternalAsset);
		
		if (e.assetData == null) {
			return;
		}
		
		var spritesheet:Bitmap = e.getData("spritesheet.png");
		var logic:String = e.getData("logic.txt");
		var characterData:Dynamic = ActorUtils.parseActorData(spritesheet.bitmapData, logic);
		opponent = new Actor(characterData);
		Utils.position(opponent, Constants.CENTER, 73);
		addChild(opponent);
		
		ring.loadRing(characterData);
				
		Utils.position(player, 96, 132);
		addChild(player);
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onGameKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onGameKeyUp);
	}
	
	private function onEnterFrame(e:Event):Void {
		player.animate();
		opponent.animate();
	}
	
	private function onGameKeyDown(e:KeyboardEvent):Void {
		
		switch(e.keyCode) {
			
			// Left key
			case 37:
				if (leftKey == false) {
					leftKey = true;
					player.dodgeLeft();
				}
			
			// Up key
			case 38:
				if (upKey == false) {
					upKey = true;
				}
			
			// Right Key	
			case 39:
				if (rightKey == false) {
					rightKey = true;
					player.dodgeRight();
				}
			
			// Down Key
			case 40:
				if (downKey == false) {
					downKey = true;
					player.duck(true);
				}
			
			// X Key
			case 88:
				if (xKey == false && zKey == false) {
					xKey = true;
					if (upKey == true) {
						player.highPunchA();
					} else {
						player.lowPunchA();
					}
				}
			
			// Z Key
			case 90:
				if (zKey == false && xKey == false) {
					zKey = true;
					if (upKey == true) {
						player.highPunchB();
					} else {
						player.lowPunchB();
					}
				}
		}
			
	}
	
	private function onGameKeyUp(e:KeyboardEvent):Void {
				
		switch(e.keyCode) {
			case 37:
				leftKey = false;
			case 38:
				upKey = false;
			case 39:
				rightKey = false;
			case 40:
				downKey = false;
				player.duck(false);
			case 88:
				xKey = false;
			case 90:
				zKey = false;
		}
		
	}
	
	
	
}
