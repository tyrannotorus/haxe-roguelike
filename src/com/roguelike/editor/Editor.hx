package com.roguelike.editor;

import com.roguelike.editor.MapData;
import com.roguelike.editor.MapEditor;
import com.roguelike.managers.TextManager;
import com.roguelike.TextData;
import openfl.display.Bitmap;
import openfl.display.Sprite;

/**
 * Editor.as.
 * - The game editor.
 */
class Editor extends Sprite {
		
	private var mapEditor:MapEditor;
			
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
		mapEditor = new MapEditor();
		mapEditor.y = 8;
		addChild(mapEditor);
	}
	
}
