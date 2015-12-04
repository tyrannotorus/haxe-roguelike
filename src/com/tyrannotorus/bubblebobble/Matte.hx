package com.tyrannotorus.bubblebobble;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import motion.Actuate;

class Matte
{
	
	//TEXT BLOCK OBJECT WITH SHADOW AND MATTING -----------------------------------------------------------------------------------
	public static function toBitmap(parameters:Dynamic = null):Bitmap
	{
		
		if (parameters == null)
		{
			parameters = { };
		}
		
		for (p in Reflect.fields(Menu.template))
		{
			if (!Reflect.hasField(parameters, p))
			{
				Reflect.setField(parameters, p, Reflect.field(Menu.template, p));
			}
		}
				
		var w:Int = Std.int(parameters.width);
		var h:Int = Std.int(parameters.height);
		var frameColor:UInt = parameters.frameColor;
		var matteColor:UInt = parameters.matteColor;
       	var matteBmd:BitmapData = new BitmapData(parameters.width, parameters.height, true, 0x00000000);
		
		// Outer frame
		matteBmd.fillRect(new Rectangle(0, 4, w, h-8), frameColor);
		matteBmd.fillRect(new Rectangle(4, 0, w-8, h), frameColor);
		matteBmd.fillRect(new Rectangle(1, 2, w-2, h-4), frameColor);
		matteBmd.fillRect(new Rectangle(2, 1, w-4, h-2), frameColor);
			
		// Inner matte
		matteBmd.fillRect(new Rectangle(1, 4, w-2, h-8), matteColor);
		matteBmd.fillRect(new Rectangle(2, 2, w-4, h-4), matteColor);
		matteBmd.fillRect(new Rectangle(4, 1, w-8, h-2), matteColor);
		
		return new Bitmap(matteBmd);
	}
			/*
			if ($modifier.hasOwnProperty("height")) {
				object.height = $modifier.height;
			} else {
				object.height = object.yoffset * 2;
				n = sprite.numChildren;
				while(n--) object.height += sprite.getChildAt(n).height;
			}
			
			
			// ALIGN ENTRIES VERTICALLY
			var start_y:Int = !object.yalign ? int((object.height - sprite.height)*0.5) : object.yalign == -1 ? object.yoffset : object.height - sprite.height;
			for (i = 0; i < $elements.length; i++)
			{
				sprite.getChildAt(i).y = start_y;
				start_y += sprite.getChildAt(i).height;
			}
			
			// ALIGN ENTRIES HORIZONTALLY
			var n:int = $elements.length;
			if (object.xalign == -1) while (n--) sprite.getChildAt(n).x = object.xoffset;
			else if (object.xalign == 0) while (n--) sprite.getChildAt(n).x = int((object.width - sprite.getChildAt(n).width)*0.5);
			else if (object.xalign == 1) while (n--) sprite.getChildAt(n).x = object.width - sprite.getChildAt(n).width - object.xoffset;
					
			// ADD MATTING
			sprite.addChildAt(getMatte(object.width, object.height, hextoUint(object.mattealpha, object.mattecolor), hextoUint(object.framealpha, object.framecolor)), 0);
						
			//POSITION BLOCK VERTICALLY
			if (object.y == -1) sprite.y = object.ymargin;
			else if (object.y == 0) sprite.y = int((template.stageheight - object.height) * 0.5);
			else if (object.y == 1) sprite.y = template.stageheight - object.height - object.ymargin;
			else sprite.y = object.y;
			
			//POSITION BLOCK HORIZONTALLY
			if (object.x == -1) sprite.x = object.xmargin;
			else if (object.x == 0) sprite.x = int((template.stagewidth - object.width) * 0.5);
			else if (object.x == 1) sprite.x = template.stagewidth - object.width - object.xmargin;
			else sprite.x = object.x;
					
			return sprite;
		}
		
		*/
		
		
		
			
		
	
		
		
		/* ADD SHADOW AND HIGHLIGHTING TO BMD --------------------------------------------------------------------------------------------
		public function addShadow($bmd:BitmapData, $fcolor:uint, $hcolor:uint, $scolor:uint, $salpha:Number):Sprite
		{
			var sprite:Sprite = new Sprite();
			
			// ADD SHADOW
			var sBMD:BitmapData = $bmd.clone();
			sBMD.threshold(sBMD, new Rectangle(0, 0, sBMD.width, sBMD.height), new Point(0,0), "==", 0xFF000000, $scolor);
			sprite.addChild(new Bitmap(sBMD));
			sprite.getChildAt(0).y = 1;
			sprite.getChildAt(0).alpha = $salpha;
			
			// ADD HIGHLIGHT
			var hBMD:BitmapData = $bmd.clone();
			hBMD.threshold(hBMD, new Rectangle(0, 0, hBMD.width, hBMD.height), new Point(0,0), "==", 0xFF000000, $hcolor);
			sprite.addChild(new Bitmap(hBMD));
			sprite.getChildAt(1).alpha = 0;
			
			// ADD REGULAR TEXT (IN MIDDLE)
			$bmd.threshold($bmd, new Rectangle(0, 0, $bmd.width, $bmd.height), new Point(0,0), "==", 0xFF000000, $fcolor);
			sprite.addChildAt(new Bitmap($bmd), 1);
								
			return sprite;
		}
			
			
		// CREATE MENU BACKING ---------------------------------------------------------------------------------------------------------
		public static function getMatte($w:int, $h:int, $mattecolor:uint, $framecolor:uint) : Bitmap
		{
			var bmd:BitmapData = new BitmapData($w, $h, true, 0);
			bmd.fillRect(new Rectangle(1, 0, $w-2, $h), $framecolor);
			bmd.fillRect(new Rectangle(0, 1, $w, $h-2), $framecolor);
			bmd.fillRect(new Rectangle(1, 1, $w-2, $h-2), $mattecolor);
			return new Bitmap(bmd);
		}
		
		/* FIND MAXIMUM WIDTH OUT OF ALL ENTRIES (OBJECT OR SPRITE) --------------------------------------------------------------------
		private function maxWidth($sprite:Sprite):int
		{
			var w:int = 0, n:int = $sprite.numChildren;
			while(n--)
				if ($sprite.getChildAt(i).width > w)
				w = $sprite.getChildAt(i).width;
			}
			return w;
		}
				
		// FIND MAXIMUM HEIGHT OUT OF ALL ENTRIES (OBJECT OR SPRITE) -------------------------------------------------------------------
		private function maxHeight($block:Dynamic):void
		{
			var h:int = 0;
			var n:int = $block.entries.length;
			while (n--)
			{
				if ($block.entries[n].hasOwnProperty("sprite"))
				h += $block.entries[n].sprite.height;
			}
			
			$block.height = h + ($block.yoffset * 2) - 1;
		}
		
		
		
				
				
			
	private static function hextoUint(A:Float, C:String):UInt
	{
		return uint("0x" + Math.round(A*255).toString(16).toUpperCase() + (C.indexOf("0x") == 0 ? C.slice(4) : $c));
	}		
	
	*/
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	public static function toBMD(Sourcebmd:BitmapData, Direction:Int, Color1:UInt, Color2:UInt):BitmapData
	{
		var pt1:Point = new Point();
		var pt2:Point = new Point();
		if (Direction == -1) pt1.x = Globals.halfblock;
		else if (Direction == 1) pt2.x = Globals.halfblock;
		var bmd:BitmapData = scaleBMD(Sourcebmd, Globals.block);
		var newbmd:BitmapData = new BitmapData(Std.int(bmd.width + Globals.halfblock), Std.int(bmd.height), true, 0x00FFFFFF);
		bmd.threshold(bmd, bmd.rect, new Point(0,0), "==", 0xFF000000, Color1);
		newbmd.copyPixels(bmd, bmd.rect, pt1, null, null, true);
		bmd.threshold(bmd, bmd.rect, new Point(0,0), "==", Color1, Color2);
		newbmd.copyPixels(bmd, bmd.rect, pt2, null, null, true);
		return newbmd;
	}
	
	public static function scaleBMD(Sourcebmd:BitmapData, Ratio:Int):BitmapData
	{
		var matrix:Matrix = new Matrix();
		matrix.scale(Ratio, Ratio);
		var bmd:BitmapData = new BitmapData(Sourcebmd.width * Ratio, Sourcebmd.height * Ratio, true, 0x000000);
		bmd.draw(Sourcebmd, matrix, null, null, null, false);
		return bmd;
	}
	*/
	
	
	
	
}
