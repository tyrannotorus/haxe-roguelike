package com.roguelike.editor;

import com.roguelike.events.DataEvent;

class EditorEvent extends DataEvent {
	
	public static inline var FILE:String = "FILE";
	public static inline var TILES:String = "TILES";
	public static inline var ACTORS:String = "ACTORS";
	public static inline var PROPS:String = "PROPS";
	public static inline var SETTINGS:String = "SETTINGS";
	public static inline var ZOOM_IN:String = "ZOOM_IN";
	public static inline var ZOOM_OUT:String = "ZOOM_OUT";
	public static inline var HELP:String = "HELP";
	public static inline var TILE_SELECTED:String = "TILE_SELECTED";
	public static inline var RESET_MAP:String = "RESET_MAP";
	public static inline var CLOSED:String = "CLOSED";
	public static inline var OPENED:String = "OPENED";
	
	/**
	 * A standard event with an added data parameter
	 * @param {String} type
	 * @param {Dynamic} data
	 * @param {Bool} bubbles
	 * @param {Bool} cancelable
	 */
	public function new(type:String, data:Dynamic = null, bubbles:Bool = false, cancelable:Bool = false) {
        super(type, data, bubbles, cancelable);
       
    }
}
