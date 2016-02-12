package com.roguelike.editor;

import flash.events.Event;
import openfl.events.EventDispatcher;

class EditorDispatcher extends EventDispatcher {
	
	public static var editorDispatcher:EditorDispatcher;
	
	/**
	 * Return the singleton instance of the editor dispatcher.
	 * @return {EditorDispatcher}
	 */
	public static function getInstance():EditorDispatcher {
		return (editorDispatcher != null) ? editorDispatcher : editorDispatcher = new EditorDispatcher();
	}
	
	/**
	 * Constuctor.
	 */
	public function new() {
       super();
    }
}
