package com.roguelike.editor;

import com.roguelike.dialogs.DialogData;
import com.roguelike.dialogs.GenericDialog;
import com.roguelike.editor.MapEditor;
import com.roguelike.Game;
import com.roguelike.managers.MapManager;
import com.roguelike.managers.TextManager;
import com.roguelike.TextData;
import com.tyrannotorus.utils.Colors;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * Editor.as.
 * - The game editor.
 */
class Editor extends Sprite {
	
	public var map:Map;
	public var mapEditor:MapEditor;
	
	/**
	 * Constructor.
	 * @param {Map} map
	 */
	public function new(map:Map) {
		
		super();
		
		var textManager:TextManager = TextManager.getInstance();
		
		// Create the standard textData to be used for the menu bar.
		var menuData:TextData = new TextData();
		menuData.upColor = Colors.WHITE;
		menuData.overColor = Colors.SCHOOL_BUS_YELLOW;
		menuData.downColor = Colors.SCHOOL_BUS_YELLOW;
		menuData.shadowColor = Colors.BLACK;
			
		// Create the map and add it to the map editor.
		this.map = map;
		mapEditor = new MapEditor(this.map);
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
				
			case EditorEvent.CLOSED:
				
				var game:Game = Game.getInstance();
				game.removeChild(this);
				game.addChildAt(map, 0);
				
				if (map.allActors[0] != null) {
					game.player = map.allActors[0];
					//map.setCurrentTile(game.player.currentTile);
					map.setFocusToTile(game.player.currentTile, 1);
				}
				
				game.stage.focus = stage;
					
			case EditorEvent.HELP:
				trace("EditorEvent.HELP");
			
		}
	}
	
	/**
	 * Hide the editor.
	 */
	public function show():Void {
		var game:Game = Game.getInstance();
		game.addChildAt(this, 0);
		mapEditor.show();
	}
	
	/**
	 * Hide the editor.
	 */
	public function hide():Void {
		mapEditor.hide();
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
