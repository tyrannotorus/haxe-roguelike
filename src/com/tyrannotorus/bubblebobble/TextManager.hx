package com.tyrannotorus.bubblebobble;

import com.tyrannotorus.bubblebobble.utils.Colors;
import com.tyrannotorus.bubblebobble.utils.Utils;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.Lib;

import motion.Actuate;
import motion.easing.Bounce;
import motion.easing.Cubic;

@:bitmap("assets/fonts/bmd_font_custom7x7.png")
class FontLarge extends BitmapData { }

@:bitmap("assets/fonts/bmd_font_custom5x5.png")
class FontSmall extends BitmapData { }

@:bitmap("assets/fonts/bmd_font_ironsword.png")
class FontIronsword extends BitmapData { }

@:bitmap("assets/fonts/bmd_font_sopwith.png")
class FontSopwith extends BitmapData { }

@:bitmap("assets/fonts/bmd_font_punchout.png")
class FontPunchOut extends BitmapData { }

class TextManager {
	
	public static inline var LARGE:Int = 0;
	public static inline var SMALL:Int = 1;
	public static inline var IRONSWORD:Int = 2;
	public static inline var SOPWITH:Int = 3;
	public static inline var PUNCHOUT:Int = 4;
	public static inline var ALPHABET:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopkrstuvwxyz0123456789?!.<>|()@:- ";
	
	private var glyphRects:Array<Array<Rectangle>> = [];
	private var glyphBmds:Array<Array<BitmapData>> = [];
	private var textArray:Array<String>;
	private var textBitmapArray:Array<Bitmap>;
	private var fontSet:Int;
	private var fontColor1:Int;
	private var fontColor2:Int;
	private var shadowcolor:Int;
	private var shadowx:Int;
	private var shadowy:Int;
	private var scale:Int;
	private var matteMarginX:Int;
	private var matteMarginY:Int;
	private var typingSpeed:Float;
		
	public function new():Void {
		constructFont(LARGE, new FontLarge(0, 0));
		constructFont(SMALL, new FontSmall(0, 0));
		constructFont(IRONSWORD, new FontIronsword(0, 0));
		constructFont(SOPWITH, new FontSopwith(0, 0));
		constructFont(PUNCHOUT, new FontPunchOut(0, 0));
	}
	
	/**
	 * Parse Font Bitmaps
	 * @param	fontSet
	 * @param	fontBmd
	 */
	private function constructFont(fontSet:Int, fontBmd:BitmapData):Void {
		var point:Point = new Point(0, 0);
		var position_x:Int = 0;
		var fontHeight:Int = fontBmd.height;
		fontBmd.threshold(fontBmd, fontBmd.rect, point, "==", Colors.MAGENTA);
		glyphBmds[fontSet] = [];
		glyphRects[fontSet] = [];
								
		// Copy every glyph in the font string to bitmapDatas
		for (idxGlyph in 0...ALPHABET.length) {
			for (fontWidth in 0...fontBmd.width) {
				if (fontBmd.getPixel((position_x + fontWidth), 0) == 16777215) {	
					var rect:Rectangle = new Rectangle(position_x, 0, fontWidth, fontHeight);
					var bmd:BitmapData = new BitmapData(fontWidth, fontHeight, true, 0);
					bmd.copyPixels(fontBmd, rect, point);
					glyphBmds[fontSet][idxGlyph] = bmd;
					glyphRects[fontSet][idxGlyph] = bmd.rect;
					position_x += (fontWidth + 1); // account for white divider
					break;
				}
			}
		}
	}

	/**
	 * Parses the text parameters and saves the variables locally
	 * @param {Dynamic} parameters
	 */
	private function parseParameters(parameters:Dynamic = null):Void {
		parameters = parameters ? parameters : { };
		textArray = Utils.getField(parameters, "text", " ").split("\n");
		fontSet = Utils.getField(parameters, "fontSet", Menu.template.fontSet);
		fontColor1 = Utils.getField(parameters, "fontColor1", Menu.template.fontColor1);
		fontColor2 = Utils.getField(parameters, "fontColor2", Menu.template.fontColor2);
		shadowcolor = Utils.getField(parameters, "shadowcolor", Menu.template.shadowcolor);
		shadowx = Utils.getField(parameters, "shadowx", Menu.template.shadowx);
		shadowy = Utils.getField(parameters, "shadowy", Menu.template.shadowy);
		scale = Utils.getField(parameters, "scale", Menu.template.scale);
		matteMarginX = Utils.getField(parameters, "matteMarginX", Menu.template.matteMarginX);
		matteMarginY = Utils.getField(parameters, "matteMarginY", Menu.template.matteMarginY);
		typingSpeed = Utils.getField(parameters, "typingSpeed", 0.2);
		parameters = null;
	}
	
	/**
	 * Gets the boundaries of the text block
	 * @return {Rectangle}
	 */
	private function getTextRect():Rectangle {
		var textArrayLength:Int = textArray.length;
		var maxWidth:Int = 2 * matteMarginX - 1;
		var maxHeight:Int = Std.int(2*matteMarginY + textArrayLength * textArray.length*glyphBmds[fontSet][0].height - 1);
		for (row in 0...textArrayLength) {
			if (textArray[row] == "") textArray[row] = " ";
			var tempMaxWidth:Float = 2 * matteMarginX - 1;
			var subTextArrayLength:Int = textArray[row].length;
			for (i in 0...subTextArrayLength) tempMaxWidth += glyphRects[fontSet][ALPHABET.indexOf(textArray[row].charAt(i))].width;
			if (tempMaxWidth > maxWidth) maxWidth = Std.int(tempMaxWidth);
		}
		return new Rectangle(0, 0, maxWidth, maxHeight);
	}
	
