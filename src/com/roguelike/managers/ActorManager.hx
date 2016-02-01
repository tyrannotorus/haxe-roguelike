package com.roguelike.managers;

import com.roguelike.Actor;
import com.tyrannotorus.assetloader.AssetEvent;
import com.tyrannotorus.assetloader.AssetLoader;
import com.tyrannotorus.utils.ActorUtils;
import com.tyrannotorus.utils.Utils;
import haxe.ds.ObjectMap;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import com.roguelike.editor.Tile;

class ActorManager extends EventDispatcher {
	
	private static var actorManager:ActorManager;
	
	private var actorCache:ObjectMap<String,Actor>;
	private var actorsArray:Array<Actor>;
		
	/**
	 * Returns the instance of the tileManager.
	 * @return {TileManager}
	 */
	 public static function getInstance():ActorManager {
		return (actorManager != null) ? actorManager : actorManager = new ActorManager();
	}
	
	/**
	 * Constructor.
	 */
	public function new():Void {
		
		if (actorManager != null) {
			trace("ActorManager.new() is already instantiated.");
			return;
		}
		
		super();
	}
		
	/**
	 * Returns whether the tileManager has loaded tiles yet.
	 * @return {Bool}
	 */
	 public function isReady():Bool {
		return (actorCache != null);
	}
	
	/**
	 * Shortcut for loading tiles
	 */
	public function init():Void {
		var assetLoader:AssetLoader = new AssetLoader();
		assetLoader.addEventListener(AssetEvent.LOAD_COMPLETE, onActorsLoaded);
		assetLoader.loadAsset("actors/actors.zip");
	}
	
	/**
	 * Tileset has loaded.
	 * @param {AssetEvent.LOAD_COMPLETE} e
	 */
	private function onActorsLoaded(e:AssetEvent):Void {
		
		var assetLoader:AssetLoader = cast(e.target, AssetLoader);
		assetLoader.removeEventListener(AssetEvent.LOAD_COMPLETE, onActorsLoaded);
		
		if (e.assetData == null) {
			trace("ActorsManager.onActorsLoaded() Failure.");
			return;
		}
		
		actorCache = new ObjectMap<String,Actor>();
		actorsArray = new Array<Actor>();
		
		// Load the fields.
		var fieldsArray:Array<String> = Reflect.fields(e.assetData);
		fieldsArray.sort(Utils.sortAlphabetically);
		
		for (idxField in 0...fieldsArray.length) {
			
			var fieldString:String = fieldsArray[idxField];
			var fieldArray:Array<String> = fieldString.split(".");
			var fileType:String = fieldArray.pop().toLowerCase();
			var fileName:String = fieldArray.join(".");
						
			if (fileType == AssetLoader.TXT) {
				
				var spriteSheet:Bitmap = Reflect.field(e.assetData, fileName + ".png");
				var spriteLogic:String = Reflect.field(e.assetData, fieldString);
				trace("parsing " + fileName);
				var actorData:Dynamic = ActorUtils.parseActorData(spriteSheet.bitmapData, spriteLogic);
				var actor:Actor = new Actor(actorData);
				actor.buttonMode = true;
				actorsArray.push(actor);
				//actorsContainer.addItem(actor);
			}
		}
		
		// People out there may be waiting. Let them know we're complete.
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	/**
	 * Returns an Actor from the actorCache by its actorName.
	 * @param {String} actorName
	 * @return {Tile}
	 */
	public function getActor(actorName:String):Actor {
		var actor:Actor = actorCache.get(actorName);
		return (actor != null) ? actor.clone() : null;
	}
	
	/**
	 * Returns an array of all the actors.
	 * @return {Array<Actor>}
	 */
	public function getAllActors():Array<Actor> {
		return actorsArray.copy();
	}
	
}
