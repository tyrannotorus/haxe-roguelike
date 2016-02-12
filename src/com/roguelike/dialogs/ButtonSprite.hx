package com.roguelike.dialogs;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import com.roguelike.Matte;
import com.roguelike.MatteData;
import com.roguelike.TextData;
import com.roguelike.managers.TextManager;
import openfl.events.MouseEvent;

/**
 * ButtonSprite.hx.
 * - A Bitmap button.
 */
class ButtonSprite extends Sprite {

	private var upBitmap:Bitmap;
	private var overBitmap:Bitmap;
	private var downBitmap:Bitmap;
	
	/**
	 * Constructor.
	 */
	public function new(textData:TextData) {
		
		super();
		
		mouseChildren = false;
		buttonMode = true;
		
		var textManager:TextManager = TextManager.getInstance();
		
		upBitmap = textManager.toBitmap(textData);
		addChild(upBitmap);
		
		textData.upColor = textData.overColor;
		overBitmap = textManager.toBitmap(textData);
		overBitmap.alpha = 0;
		addChild(overBitmap);
		
		textData.upColor = textData.downColor;
		downBitmap = textManager.toBitmap(textData);
		downBitmap.alpha = 0;
		downBitmap.y = 1;
		addChild(downBitmap);
		
		addListeners();
	}
	
	/**
	 * Add listeners to the button.
	 */
	private function addListeners():Void {
		this.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver, false, 0, true);
		this.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut, false, 0, true);
		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		this.addEventListener(MouseEvent.MOUSE_UP, onMouseRollOver, false, 0, true);
	}
	
	/**
	 * Remove listeners to the button.
	 */
	private function removeListeners():Void {
		this.removeEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
		this.removeEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
		this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		this.removeEventListener(MouseEvent.MOUSE_UP, onMouseRollOver);
	}
	
	/**
	 * Select or deselect the button.
	 * @param {Bool} value
	 */
	public function select(value:Bool):Void {
		
		// Select the button.
		if (value) {
			onMouseRollOver();
			removeListeners();
		
		// Deselect the button.	
		} else {
			onMouseRollOut();
			addListeners();
		}
	}
	
	/**
	 * Roll over
	 * @param {MouseEvent.ROLL_OVER} e
	 */
	private function onMouseRollOver(e:MouseEvent = null):Void {
		upBitmap.alpha = 0;
		overBitmap.alpha = 1;
		downBitmap.alpha = 0;
	}
	
	/**
	 * Roll over
	 * @param {MouseEvent.ROLL_OUT} e
	 */
	private function onMouseRollOut(e:MouseEvent = null):Void {
		upBitmap.alpha = 1;
		overBitmap.alpha = 0;
		downBitmap.alpha = 0;
	}
	
	/**
	 * Roll over
	 * @param {MouseEvent.MOUSE_DOWN} e
	 */
	private function onMouseDown(e:MouseEvent = null):Void {
		upBitmap.alpha = 0;
		overBitmap.alpha = 0;
		downBitmap.alpha = 1;
	}
	
	
}