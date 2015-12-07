package bubblebobble.editor;

import bubblebobble.editor.LevelEditor;
import openfl.display.Bitmap;
import openfl.display.Sprite;

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
			
		// Create text
		var textData:TextData = new TextData( { text:"- Bubble Bobble Editor -" } );
		var titleText:Bitmap = TextManager.getInstance().toBitmap(textData);
		titleText.x = Std.int((Main.GAME_WIDTH - titleText.width) / 2);
		titleText.y = 1;
		addChild(titleText);
		
		textData = new TextData( { text:"- Menu -" } );
		var menuText:Bitmap = TextManager.getInstance().toBitmap(textData);
		menuText.y = 1;
		addChild(menuText);
		
		textData = new TextData( { text:"- Stage 1 -" } );
		var stageText:Bitmap = TextManager.getInstance().toBitmap(textData);
		stageText.x = Main.GAME_WIDTH - stageText.width;
		stageText.y = 1;
		addChild(stageText);
		
		// Create and add the level editor
		levelEditor = new LevelEditor();
		levelEditor.y = 8;
		addChild(levelEditor);
	}
	
}
