package roguelike.editor;

import roguelike.editor.LevelEditor;
import roguelike.managers.TextManager;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import roguelike.TextData;

/**
 * Editor.as.
 * - The game editor.
 */
class Editor extends Sprite {
		
	private var levelEditor:LevelEditor;
			
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		
		var textManager:TextManager = TextManager.getInstance();
			
		// Create text
		var textData:TextData = new TextData( { text:"- Tiny Tactics Editor -" } );
		var titleText:Bitmap = textManager.toBitmap(textData);
		titleText.x = Std.int((Main.GAME_WIDTH - titleText.width) / 2);
		titleText.y = 1;
		addChild(titleText);
		
		textData = new TextData( { text:"- Menu -" } );
		var menuText:Bitmap = textManager.toBitmap(textData);
		menuText.y = 1;
		addChild(menuText);
		
		textData = new TextData( { text:"- Stage 1 -" } );
		var stageText:Bitmap = textManager.toBitmap(textData);
		stageText.x = Main.GAME_WIDTH - stageText.width;
		stageText.y = 1;
		addChild(stageText);
		
		// Create and add the level editor
		levelEditor = new LevelEditor();
		levelEditor.y = 8;
		addChild(levelEditor);
	}
	
}
