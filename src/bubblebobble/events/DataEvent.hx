package bubblebobble.events;

import flash.events.Event;

class DataEvent extends Event {
	
	public static inline var LOAD_COMPLETE:String = "LOAD_COMPLETE";
	public var data:Dynamic;
	
	/**
	 * A standard event with an added data parameter
	 * @param {String} type
	 * @param {Dynamic} data
	 * @param {Bool} bubbles
	 * @param {Bool} cancelable
	 */
	public function new(type:String, data:Dynamic, bubbles:Bool = false, cancelable:Bool = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
