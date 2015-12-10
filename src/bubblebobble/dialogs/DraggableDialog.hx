package bubblebobble.dialogs;

import haxe.ds.StringMap;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * DraggableDialog.as.
 * - If you want your new, fancy GenericDialog to be draggable around the screen in some manner, extend this.
 * - DraggableDialogs maintain independent positioning for both windowed/fullscreen display states, which auto-restore upon switching display state.
 * - Advised: Override the addListeners/removeListeners functions in order to add drag clicking to a specified part of the dialog.
 */
class DraggableDialog extends GenericDialog {

	private var displayStatePosition:StringMap<Dynamic> = new StringMap<Dynamic>();

	/**
	 * Constructor.
	 * @param {DialogData} dialogData
	 */
	public function new(dialogData:DialogData = null) {
		super(dialogData);
	}
	
	/**
	 * Mouse is held down, inititate the drag of the dialog
	 * @param {MouseEvent.MOUSE_DOWN} e
	 */
	private function onStartDialogDrag(e:MouseEvent):Void {
		e.stopImmediatePropagation();
		this.parent.setChildIndex(this, this.parent.numChildren - 1);
		startDrag();
	}

	/**
	 * Stop dragging the dialog.
	 * @param {MouseEvent.MOUSE_UP} e
	 */
	private function onStopDialogDrag(e:MouseEvent):Void {
		e.stopImmediatePropagation();
		stopDrag();
	}

	/**
	 * Restores the saved position of the chat log window depending on the current display state (fullscreen or normal screen)
		 * @param {Event.RESIZE} e
	 */
	public function restorePosition(e:Event = null):Void {
		
	}

	/**
	 * Positions the dialog, with the option of setting both restorable display state positions to this position.
	 * Use this when positioning the window for the first time.
	 * @param {Number} x
	 * @param {Number} y
	 * @param {Boolean} setRestorablePositions
	 */
	public function setPosition(x:Int, y:Int, setRestorablePositions:Bool = false):Void {
		
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