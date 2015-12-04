package com.tyrannotorus.bubblebobble.utils;

import openfl.display.DisplayObject;
import format.swf.Data.Sound;
import openfl.display.DisplayObject;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import motion.Actuate;

class ActorUtils {
	
	/**
	 * Parse an actor from an imported spritesheet.png and logic.txt.
	 * @param {BitmapData} actorSpritesheet
	 * @param {String} actorLogic
	 */
	public static function parseActorData(actorSpritesheet:BitmapData, actorLogic:String):Dynamic {
		
		var line:String;
		var logic:Array<String> = actorLogic.split("\r\n").map(removeComments).map(removeWhiteSpace).filter(removeNulls);
				
		var character:Dynamic = { };
		var stats:Dynamic = { };
		var actions:Dynamic = { };
		var combos:Dynamic = { };
						
		var tempString:String;
		var frameProperties:Array<String>;
		var frameProperty:Array<String>;
		var frameCoordinates:Dynamic = { };
		var actionType:String = "";
		
		for (i in 0...logic.length) {
			
			line = logic[i];
			
			// Parse the stat
			if(line.indexOf("stats.")==0) {
				tempString = line.substring(6, line.indexOf("="));
				Reflect.setField(stats, tempString, line.split("=")[1]);
				
			// Initilize parsing of frame data, followed by timing data
			} else if(line.indexOf("frames.")==0){
				actionType = line.substring(7, line.indexOf("("));
				parseFrame(line, actionType, actions, frameCoordinates);
											
			// Initilize parsing of combo data, followed by combo timing data
			} else if (line.indexOf("combos.")==0) {
				actionType = line.substring(7);
				Reflect.setField(combos, actionType, new Array<Int>());
			
			// Parse data for successive frames in this action
			} else if(Reflect.field(actions, actionType) != null) {
				parseFrameData(line, actionType, actions);
						
			} else if(Reflect.field(combos, actionType) != null) {
				var comboData:Array<String> = line.split(",");
				Reflect.field(combos, actionType).push(comboData);
			}
		}
		
		// Calculate width of animation cells by locating cyan divider. 
		var cellWidth:Int = actorSpritesheet.width;
		for (i in 0...cellWidth) {
			if (Std.int(actorSpritesheet.getPixel32(i, 0)) == Colors.CYAN) {
				cellWidth = i;
				break;
			}
		}
		
		// Calculate height of animation cells by locating cyan divider.
		var cellHeight:Int = actorSpritesheet.height;
		for (i in 0...cellHeight) {
			if (Std.int(actorSpritesheet.getPixel32(0, i)) == Colors.CYAN) {
				cellHeight = i;
				break;
			}
		}
		
		var rect:Rectangle = actorSpritesheet.rect;
		var zeroPoint:Point = new Point(0, 0);
		
		// Copy and Fill animation cells
		var fields:Array<Dynamic> = Reflect.fields(actions);
		for (key in Reflect.fields(actions)) {
			var actionData:Dynamic = Reflect.field(actions, key);
			var point:Point = Reflect.field(frameCoordinates, key);
			Reflect.setField(actionData, "bitmaps", new Array<BitmapData>());
			var len:Int = Reflect.field(actionData, "timing").length;
			for(i in 0...len) {
				var posX:Int = Std.int(point.x * cellWidth + point.x + i * (cellWidth + 1));
				var posY:Int = Std.int(point.y * cellHeight + point.y);
				var rect:Rectangle = new Rectangle(posX, posY, cellWidth, cellHeight);
				var cell:BitmapData = new BitmapData(cellWidth, cellHeight, true);
				cell.copyPixels(actorSpritesheet, rect, zeroPoint);
				cell.threshold(cell, cell.rect, zeroPoint, "==", Colors.MAGENTA);
				Reflect.field(actionData, "bitmaps")[i] = cell;
			}
		}
		
		actorSpritesheet.dispose();
		
		Reflect.setField(character, "stats", stats);
		Reflect.setField(character, "actions", actions);
		Reflect.setField(character, "combos", combos);
		
		return character;			
	}
	
	private static function parseFrame(line:String, actionType:String, actions:Dynamic, frameCoordinates:Dynamic):Void {
		
		// Parse frame coordinates
		var bracket:Int = line.indexOf("(");
		var comma:Int = line.indexOf(",");
		var posX:Int = Std.parseInt(line.substring(bracket + 1, comma));
		var posY:Int = Std.parseInt(line.substring(comma + 1, line.indexOf(")")));
		Reflect.setField(frameCoordinates, actionType, new Point(posX, posY));
				
		var actionData:Dynamic = { };
		Reflect.setField(actionData, "sfx", new Array<Sound>());
		Reflect.setField(actionData, "timing", new Array<Int>());
		Reflect.setField(actionData, "blockHigh", new Array<Int>());
		Reflect.setField(actionData, "blockLow", new Array<Int>());
		Reflect.setField(actionData, "dodge", new Array<Int>());
		Reflect.setField(actionData, "uppercut", new Array<Int>());
		Reflect.setField(actionData, "hit", new Array<Int>());
		Reflect.setField(actionData, "xshift", new Array<Int>());
		Reflect.setField(actionData, "yshift", new Array<Int>());
		Reflect.setField(actionData, "xshove", new Array<Int>());
		Reflect.setField(actionData, "yshove", new Array<Int>());
		Reflect.setField(actionData, "flip", new Array<Int>());
		
		Reflect.setField(actions, actionType, actionData);
	}
	
	private static function parseFrameData(line:String, actionType:String, actions:Dynamic):Void {
		var actionData:Dynamic = Reflect.field(actions, actionType); 			
		var frame:Int = Reflect.field(actionData, "timing").length;
								
		// Ensure all indices (except for sfx) are populated with at least int 0
		var fields:Array<String> = Reflect.fields(actionData);
		for (i in 0...fields.length) {
			if (fields[i] != "sfx") {
				Reflect.field(actionData, fields[i])[frame] = 0;
			}
		}
				
		Reflect.field(actionData, "sfx")[frame] = null;
		Reflect.field(actionData, "flip")[frame] = 1;
					
		var frameProperty:Array<String>;
		var frameProperties:Array<String> = line.split(",");
		for(i in 0...frameProperties.length){
			frameProperty = frameProperties[i].split(":");
					
			if (frameProperty[0] == "sfx") {
				//var sound:Sound = sound[ arr[1].slice(0, arr[1].indexOf(".")) ] as Sound;
				//var sound:String = 
				//Reflect.setField(actionData, "sfx". sound); 
					
			} else if(frameProperty[0] == "flip") {
				Reflect.field(actionData, "flip")[frame] = (frameProperty[1]=="0"?1:-1);
						
			} else {
				Reflect.field(actionData, frameProperty[0])[frame] = frameProperty[1];
			}
		}
	}
	
	private static function removeNulls(element:String):Bool {
    	return (element != "");
	}

	private static function removeComments(element:String):String {
    	return element.split(";")[0];
	}
		
	private static function removeWhiteSpace(element:String):String {
		var base:String = "0123456789abcdefghijklmnopqrstuvwxyz";
		var string:String;
		var array1:Array<String> = element.split("\t").join("").split(",");
		for (i in 0...array1.length) {
			var array2:Array<String> = array1[i].split("\"");
			string = "";
			for(j in 0...array2.length) {
				(j==1) ? string += array2[j] : string += array2[j].split(" ").join("");
			}
			array1[i] = string;
		}
		string = array1.join(",");
		return string;
    }
	
}