	/**
	 * Convert string to bitmapdata
	 * @param {Dynamic} parameters
	 * @return {BitmapData}
	 */
	public function toBitmapData(parameters:Dynamic = null):BitmapData {
		
		parseParameters(parameters);
		var textRect:Rectangle = getTextRect();				
		var bmd:BitmapData = new BitmapData(Std.int(textRect.width), Std.int(textRect.height), true, Colors.TRANSPARENT);
		var textArrayLength:Int = textArray.length;
		var idxGlyph:Int;
		var rect:Rectangle;
								
		// Write full lines of Text to empty bitmapdata
		var point:Point = new Point();
		for (i in 0...textArrayLength) {
			var subTextArrayLength:Int = textArray[i].length;
			point.x = matteMarginX;
			point.y = Std.int(i * glyphBmds[fontSet][0].height);
			for (j in 0...subTextArrayLength) {
				idxGlyph = ALPHABET.indexOf(textArray[i].charAt(j));
				rect = glyphRects[fontSet][idxGlyph];
				bmd.copyPixels(glyphBmds[fontSet][idxGlyph], rect, point);
				point.x += rect.width;
			}
		}
			
		/* Render shadow text and lay opaque text on top */
		textRect.width += (shadowx < 0 ? -shadowx : shadowx);
		var finalBmd:BitmapData = new BitmapData(Std.int(textRect.width), Std.int(textRect.height+(shadowy<0?-shadowy:shadowy)), true, 0x00000000);
		finalBmd.copyPixels(bmd, bmd.rect, new Point(shadowx < 0 ? 0 : shadowx, shadowy < 0 ? 0 : shadowy));
		finalBmd.threshold(bmd, bmd.rect, new Point(0,0), "==", Colors.BLACK, shadowcolor);	// Convert opaque text to shadow
		finalBmd.threshold(bmd, bmd.rect, new Point(0,0), "==", Colors.YELLOW, shadowcolor);	// Convert opaque text to shadow
		
		bmd.threshold(bmd, bmd.rect, new Point(0,0), "==", Colors.BLACK, fontColor1);		// Colour opaque text
		bmd.threshold(bmd, bmd.rect, new Point(0,0), "==", Colors.YELLOW, fontColor2);		// Colour opaque text
		finalBmd.copyPixels(bmd, bmd.rect, new Point(Std.int(shadowx < 0? -shadowx:0),Std.int(shadowy < 0? -shadowy:0)), null, null, true);
		bmd.dispose();
		
		return (scale == 1 ? finalBmd : scaleBMD(finalBmd, scale));
	}
	
	/**
	 * Returns Bitmap block of text 
	 * @param	{Dynamic} parameters
	 * @param	{String} name
	 * @param	{Bool} visibilty
	 * @return	{Bitmap}
	 */
	public function toBitmap(parameters:Dynamic = null, name:String = null, visibilty:Bool = true):Bitmap {
		var bitmap:Bitmap = new Bitmap(toBitmapData(parameters));
		if(name!=null) bitmap.name = name;
		bitmap.visible = visibilty;		
		return bitmap;
	}
	
	public function typeText(parameters:Dynamic = null):Sprite {
		
		parseParameters(parameters);
		var textRect:Rectangle = getTextRect();
		var textBlock:Sprite = new Sprite();
		var textArrayLength:Int = textArray.length;
		var point:Point = new Point();
		var idxChar:Int;
		
		textBitmapArray = [];
		
		// Write full lines of Text to empty bitmapdata
		var positionPoint:Point = new Point();
		var thresholdPoint:Point = new Point();
		var rect:Rectangle;
		for (row in 0...textArrayLength) {
			var subTextArrayLength:Int = textArray[row].length;
			positionPoint.x = matteMarginX;
			positionPoint.y = Std.int(row * glyphRects[fontSet][0].height);
			
			for (i in 0...subTextArrayLength) {
				idxChar = ALPHABET.indexOf(textArray[row].charAt(i));
				if(idxChar == -1) {
					continue;
				}
				var glyph:Bitmap = new Bitmap(glyphBmds[fontSet][idxChar]);
				rect = glyph.bitmapData.rect;
				glyph.bitmapData.threshold(glyph.bitmapData, rect, thresholdPoint, "==", Colors.BLACK, fontColor1);
				glyph.x = positionPoint.x;
				glyph.y = positionPoint.y;
				glyph.alpha = 0;
				textBitmapArray.push(glyph);
				textBlock.addChild(glyph);
				positionPoint.x += glyph.width;
			}
		}
		tweenText(textBlock, 0);
		return textBlock;		
	}
	
	private function tweenText(textBlock:Sprite, idxGlyph:Int):Void {
		if(idxGlyph < textBitmapArray.length){
			Actuate.tween(textBlock.getChildAt(idxGlyph), typingSpeed, {alpha:1} ).ease(Cubic.easeOut).onComplete(tweenText, [textBlock, (idxGlyph+1)]);
		}
	}	
	
	/**
	 * Returns a scaled bitmapData according to scale parameter
	 * @param	{BitmapData} source
	 * @param	{Int} scale
	 * @return	{BitmapData}
	 */
	public function scaleBMD(source:BitmapData, scale:Int):BitmapData {
		var matrix:Matrix = new Matrix();
		matrix.scale(scale, scale);
		var bmd:BitmapData = new BitmapData(Std.int(source.width * scale), Std.int(source.height * scale), true, 0x000000);
		bmd.draw(source, matrix, null, null, null, false);
		source.dispose();
		return bmd;
	}
	
}
