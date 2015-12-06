package bubblebobble;

import bubblebobble.dialogs.TilesDialog;
import bubblebobble.editor.Editor;
import com.tyrannotorus.utils.KeyCodes;
import openfl.Assets;
import openfl.display.Bitmap;
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
		
	private var screen:Sprite;
	private var player:Actor;
	private var opponent:Actor;
	private var healthBars:HealthBars;
	private var menu:Menu;
	private var tilesDialog:TilesDialog;
	
	// Keyboard Controls
	private var zKey:Bool = false;
	private var xKey:Bool = false;
	private var cKey:Bool = false;
	private var upKey:Bool = false;
	private var downKey:Bool = false;
	private var leftKey:Bool = false;
	private var rightKey:Bool = false;
		
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
		
		// Create text
		var textData:TextData = new TextData( { text:"- Bubble Bobble Forever -" } );
		var titleText:Bitmap = TextManager.getInstance().toBitmap(textData);
		titleText.x = Std.int((Main.GAME_WIDTH - titleText.width) / 2);
		titleText.y = 1;
		addChild(titleText);
		
		textData = new TextData( { text:"- Menu -" } );
		var menuText:Bitmap = TextManager.getInstance().toBitmap(textData);
		//menuText.x = Main.GAME_WIDTH - menuText.width) / 2);
		menuText.y = 1;
		addChild(menuText);
		
		var editor:Editor = new Editor();
		editor.y = 8;
		addChild(editor);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onGameKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onGameKeyUp);
		
		//var testText:Dynamic = { };
		//testText.text = "Mike Tysons\nPunch\nout!!";
		//testText.fontColor1 = Colors.WHITE;
		//testText.fontSet = 4;
		//addChild(textManager.typeText(testText));
		
		
				
		musicTransform = new SoundTransform(0.1);
		music = Assets.getSound("audio/title_music.mp3", true);
		musicChannel = music.play();
		musicChannel.soundTransform = musicTransform;
	}
	

	
	private function onGameKeyDown(e:KeyboardEvent):Void {
		
		switch(e.keyCode) {
			
			// Left key
			case KeyCodes.LEFT:
				//if (leftKey == false) {
					leftKey = true;
					player.xMove(-1, -1, player.WALK);
				//}
			
			// Up key
			case KeyCodes.UP:
				if (upKey == false) {
					upKey = true;
				}
			
			// Right Key	
			case KeyCodes.RIGHT:
				//if (rightKey == false) {
					rightKey = true;
					player.xMove(1, 1, player.WALK);
				//}
			
			// Down Key
			case KeyCodes.DOWN:
				if (downKey == false) {
					downKey = true;
					//player.duck(true);
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
				player.xMove(0, 0, player.IDLE);
			case KeyCodes.UP:
				upKey = false;
			case KeyCodes.RIGHT:
				rightKey = false;
				player.xMove(0, 0, player.IDLE);
			case KeyCodes.DOWN:
				downKey = false;
				player.duck(false);
			case KeyCodes.X:
				xKey = false;
			case KeyCodes.Z:
				zKey = false;
		}
		
	}
	
	
	
}
