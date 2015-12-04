package com.tyrannotorus.bubblebobble;

import com.tyrannotorus.bubblebobble.utils.Utils;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class Ring extends Sprite {

	private var RING_COLOR:Int = 0xFF0070EC;
	private var CROWD_COLOR:Int = 0xFFFC7460;
	private var WALL_COLOR:Int = 0xFFFCE4A0;
	private var ringBitmap:Bitmap;
	
	public function new() {
		super();
		ringBitmap = new Bitmap();
		ringBitmap.smoothing = true;
		addChild(ringBitmap);
	}
	
	/**
	 * Loads the boxing ring and recolors it according to data in the character's stats
	 * @param {Dynamic} characterData
	 */
	public function loadRing(characterData:Dynamic) {
		
		ringBitmap.bitmapData = Assets.getBitmapData("img/ring.png");
		var rect:Rectangle = ringBitmap.bitmapData.rect;
		var point:Point = new Point(0, 0);
		var hexColor:String = "";
		
		var ringData:Dynamic = Reflect.field(characterData, "stats");
		
		var ringColor:Int = RING_COLOR;
		hexColor = Reflect.field(ringData, "RINGCOLOR");
		if (hexColor != null) {
			ringColor = Colors.hexToInt(hexColor, true);
		}
		
		var crowdColor:Int = CROWD_COLOR;
		hexColor = Reflect.field(ringData, "CROWDCOLOR");
		if (hexColor != null) {
			crowdColor = Colors.hexToInt(hexColor, true);
		}
		
		var wallColor:Int = WALL_COLOR;
		hexColor = Reflect.field(ringData, "2WALLCOLOR");
		if (hexColor != null) {
			wallColor = Colors.hexToInt(hexColor, true);
		}
		
		ringBitmap.bitmapData.threshold(ringBitmap.bitmapData, rect, point, "==", Colors.YELLOW, ringColor);
		ringBitmap.bitmapData.threshold(ringBitmap.bitmapData, rect, point, "==", Colors.CYAN, crowdColor);
		ringBitmap.bitmapData.threshold(ringBitmap.bitmapData, rect, point, "==", Colors.GREEN, wallColor);
	}
}
