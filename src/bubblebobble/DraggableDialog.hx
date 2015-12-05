package bubblebobble;

import haxe.ds.StringMap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * DraggableDialog.as.
 * - If you want your new, fancy dialog to be draggable around the screen in some manner, extend this.
 * - DraggableDialogs maintain independent positioning for both windowed/fullscreen display states, which auto-restore upon switching display state.
 * - Advised: Override the addListeners/removeListeners functions in order to add drag clicking to a specified part of the dialog.
 */
class DraggableDialog extends Sprite {

	private var displayStatePosition:StringMap<Dynamic> = new StringMap<Dynamic>();

	/**
	 * Constructor.
	 */
	public function new() {
		
		super();
		
		// Grab our local reference to myLife.
		//myLife = MyLifeInstance.getInstance() as MyLifeGame;
		
		// Listen for display state changes.
		//myLife.gblStage.addEventListener(Event.RESIZE, restorePosition);
	}
		/**
	 * Mouse is held down, inititate the drag of the dialog
	 * @param {MouseEvent.MOUSE_DOWN} e
	 */
	private function onStartDialogDrag(e:MouseEvent):Void {
		trace("startDrag()");
		//var displayState:String = myLife.gblStage.displayState;
		//if(displayStatePosition[displayState] == null) {
		//	displayStatePosition[displayState] = new Point(0,0);
		//}
			//displayStatePosition[displayState].x = x;
		//displayStatePosition[displayState].y = y;
		startDrag();
	}

	/**
	 * Stop dragging the dialog.
	 * @param {MouseEvent.MOUSE_MOVE} e
	 */
	private function onStopDialogDrag(e:MouseEvent):Void {
	trace("onStopDialogDrag()");
		//var displayState:String = myLife.gblStage.displayState;
		//if(displayStatePosition[displayState] == null) {
		//	displayStatePosition[displayState] = new Point(0,0);
		//}
			//displayStatePosition[displayState].x = x;
		//displayStatePosition[displayState].y = y;
		stopDrag();
	}

	/**
	 * Restores the saved position of the chat log window depending on the current display state (fullscreen or normal screen)
		 * @param {Event.RESIZE} e
	 */
	public function restorePosition(e:Event = null):Void {
		
		//var displayState:String = myLife.gblStage.displayState;
		
		//if(displayStatePosition[displayState] != null) {
		//	var point:Point = displayStatePosition[displayState];
		//	x = point.x;
		//	y = point.y;
		//}
	}

	/**
	 * Positions the dialog, with the option of setting both restorable display state positions to this position.
	 * Use this when positioning the window for the first time.
	 * @param {Number} x
	 * @param {Number} y
	 * @param {Boolean} setRestorablePositions
	 */
	public function setPosition(x:Int, y:Int, setRestorablePositions:Bool = false):Void {
		
		//this.x = x;
		//this.y = y;
		
		//if(setRestorablePositions) {
		//	displayStatePosition[FullScreenManager.WINDOW] = new Point(x, y);
		//	displayStatePosition[FullScreenManager.FULLSCREEN] = new Point(x, y);
		//}
	}

	/**
	 * Adds the drag listeners. By default, you can drag the entire dialog by clicking anywhere.
	 * Override this function to add drag listeners to the appropriate part of the dialog (the title bar, for instance).
	 */
	private function addListeners():Void {
		//this.addEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag, false, 0, true);
		//this.addEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag, false, 0, true);
	}

	/**
	 * Removes the drag listeners. Override this function as well.
	 */
	private function removeListeners():Void {
		//this.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDialogDrag);
		//this.removeEventListener(MouseEvent.MOUSE_UP, onStopDialogDrag);
	}

	/**
	 * And make sure you clean up your mess.
	 */
	public function cleanUp():Void {
		//myLife.gblStage.removeEventListener(Event.RESIZE, restorePosition);
		//myLife = null;
	}
	
}