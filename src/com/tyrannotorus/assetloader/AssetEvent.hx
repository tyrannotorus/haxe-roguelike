package com.tyrannotorus.assetloader;

import openfl.events.Event;

/**
 * AssetEvent.hx
 * Dispatched by AssetLoader.as.
 */
class AssetEvent extends Event {
	
	// Event types.
	public static inline var LOAD_COMPLETE:String = "LOAD_COMPLETE";
	
	// Asset event properties.
	public var assetData:Dynamic;
	public var assetType:String;
	public var assetPath:String;
	
	/**
	 * A standard event with an added assetData parameter.
	 * @param {String} type
	 * @param {Dynamic} assetData
	 * @param {Bool} bubbles
	 * @param {Bool} cancelable
	 */
	public function new(type:String, assetData:Dynamic = null, bubbles:Bool = false, cancelable:Bool = false) {
        super(type, bubbles, cancelable);
        this.assetData = assetData;
    }
	
	/**
	 * In the case of zip files, the assetData will by dynamic with individual properties for the indcan be comprised of multiple files.
	 * @param {String} assetName
	 * @param {Dynamic} assetData
	 */
	public function addData(assetName:String, assetData:Dynamic):Void {
		
		if (!this.assetData) {
			return;
		}
		
		Reflect.setField(this.assetData, assetName, assetData);
	}
	
	/**
	 * Return a specified property of the assetData.
	 * @param {String} assetName
	 * @return {Dynamic}
	 */
	public function getData(assetName:String = null):Dynamic {
		
		// If no assetName is passed, return the whole assetData.
		if (!assetData || assetName == null){
			return assetData;
		}
		
		// Return the field name of the assetData.
		return Reflect.field(assetData, assetName);
	}
}
