package bubblebobble;

import com.tyrannotorus.utils.Constants;
import com.tyrannotorus.utils.Utils;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.Lib;
import flash.events.Event;
import flash.events.MouseEvent;

import motion.Actuate;
import motion.easing.Bounce;
import motion.easing.Cubic;

class Menu extends Sprite {
	
	private var container:Dynamic = { };
	private var entries:Dynamic = { };
	private var uniqueId:Int = 0;
	
	public static var template:Dynamic = {
		fontColor1:0xFFFFFF00,
		fontColor2:0xFFFFFF00,
		highcolor1:0xFFFFFFFF,
		highcolor2:0xFFFFFFFF,
		disabledcolor:0xFF999999,
		shadowcolor:0xBB000000,
		shadowx:0,
		shadowy: -1,
		tweenIn:Constants.SLIDE_RIGHT,
		tweenOut:Constants.SLIDE_LEFT,
		scale:1,
		fontSet:0,
		linebreak:0,
		frameColor:0xFFFFFF00,
		matteColor:0xCC000000,
		matteMarginX:6,
		matteMarginY:6,
		matteAlignX:Constants.CENTER,
		matteAlignY:Constants.CENTER,
		stageMarginX:0,
		stageMarginY:0,
		stageAlignX:Constants.CENTER,
		stageAlignY:Constants.CENTER,
		name:"",
		link:"",
		matte:{ },
	}
					
	public function new():Void {
		super();
	}
	
	public function set(parameters:Dynamic):Void {
		
		/* find target menu, if it doesn't exist, create it */
		var menuName:String = Reflect.field(parameters, 'menu');
		var menuData:Dynamic = Reflect.field(container, menuName);
		var menu:Sprite = menuData.content;
		
		for (p in Reflect.fields(parameters))
		{
			Reflect.setField(menuData, p, Reflect.field(parameters, p));
		}
		
		var tweenIn:Int = Utils.getField(parameters, 'tweenIn', Constants.NONE);
		menuData.tweenIn = tweenIn;
		
		var tweenOut:Int = Utils.getField(parameters, 'tweenOut', -tweenIn);
		menuData.tweenOut = tweenOut;
		
		var xalign:Int = Utils.getField(parameters, 'x', template.stageAlignX);
		switch( xalign )
		{
			case Constants.CENTER:
				menu.x = Utils.centerX(menu);
			case Constants.LEFT:
				menu.x = template.panelMarginX + template.stageMarginX;
			case Constants.RIGHT:
				menu.x = Constants.fullWidth - menu.width - template.panelMarginX - template.stageMarginX;
		}
		
		var yalign:Int = Utils.getField(parameters, 'y', template.stageAlignY);
		switch( yalign )
		{
			case Constants.CENTER:
				menu.y = Utils.centerY(menu);
			case Constants.TOP:
				menu.y = template.panelMarginY + template.stageMarginY;
			case Constants.BOTTOM:
				menu.y = Constants.fullHeight - menu.height - template.panelMarginY - template.stageMarginY;
		}
		
		menuData.x = menu.x;
		menuData.y = menu.y;
		menuData.name = menuName;
		
		if (Reflect.hasField(parameters, "matte"))
		{
			menuData.content.addChildAt(Matte.toBitmap( parameters.matte ), 0);
		}
		
	}
	
	
	public function add(menuEntry:Dynamic):Void
	{
		/* find target menu, if it doesn't exist, create it */
		var menuName:String = Reflect.field(menuEntry, 'menu');
		var menu:Dynamic = Utils.getField(container, menuName, { name:menuName, content:new Sprite() } );
		menu.content.name = menuName;
		
		/* Create initial entry data */
		var entry:Dynamic = Reflect.hasField(menuEntry, 'href') ? {href:menuEntry.href, index:menu.content.numChildren } : { };
		entry.content = new Sprite();
		entry.content.x = Utils.getField(menuEntry, 'x', 0);
		entry.content.y = Utils.getField(menuEntry, 'y', menu.content.numChildren ? menu.content.getChildAt(menu.content.numChildren - 1).y + menu.content.getChildAt(menu.content.numChildren - 1).height : 0);
		entry.content.name = ++uniqueId;
		entry.content.addChild(TextManager.getInstance().toBitmap(menuEntry, "regular"));
		
		if (Reflect.hasField(entry, 'href'))
		{
			menuEntry.fontColor1 = Utils.getField(menuEntry, 'highcolor1', template.highcolor1);
			menuEntry.fontColor2 = Utils.getField(menuEntry, 'highcolor2', template.highcolor2);
			entry.content.addChild(TextManager.getInstance().toBitmap(menuEntry, "highlight", false));
		}
		
		if (!menu.content.hasEventListener(MouseEvent.MOUSE_DOWN))
		{
			menu.content.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown); 
		}
		
