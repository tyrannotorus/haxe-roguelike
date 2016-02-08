package com.roguelike.editor;

import com.roguelike.dialogs.DialogData;
import com.roguelike.dialogs.GenericDialog;
import com.roguelike.editor.MapEditor;
import com.roguelike.managers.TextManager;
import com.roguelike.TextData;
import com.tyrannotorus.utils.Colors;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;

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
		
		// Listen for dispatches from the editorDispatcher.
		var editorDispatcher:EditorDispatcher = EditorDispatcher.getInstance();
		editorDispatcher.addEventListener(Event.CHANGE, onEditorDispatch);
	}
	
	/**
	 * Listen to EditorDispatcher events, mostly dispatching menu events.
	 * @param {EditorEvent} e
	 */
	private function onEditorDispatch(e:EditorEvent):Void {
		
		var editorEvent:String = e.data;
		
		switch(editorEvent) {
			
			case EditorEvent.FILE:
				var dialogData:DialogData = new DialogData();
				dialogData.headerHeight = 0;
				dialogData.width = 100;
				dialogData.height = 100;
				dialogData.headerText = "File";
				dialogData.matteColor = Colors.setAlpha(Colors.BLACK, 0.7);
				dialogData.borderColor = Colors.TRANSPARENT;
				dialogData.shadowColor = Colors.TRANSPARENT;
				dialogData.dialogPositionY = 0.4;
				var genericDialog:GenericDialog = new GenericDialog(dialogData);
				addChild(genericDialog);
			
			case EditorEvent.HELP:
				trace("EditorEvent.HELP");
			
		}
	}
	
	/**
	 * Clean up the mess.
	 */
	public function cleanUp():Void {
		
		mapEditor.parent.removeChild(mapEditor);
		mapEditor.cleanUp();
		mapEditor = null;
		
		var editorDispatcher:EditorDispatcher = EditorDispatcher.getInstance();
		editorDispatcher.removeEventListener(Event.CHANGE, onEditorDispatch);
	}
	
}
