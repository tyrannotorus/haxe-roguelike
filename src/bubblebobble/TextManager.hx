package bubblebobble;

import com.tyrannotorus.utils.Colors;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import motion.Actuate;
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
	
	private static var textManager:TextManager;
	
	private var glyphRects:Array<Array<Rectangle>> = [];
	private var glyphBmds:Array<Array<BitmapData>> = [];
	private var textBitmapArray:Array<Bitmap>;
		
	public static function getInstance():TextManager {
		return (textManager != null) ? textManager : textManager = new TextManager();
	}
		
	public function new():Void {
		
		if (textManager != null) {
			trace("TextManager.new() is already instantiated.");
			return;
		}
		
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
	 * Determine the boundaries of proposed text block.
	 * @param {Array<String>} textArray
	 * @return {Rectangle}
	 */
	private function getTextRect(textData:TextData):Rectangle {
		
		var textArray:Array<String> = textData.text.split("\n");
		var textArrayLength:Int = textArray.length;
		
		var fontSet:Int = textData.fontSet;
		var matteMarginX:Int = textData.matteMarginX;
		var matteMarginY:Int = textData.matteMarginY;
		var maxWidth:Int = 2 * matteMarginX - 1;
		var maxHeight:Int = Std.int(2*matteMarginY + textArrayLength * textArrayLength*glyphBmds[fontSet][0].height - 1);
		
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
	 * @param {textData} textData
	 * @return {BitmapData}
	 */
	public function toBitmapData(textData:TextData):BitmapData {
		
		trace(textData.text);
		
		var textArray:Array<String> = textData.text.split("\n");
		
		trace(textArray.join(","));
		
		var textRect:Rectangle = getTextRect(textData);	
		
		trace(textRect);
		var bmd:BitmapData = new BitmapData(Std.int(textRect.width), Std.int(textRect.height), true, Colors.TRANSPARENT);
		var textArrayLength:Int = textArray.length;
		var idxGlyph:Int;
		var rect:Rectangle;
		var fontSet:Int = textData.fontSet;
		var matteMarginX:Int = textData.matteMarginX;
								
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
		
		bmd.threshold(bmd, bmd.rect, new Point(0,0), "==", Colors.BLACK, textData.primaryColor);		// Colour opaque text
		bmd.threshold(bmd, bmd.rect, new Point(0,0), "==", Colors.YELLOW, textData.secondaryColor);		// Colour opaque text
			
		// Render shadow text and lay opaque text on top.
		if (textData.shadowColor != Colors.TRANSPARENT) {
			
			var shadowOffsetX:Int = textData.shadowOffsetX;
			var shadowOffsetY:Int = textData.shadowOffsetY;
			var shadowPoint:Point = new Point();
			var textPoint:Point = new Point();
			
			if (shadowOffsetX < 0) {
				shadowPoint.x = 0;
				textPoint.x = -shadowOffsetX;
			} else {
				shadowPoint.x = shadowOffsetX;
				textPoint.x = 0;
			}
			
			if (shadowOffsetY < 0) {
				shadowPoint.y = 0;
				textPoint.y = -shadowOffsetY;
			} else {
				shadowPoint.y = shadowOffsetY;
				textPoint.y = 0;
			}
			
			var newWidth:Int = Std.int(bmd.width + Math.abs(shadowOffsetX));
			var newHeight:Int = Std.int(bmd.height + Math.abs(shadowOffsetY));
			var shadowBmd:BitmapData = new BitmapData(newWidth, newHeight, true, Colors.TRANSPARENT);
			shadowBmd.copyPixels(bmd, bmd.rect, shadowPoint, null, null, true);
			shadowBmd.threshold(shadowBmd, shadowBmd.rect, new Point(), "!=", Colors.TRANSPARENT, textData.shadowColor);
			shadowBmd.copyPixels(bmd, bmd.rect, textPoint, null, null, true);
			
			bmd.dispose();
			
			return scaleBMD(shadowBmd, textData.scale);
		}
		
		return scaleBMD(bmd, textData.scale);
		
	}
	
	/**
	 * Returns Bitmap block of text 
	 * @param	{textData} textData
	 * @param	{String} name
	 * @param	{Bool} visibilty
	 * @return	{Bitmap}
	 */
	public function toBitmap(textData:TextData, name:String = null, visibilty:Bool = true):Bitmap {
		
		var textBmd:BitmapData = toBitmapData(textData);
		var textBitmap:Bitmap = new Bitmap(textBmd);
		textBitmap.visible = visibilty;
		
		if (name != null) {
			textBitmap.name = name;
		}
				
		return textBitmap;
	}
	
	public function typeText(textData:TextData):Sprite {
		
		var textArray:Array<String> = textData.text.split("\n");
		var textRect:Rectangle = getTextRect(textData);
		var textBlock:Sprite = new Sprite();
		var textArrayLength:Int = textArray.length;
		var point:Point = new Point();
		var idxChar:Int;
		var primaryColor:Int = textData.primaryColor;
		var fontSet:Int = textData.fontSet;
		var matteMarginX:Int = textData.matteMarginX;
		
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
				glyph.bitmapData.threshold(glyph.bitmapData, rect, thresholdPoint, "==", Colors.BLACK, primaryColor);
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
		//if(idxGlyph < textBitmapArray.length){
		//	Actuate.tween(textBlock.getChildAt(idxGlyph), typingSpeed, {alpha:1} ).ease(Cubic.easeOut).onComplete(tweenText, [textBlock, (idxGlyph+1)]);
		//}
	}	
	
	/**
	 * Returns a scaled bitmapData according to scale parameter
	 * @param	{BitmapData} source
	 * @param	{Int} scale
	 * @return	{BitmapData}
	 */
	public function scaleBMD(source:BitmapData, scale:Int):BitmapData {
		
		if (scale == 1) {
			return source;
		}
		
		var matrix:Matrix = new Matrix();
		matrix.scale(scale, scale);
		var bmd:BitmapData = new BitmapData(Std.int(source.width * scale), Std.int(source.height * scale), true, Colors.TRANSPARENT);
		bmd.draw(source, matrix, null, null, null, false);
		source.dispose();
		
		return bmd;
	}
	
}