		if (!menu.content.hasEventListener(MouseEvent.MOUSE_UP))
		{
			menu.content.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		if (!menu.content.hasEventListener(MouseEvent.CLICK))
		{
			menu.content.addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		menu.content.addChild(entry.content);
		
		/* update main dynamic container with updated/new menu */
		Reflect.setField(entries, Std.string(uniqueId), entry);
		Reflect.setField(container, menuName, menu);
	}
	
	
	private function onMouseDown(e:MouseEvent):Void
	{
		var sprite:Sprite = e.target;
		if(sprite.numChildren != 1){
			sprite.getChildAt(0).visible = false;
			sprite.getChildAt(1).visible = true;
		}
	}
	
	private function onMouseUp(e:MouseEvent):Void
	{
		var sprite:Sprite = e.target;
		if(sprite.numChildren != 1){
			sprite.getChildAt(0).visible = true;
			sprite.getChildAt(1).visible = false;
		}
	}
	
	private function onMouseClick(e:MouseEvent):Void
	{
		var menuEntry:Dynamic = Reflect.field(entries, e.target.name);
		if (Reflect.hasField(menuEntry, "href")) {
			execute(menuEntry.href);
		}
	}
	
	public function execute(href:Dynamic)
	{
		var action:String;
		var link:String;
		var links:Array<String> = [];
				
		if (Std.is(href, String)) {
			links.push(href);
		} else if (Std.is(href, Array)) {
			links = href.concat();
		}
				
		while (links.length != 0)
		{
			link = links.shift();
			var split:Array<String> = link.split("_");
			action = split[0];
			link = split[1];
			
			switch(action)
			{
				case "open":
					open(link);
				case "close":
					if (link == Std.string(Constants.ALL)) for (menu in Reflect.fields(container)) {
						trace("closing " +menu);
						close(menu);
					} else {
						close(link);
					}
				//case "history_back": close("history"); open("main");	
				//case "exit": close(menuName);
			}
		}
	}
	
	public function close(menuName:String, tweenSpeed:Float = 0.5):Void
	{
		if (!hasMenu(menuName))
		{
			return;
		}
				
		var menuData:Dynamic = Reflect.field(container, menuName);
		var menu:Sprite = menuData.content;
		var tweenParameters:Dynamic<Int> = { };
		var hasTweenOut:Bool = Reflect.hasField(menuData, "tweenOut");
		
		// If menu does not exist on stage, return
		if (!this.contains(menu)) {
			return;
		}
				
		if (hasTweenOut)
		{
			var tweenOut:Int = Reflect.field(menuData, "tweenOut");
			switch(tweenOut)
			{
				case Constants.SLIDE_LEFT:
				tweenParameters.x = -Std.int(menu.width);
				case Constants.SLIDE_RIGHT:
				tweenParameters.x = Constants.fullWidth;
				case Constants.SLIDE_UP:
				tweenParameters.y = -Std.int(menu.height);
				case Constants.SLIDE_DOWN:
				tweenParameters.y = Constants.fullHeight;
			}
			Actuate.tween(menu, tweenSpeed, tweenParameters ).ease(Cubic.easeOut).onComplete(this.removeChild, [menu]);
		
		} else {
			this.removeChild(menu);
		}
	}
	
	private function hasMenu(menuName:String):Bool
	{
		return Reflect.hasField(container, menuName);
	}
	
	public function open(menuName:String, tweenSpeed:Float = 0.5):Void
	{
		if (!hasMenu(menuName))
		{
			trace(menuName + " does not exist");
			return;
		}
		
		var menuData:Dynamic = Reflect.field(container, menuName);
		var menu:Sprite = menuData.content;
		//menu.x = menuData.x;
		//menu.y = menuData.y;
		var tweenParameters:Dynamic<Int> = { };
		var hasTweenIn:Bool = Reflect.hasField(menuData, "tweenIn");
		
		if (hasTweenIn)
		{
			var tweenIn:Int = Reflect.field(menuData, "tweenIn");
			switch(tweenIn)
			{
				case Constants.SLIDE_LEFT:
				tweenParameters.x = Std.int(menuData.x);
				menu.x = Constants.fullWidth;
				case Constants.SLIDE_RIGHT:
				tweenParameters.x = Std.int(menuData.x);
				menu.x = Std.int( -menu.width);
				case Constants.SLIDE_UP:
				tweenParameters.y = Std.int(menuData.y);
				menu.y = Constants.fullHeight;
				case Constants.SLIDE_DOWN:
				tweenParameters.y = Std.int(menuData.y);
				menu.y = Std.int(-menu.height);	
			}
			Actuate.tween(menu, tweenSpeed, tweenParameters).ease(Cubic.easeOut);
		}
				
		this.addChild(menu);
	}
	
	
	
	
	
}
