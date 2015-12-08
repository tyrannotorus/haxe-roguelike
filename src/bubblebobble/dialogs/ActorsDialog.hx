package bubblebobble.dialogs;

import bubblebobble.Actor;
import bubblebobble.dialogs.DraggableDialog;
import com.tyrannotorus.assetloader.AssetEvent;
import com.tyrannotorus.assetloader.AssetLoader;
import com.tyrannotorus.utils.ActorUtils;
import com.tyrannotorus.utils.Colors;
import com.tyrannotorus.utils.Utils;
import haxe.ds.ObjectMap;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
 * TilesDialog.hx.
 * - A draggable dialog with for use within the level editor.
 * - Loads a selection of tiles.
 */
class ActorsDialog extends DraggableDialog {
	
	private static inline var WIDTH:Int = 96;
	private static inline var HEIGHT:Int = 128;
	private static inline var XMARGIN:Int = 3;

	private var actorsContainer:ItemContainer;
	private var actorsMap:ObjectMap<Dynamic,Bitmap>;
	private var selectedTile:Bitmap;
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
		
		actorsArray = new Array<Actor>();
		
		addListeners();
	}
	
	/**
	 * Makes the tile publically accessible.
	 * @return {Bitmap}
	 */
	public function getSelectedTile():Bitmap {
		return selectedTile;
	}
	
	/**
	 * User has clicked the tiles container.
	 * @return {MouseEvent.CLICK} e
	 */
	private function onTileClick(e:MouseEvent):Void {
/*
		var tileBitmap:Bitmap = actorsMap.get(e.target);
		
		// Invalid. Something was clicked, but it wasn't a tile.
		if (tileBitmap == null) {
			e.stopImmediatePropagation();
			return;
		}
		
		// Swap in and position the new tile.
		selectedTile.bitmapData = tileBitmap.bitmapData;
		selectedTile.x = selectedTile.y = (16 - selectedTile.width) / 2;*/
	}
	
	/**
	 * Initiate load of the tileset.
	 */
	public function loadActors():Void {
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
			trace("TilesDialog.onActorsLoaded() Failure.");
			return;
		}
		
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
				var actorData:Dynamic = ActorUtils.parseActorData(spriteSheet.bitmapData, spriteLogic);
				var actor:Actor = new Actor(actorData);
				actor.buttonMode = true;
				
				actorsArray.push(actor);
				actorsContainer.addItem(actor);
			}
		}
	}
	
	
	/**
	 * Animate an creatures on the level.
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

	/**
	 * Add listeners.
	 */
	override private function addListeners():Void {
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		headerContainer.addEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.addEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}
	
	/**
	 * Removes listeners.
	 */
	override private function removeListeners():Void {
		this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		headerContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		headerContainer.removeEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}

	
}