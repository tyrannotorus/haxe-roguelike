package com.roguelike.editor;

import com.roguelike.dialogs.ButtonSprite;
import com.roguelike.managers.TextManager;
import com.roguelike.TextData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * ActorsDialog.hx.
 * - Popup containing actors.
 */
class MenuBar extends Sprite {
	
	private var menuItems:Array<ButtonSprite>;
	private var menuEvents:Array<String>;
	private var stickySelections:Bool;
	private var selectedButton:ButtonSprite;
	private var textData:TextData;
	private var upColor:UInt;
	private var overColor:UInt;
	private var downColor:UInt;
	private var paddingWidth:UInt;
	private var xPosition:Int = 0;
		
	/**
	 * Constructor.
	 * @param {TextData} textData
	 */
	public function new(textData:TextData, stickySelections:Bool = true) {
		
		super();
		
		this.textData = textData;
		this.stickySelections = stickySelections;
		this.menuItems = new Array<ButtonSprite>();
		this.menuEvents = new Array<String>();
		this.paddingWidth = Math.floor(TextManager.getInstance().toBitmap(new TextData( { text:"   " } )).width);
		this.upColor = textData.upColor;
		this.overColor = textData.overColor;
		this.downColor = textData.downColor;
		this.mouseEnabled = false;
		this.cacheAsBitmap = true;
		
		this.addEventListener(MouseEvent.CLICK, onMenuClick);
		this.addEventListener(MouseEvent.MOUSE_DOWN, onStopPropagation);
		this.addEventListener(MouseEvent.MOUSE_UP, onStopPropagation);
	}
	
	/**
	 * Stop the mouse propagation
	 * @param {MouseEvent} e
	 */
	private function onStopPropagation(e:MouseEvent):Void {
		e.stopImmediatePropagation();
		e.stopPropagation();
	}
	
	/**
	 * A Menu element was clicked. Switch to the new menu.
	 * @param {MouseEvent.CLICK} e
	 */
	private function onMenuClick(e:MouseEvent):Void {
		
		var menuIndex:Int = menuItems.indexOf(e.target);
		if (menuIndex == -1) {
			return;
		}
		
		e.stopImmediatePropagation();
		e.stopPropagation();
		
		// Select the menu item.
		if(stickySelections) {
			selectMenuItem(e.target);
		}
		
		// Dispatch the menu click.
		var editorEvent:EditorEvent = new EditorEvent(EditorEvent.DISPATCH, menuEvents[menuIndex]);
		EditorDispatcher.getInstance().dispatchEvent(editorEvent);
	}
		
	/**
	 * Add an item to the menu.
	 * @param {TextData} menuText
	 * @param {String} editorEvent
	 * @param {Bool} autoSelect
	 */
	public function addItem(menuText:String, editorEvent:String, autoSelect:Bool = false):Void {
		
		textData.text = menuText;
		textData.overColor = overColor;
		textData.upColor = upColor;
		textData.downColor = downColor;
				
		var buttonSprite:ButtonSprite = new ButtonSprite(textData);
		buttonSprite.x = xPosition;
		addChild(buttonSprite);
		
		menuItems.push(buttonSprite);
		menuEvents.push(editorEvent);
		xPosition += Math.floor(buttonSprite.width + paddingWidth);
		
		if (autoSelect) {
			selectMenuItem(buttonSprite);
		}
	}
	
	/**
	 * Select this button in the menu.
	 * @param {Dynamic} buttonSprite
	 */
	public function selectMenuItem(buttonSprite:Dynamic):Void {
		
		var buttonIndex:Int = menuItems.indexOf(buttonSprite);
		
		if (buttonIndex != -1) {
			
			if (selectedButton != null) {
				selectedButton.select(false);
			}
			
			selectedButton = menuItems[buttonIndex];
			selectedButton.select(true);
		}
	}
	
	

}