package com.roguelike.editor;

import com.tyrannotorus.utils.Colors;
import haxe.Json;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.Object;
import openfl.Vector;

/**
 * ActorData.hx.
 * - Data for Actor.hx.
 */
class ActorData {
	
	public var name:String;
	public var fileName:String;
	public var health:Int;
	public var animationTypes:Array<String>;
	public var frameBitmapDatas:Array<Array<BitmapData>>; 
	public var frameHitAreas:Array<Array<Sprite>>;
	public var frameTimings:Array<Array<Int>>; // Required in actor.zip
	public var hitFrames:Array<Array<Int>>; // Optional
	public var xShiftFrames:Array<Array<Int>>; // Optional
	public var yShiftFrames:Array<Array<Int>>; // Optional
	public var xShoveFrames:Array<Array<Int>>; // Optional
	public var yShoveFrames:Array<Array<Int>>; // Optional
	public var flipFrames:Array<Array<Int>>; // Optional

	/**
	 * Constructor.
	 * @param {String} jsonString
	 * @param {BitmapData} spriteSheetBmd
	 */
	public function new(jsonString:String, spriteSheetBmd:BitmapData):Void {
		deserialize(jsonString, spriteSheetBmd);
	}
	
	/**
	 * Deserializes json string into actorData.
	 * @param {String} jsonString
	 * @param {BitmapData} spriteSheetBmd
	 */
	private function deserialize(jsonString:String, spriteSheetBmd:BitmapData):Void {
		
		var jsonData:Object = Json.parse(jsonString);
		name = jsonData.name;
		fileName = jsonData.fileName;
		health = jsonData.health;
		
		animationTypes = new Array<String>();
		frameBitmapDatas = new Array<Array<BitmapData>>();
		frameTimings = new Array<Array<Int>>();
		frameHitAreas = new Array<Array<Sprite>>();
		hitFrames = new Array<Array<Int>>();
		xShiftFrames = new Array<Array<Int>>();
		yShiftFrames = new Array<Array<Int>>();
		xShoveFrames = new Array<Array<Int>>();
		yShoveFrames = new Array<Array<Int>>();
		flipFrames = new Array<Array<Int>>();		
		
		// Calculate width of animation cells by locating cyan divider. 
		var cellWidth:Int = spriteSheetBmd.width;
		for (i in 0...cellWidth) {
			if (Std.int(spriteSheetBmd.getPixel32(i, 0)) == Colors.CYAN) {
				cellWidth = i;
				break;
			}
		}
		
		// Calculate height of animation cells by locating cyan divider.
		var cellHeight:Int = spriteSheetBmd.height;
		for (i in 0...cellHeight) {
			if (Std.int(spriteSheetBmd.getPixel32(0, i)) == Colors.CYAN) {
				cellHeight = i;
				break;
			}
		}
		
		var animationData:Object = jsonData.animationData;
		var rect:Rectangle = spriteSheetBmd.rect;
		var zeroPoint:Point = new Point(0, 0);
		
		for (keyString in Reflect.fields(animationData)) {
			
			var animationData:Object = Reflect.field(animationData, keyString);// animationData[keyString];// Json.parse(animationDataString);
			var point:Point = new Point(animationData.position.x, animationData.position.y);
			var timingArray:Array<Int> = cast animationData.frameTiming;
			var bmdArray:Array<BitmapData> = new Array<BitmapData>();
			var hitAreaArray:Array<Sprite> = new Array<Sprite>();
			
			// An array filled with zeros to fill optionally included array data in the actor.zip.
			var zeroArray:Array<Int> = new Array<Int>();
			var flipArray:Array<Int> = new Array<Int>();
			
			for(idxFrame in 0...timingArray.length) {
				
				// Create the original bitmapData for the cell frame.
				var posX:Int = Std.int(point.x * cellWidth + point.x + idxFrame * (cellWidth + 1));
				var posY:Int = Std.int(point.y * cellHeight + point.y);
				var frameVector:Vector<UInt> = spriteSheetBmd.getVector(new Rectangle(posX, posY, cellWidth, cellHeight));
				var frameSprite:Sprite = new Sprite();
				var idxPixel:Int = 0;
				
				frameSprite.graphics.beginFill(Colors.BLACK, 1);
				for(yPosition in 0...cellHeight) {
					for (xPosition in 0...cellWidth) {
						
						var pixel:Int = frameVector[idxPixel];
						
						if (pixel == Colors.MAGENTA) {
							pixel = Colors.TRANSPARENT;
						} else if (pixel == Colors.BLUE) {
							pixel = Colors.ACTOR_SHADOW;
						}
						
						if (pixel != Colors.TRANSPARENT) {
							frameSprite.graphics.drawRect(xPosition, yPosition, 1, 1);
						}
						
						frameVector[idxPixel++] = pixel;
					}
				}
				frameSprite.graphics.endFill();
				
				var frameBmd:BitmapData = new BitmapData(cellWidth, cellHeight, true, Colors.TRANSPARENT);
				frameBmd.setVector(frameBmd.rect, frameVector);
				
				bmdArray.push(frameBmd);
				hitAreaArray.push(frameSprite);
				zeroArray.push(0);
				flipArray.push(1);
			}
			
			var hitFrameArray:Array<Int> = (animationData.hitFrames != null) ? cast animationData.hitFrames : zeroArray;
			var xShiftArray:Array<Int> = (animationData.xShift != null) ? cast animationData.xShift : zeroArray;
			var yShiftArray:Array<Int> = (animationData.yShift != null) ? cast animationData.yShift : zeroArray;
			var xShoveArray:Array<Int> = (animationData.xShove != null) ? cast animationData.xShove : zeroArray;
			var yShoveArray:Array<Int> = (animationData.yShove != null) ? cast animationData.yShove : zeroArray;
			var flipArray:Array<Int> = (animationData.flipFrames != null) ? cast animationData.flipFrames : flipArray;
			
			// The "IDLE" animation should always be at index 0.
			keyString = keyString.toUpperCase();
			if(keyString == "IDLE") {
				animationTypes.unshift(keyString);
				frameTimings.unshift(timingArray);
				frameBitmapDatas.unshift(bmdArray);
				frameHitAreas.unshift(hitAreaArray);
				hitFrames.unshift(hitFrameArray);
				xShiftFrames.unshift(xShiftArray);
				yShiftFrames.unshift(yShiftArray);
				xShoveFrames.unshift(xShoveArray);
				yShoveFrames.unshift(yShoveArray);
				flipFrames.unshift(flipArray);
			
			// All the other animations can be in any order.
			} else {
				animationTypes.push(keyString);
				frameTimings.push(timingArray);
				frameBitmapDatas.push(bmdArray);
				frameHitAreas.push(hitAreaArray);
				hitFrames.push(hitFrameArray);
				xShiftFrames.push(xShiftArray);
				yShiftFrames.push(yShiftArray);
				xShoveFrames.push(xShoveArray);
				yShoveFrames.push(yShoveArray);
				flipFrames.push(flipArray);
			}
		}
		
	}
}
