package com.roguelike.dialogs;

import com.roguelike.Actor;
import com.roguelike.dialogs.DraggableDialog;
import com.roguelike.managers.ActorManager;
import com.tyrannotorus.utils.Colors;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
 * TilesDialog.hx.
 * - A draggable dialog with for use within the level editor.
 * - Loads a selection of tiles.
 */
class ActorsDialog3 extends DraggableDialog {
	
	private static inline var WIDTH:Int = 96;
	private static inline var HEIGHT:Int = 128;
	private static inline var XMARGIN:Int = 3;

	private var actorsContainer:ItemContainer;
	private var actorsArray:Array<Actor>;
	
	/**
	 * Constructor.
	 */
	public function new() {
		
		var dialogData:DialogData = new DialogData();
		dialogData.headerText = "Characters";
		dialogData.headerHeight = 14;
		dialogData.headerTextShadowColor = Colors.BLACK;
		dialogData.width = WIDTH;
		dialogData.height = HEIGHT;
				
		super(dialogData);
				
		headerText.y += 1;
		var actorsContainerY:Int = Std.int(headerContainer.y + headerContainer.height + 2);
		var actorsRectangle:Rectangle = new Rectangle(XMARGIN, actorsContainerY, WIDTH - 2 * XMARGIN, 50);
		actorsContainer = new ItemContainer(actorsRectangle);
		addChild(actorsContainer);
		
		var actorManager:ActorManager = ActorManager.getInstance();
		if (!actorManager.isReady()) {
			actorManager.addEventListener(Event.COMPLETE, onActorsLoaded);
		} else {
			onActorsLoaded();
		}
				
		addListeners();
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
		
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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

	/**
	 * Add listeners.
	 */
	override private function addListeners():Void {
		headerContainer.addEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.addEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
		//this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}
	
	/**
	 * Removes listeners.
	 */
	override private function removeListeners():Void {
		headerContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.removeEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
		//this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}

	
}