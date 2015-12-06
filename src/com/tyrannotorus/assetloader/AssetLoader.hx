package com.tyrannotorus.assetloader;

import haxe.ds.ObjectMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Entry;
import haxe.zip.Reader;
import List;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;

/**
 * AssetLoader.hx
 * Simplifies the external asset loading proceess.
 * Handles pngs, txts, and zip files (converting to dynamic)
 * Dispatches AssetEvent when complete.
 */

class AssetLoader extends EventDispatcher {
	
	// Handled File types.
	private static inline var PNG:String = "png";
	private static inline var TXT:String = "txt";
	private static inline var ZIP:String = "zip";
	
	// Cache of previously loaded assets.
	private static var assetCache:ObjectMap<Dynamic,AssetEvent> = new ObjectMap<Dynamic,AssetEvent>();
	
	// Class variables.
	private var urlLoader:URLLoader;
	private var assetEvent:AssetEvent;
	private var filesLeft:Int = 0;
	
	/**
	 * Constructor.
	 */
	public function new():Void {
		super();
	}
	
	/**
	 * Loads an asset from cache if it has been previously loaded; otherwise from locally or the web.
	 * @param {String} assetPath
	 */
	public function loadAsset(assetPath:String):Void {
		
		// If this asset was previously loaded, return it from the cache.
		assetEvent = assetCache.get(assetPath);
		if (assetEvent != null) {
			dispatchEvent(assetEvent);
			return;
		}
		
		// Create the asset event that will be dispatched to the user.
		assetEvent = new AssetEvent(AssetEvent.LOAD_COMPLETE);
		assetEvent.assetPath = assetPath;
		assetEvent.assetType = assetPath.split(".").pop().toLowerCase();
		
		// We're loading the asset from the web.
		if (assetPath.toLowerCase().indexOf("http") == 0) {
			
			// Initiate loading the asset.
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, onAssetLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onAssetLoadedError);
			urlLoader.addEventListener(ProgressEvent.PROGRESS, onAssetProgress);
			urlLoader.load(new URLRequest(assetPath));
			return;
		}
		
		// Otherwise, we're loading the asset from our local environment.
		switch(assetEvent.assetType) {
			
			// Load a zip.
			case ZIP:
				var zipFile:ByteArray = Assets.getBytes(assetPath);
				unpackZip(zipFile);
					
			// Load a bitmap.
			case PNG:
				var bitmapData:BitmapData = Assets.getBitmapData(assetPath);
				var bitmapFile:Bitmap = new Bitmap(bitmapData);
				assetEvent.assetData = bitmapFile;
			
			// Load a text file.
			case TXT:
				var textFile:String = Assets.getText(assetPath);
				assetEvent.assetData = textFile;
		}
		
		// Dispatch assetEvent if asset was successfully loaded.
		if (assetEvent.assetData != null) {
			dispatchComplete();
		}
	}
	
	/**
	 * The asset loaded successfully.
	 * @param {Event.COMPLETE} e
	 */
	private function onAssetLoaded(e:Event):Void {
		
		switch(assetEvent.assetType) {
			
			// Unpack the zip file.
			// OpenFL currently does *not* support compressed zip files.
			case ZIP:
				unpackZip(urlLoader.data);
				
			case PNG:
				assetEvent.assetData = cast(urlLoader.data, Bitmap);
				dispatchComplete();
				
			default:
		}
	}
	
	/**
	 * There was an error loading the asset. Nothing more we can do here.
	 * @param {IOErrorEvent.IO_ERROR} e
	 */
	private function onAssetLoadedError(e:IOErrorEvent):Void {
		trace("AssetLoader.onAssetLoadedError() Loading: " + assetEvent.assetPath + " " + e);
		cleanUp();
		dispatchEvent(assetEvent);
	}
	
	/**
	 * Called on progress loading the asset.
	 * @param {ProgressEvent.PROGRESS} e
	 */
	private function onAssetProgress(e:ProgressEvent):Void {
		var loadedPct:UInt = Math.round(100 * (e.bytesLoaded / e.bytesTotal)); 
	}
	
	/**
	 * Unpack a loaded asset that's a zip file.
	 * @param {ByteArray} byteArray
	 */
	private function unpackZip(byteArray:ByteArray):Void {
		
		// Read the file entries in the zip.
		var bytes:Bytes = Bytes.ofData(byteArray);
        var bytesInput:BytesInput = new haxe.io.BytesInput(bytes);
       	var reader:format.zip.Reader = new format.zip.Reader(bytesInput);
		var zipEntries:List<format.zip.Data.Entry> = reader.read();
		
		// Instantiate the assetData.
		assetEvent.assetData = { };
		
		filesLeft = zipEntries.length;
		trace("loading " + filesLeft);
				
		// Cycle through entries in the zip
		for(entry in zipEntries) {
			
			var fileName:String = entry.fileName.split("/").pop().toLowerCase();
			var fileType:String = fileName.split(".").pop();
			
			// Parse the PNG from the zip.
			if(fileType == PNG){
				var loader:Loader = new Loader();
				loader.name = fileName;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageFromZipLoaded);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageFromZipError);
				loader.loadBytes(entry.data.getData());
			
			// parse .txt from the zip
			} else if (fileType == TXT) {
				assetEvent.addData(fileName, entry.data.toString());
				filesLeft--;
				dispatchComplete();
			}
		} 
	}
	
	/**
	 * An image from within a zip file has loaded.
	 * @param {Event.COMPLETE} e
	 */
	private function onImageFromZipLoaded(e:Event):Void {
		
		// Remove the loader listeners.
		var loaderInfo:LoaderInfo = cast(e.target, LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, onImageFromZipLoaded);
		loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImageFromZipError);
		trace("loaded png " + loaderInfo.loader.name);
		assetEvent.addData(loaderInfo.loader.name, cast(loaderInfo.content, Bitmap));
		
		filesLeft--;
		dispatchComplete();
	}
	
	/**
	 * There was an error loading an image from within a zip file.
	 * @param {IOErrorEvent.IO_ERROR} e
	 */
	private function onImageFromZipError(e:IOErrorEvent):Void {
		
		// Remove the loader listeners.
		var loaderInfo:LoaderInfo = cast(e.target, LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, onImageFromZipLoaded);
		loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImageFromZipError);
		
		filesLeft--;
		dispatchComplete();
	}
	
	/**
	 * Dispatch Event.COMPLETE to let anyone listening know that the asset has loaded.
	 */
	private function dispatchComplete():Void {
		
		// We're still waiting on files to load.
		if (filesLeft > 0) {
			return;
		}
		trace("dispatching assetEvent " + assetEvent.type + " " + filesLeft);
		// Save the assetData to the assetCache and dispatch compelete.
		var assetPath:String = assetEvent.assetPath;
		assetCache.set(assetPath, assetEvent);
		dispatchEvent(assetEvent);
		
		cleanUp();
	}
	
	/**
	 * Always clean up your mess.
	 */
	private function cleanUp():Void {
		if(urlLoader != null) {
			urlLoader.removeEventListener(Event.COMPLETE, onAssetLoaded);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onAssetLoadedError);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS, onAssetProgress);
			urlLoader = null;
		}
	}
	
	
}
