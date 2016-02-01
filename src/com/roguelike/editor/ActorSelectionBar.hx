package com.roguelike.editor;

import com.roguelike.Actor;
import com.roguelike.dialogs.ItemContainer;
import com.roguelike.managers.ActorManager;
import com.roguelike.managers.TextManager;
import com.tyrannotorus.utils.Colors;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Rectangle;

/**
 * ActorsDialog.hx.
 * - Popup containing actors.
 */
class ActorSelectionBar extends Sprite {
	
	private static inline var WIDTH:Int = Main.GAME_WIDTH - 20;
	private static inline var HEIGHT:Int = 22;
	private static inline var XMARGIN:Int = 3;

	private var actorsContainer:ItemContainer;
	private var actorsArray:Array<Actor>;
	
	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		
		var rect:Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
		
		// Create the header and header backing matte.
		var matteData:MatteData = new MatteData();
		matteData.width = Math.floor(rect.width);
		matteData.height = Math.floor(rect.height);
		matteData.topRadius = 0;
		matteData.bottomRadius = 0;
		matteData.borderColor = Colors.TRANSPARENT;
		matteData.matteColor = Colors.BLACK;
		var matteSprite:Sprite = Matte.toSprite(matteData);
		matteSprite.alpha = 0.7;
		addChild(matteSprite);
					
		actorsContainer = new ItemContainer(rect);
		addChild(actorsContainer);
		
		var actorManager:ActorManager = ActorManager.getInstance();
		if (!actorManager.isReady()) {
			actorManager.addEventListener(Event.COMPLETE, onActorsLoaded);
		} else {
			onActorsLoaded();
		}
		
		// Create title text.
		var titleData:TextData = new TextData( { text:"Characters", shadowColor:Colors.BLACK } );
		var titleBitmap:Bitmap = TextManager.getInstance().toBitmap(titleData);
		titleBitmap.x = 4;
		titleBitmap.y = -1;
		
		var titleSprite:Sprite = new Sprite();
		titleSprite.addChild(titleBitmap);
		titleSprite.mouseEnabled = false;
		titleSprite.mouseChildren = false;
		titleSprite.cacheAsBitmap = true;
		addChild(titleSprite);
		
		var xData:TextData = new TextData( { text:"x", shadowColor:Colors.BLACK } );
		var xBitmap:Bitmap = TextManager.getInstance().toBitmap(xData);
		var xSprite:Sprite = new Sprite();
		xSprite.addChild(xBitmap);
		xSprite.x = WIDTH - 4 - xBitmap.width;
		xSprite.y = -1;
		xSprite.mouseChildren = false;
		xSprite.buttonMode = true;
		addChild(xSprite);
		
		this.cacheAsBitmap = true;
	}
	
	/**
	 * All Actors have loaded. Load them into the container for display.
	 * @param {Event.COMPLETE} e
	 */
	private function onActorsLoaded(e:Event = null):Void {
		actorsArray = ActorManager.getInstance().getAllActors();
		for (idxActor in 0...actorsArray.length) {
			actorsContainer.addItem(actorsArray[idxActor]);
		}
	}
	
	/**
	 * Animate the actors on the level.
	 */	
	private function onEnterFrame(e:Event):Void {
		for (idxActor in 0...actorsArray.length) {
			actorsArray[idxActor].animate();
		}
	}
		
	public function getActor(possibleActor:Dynamic):Actor {
		
		if(Std.is(possibleActor, Actor)){
			
			var actor:Actor = cast(possibleActor, Actor);
			var selectedActor:Actor = actor.clone();
			selectedActor.buttonMode = true;
			actorsArray.push(selectedActor);
			
			return selectedActor;
		}
		
		return null;
	}
	
	public function removeActor(actor:Actor):Void {
		var actorIndex:Int = actorsArray.indexOf(actor);
		if (actorIndex != -1) {
			actorsArray.splice(actorIndex, 1);
		}
	}

}