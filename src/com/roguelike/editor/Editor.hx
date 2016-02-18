package com.roguelike.editor;

import com.roguelike.dialogs.DialogData;
import com.roguelike.dialogs.GenericDialog;
import com.roguelike.editor.MapEditor;
import com.roguelike.managers.MapManager;
import com.roguelike.managers.TextManager;
import com.roguelike.TextData;
import com.tyrannotorus.utils.Colors;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Rectangle;

/**
 * Editor.as.
 * - The game editor.
 */
class Editor extends Sprite {
	
	private var map:Map;
	private var mapEditor:MapEditor;
			
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		
		var textManager:TextManager = TextManager.getInstance();
		
		// Create the standard textData to be used for the menu bar.
		var menuData:TextData = new TextData();
		menuData.upColor = Colors.WHITE;
		menuData.overColor = Colors.SCHOOL_BUS_YELLOW;
		menuData.downColor = Colors.SCHOOL_BUS_YELLOW;
		menuData.shadowColor = Colors.BLACK;
			
		// Create the map and add it to the map editor.
		var mapData:MapData = MapManager.getInstance().getMapData("hellmouth.txt");
		map = new Map(mapData);
		mapEditor = new MapEditor(map);
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
		trace("onEditorDispatch() " + editorEvent);
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
