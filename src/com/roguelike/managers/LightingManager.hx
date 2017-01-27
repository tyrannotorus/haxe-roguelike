package com.roguelike.managers;

import com.tyrannotorus.assetloader.AssetEvent;
import com.tyrannotorus.assetloader.AssetLoader;
import com.tyrannotorus.utils.Utils;
import haxe.ds.HashMap;
import haxe.ds.ObjectMap;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import com.roguelike.editor.Tile;
import com.roguelike.editor.TileData;
import motion.Actuate;
import com.tyrannotorus.utils.Colors;

class LightingManager {
	
	private static var litTiles:Array<Tile> = new Array<Tile>();
	
	/**
	 * Returns whether the tileManager has loaded tiles yet.
	 * @return {Bool}
	 */
	 public static function lightTile(tile:Tile, rings:Int = 7):Void {
		
		// Reset previous tiles.
		for(ii in 0 ... litTiles.length) {
			Actuate.transform(litTiles[ii], 0).color(Colors.BLACK, 1);
		}
		
		var allNeighbours:Array<Tile> = new Array<Tile>();
		allNeighbours[0] = tile;
		
		var neighbourRings:Array<Array<Tile>> = new Array<Array<Tile>>();
		neighbourRings[0] = new Array<Tile>();
		neighbourRings[0][0] = tile;
				 
		for (ii in 1 ... rings) {
			
			var previousRing:Array<Tile> = neighbourRings[ii - 1];
			var neighbourRing:Array<Tile> = new Array<Tile>();
			
			for (jj in 0 ... previousRing.length) {
				extractNeighbours(previousRing[jj], neighbourRing, allNeighbours);
			}
			
			neighbourRings[ii] = neighbourRing;
		}
		
		// Light the tiles.
		var lightValue:Float = 0;
		for (ii in 0 ... neighbourRings.length) {
			
			for (jj in 0 ... neighbourRings[ii].length) {
				Actuate.transform(neighbourRings[ii][jj], 0).color(Colors.BLACK, lightValue);
			}
			lightValue += 0.15;
			if (lightValue > 1) {
				lightValue = 1;
			}
		}
 
	}
	
	private static function extractNeighbours(tile:Tile, neighbourRing:Array<Tile>, allNeighbours:Array<Tile>):Void {
		
		if (tile == null) {
			return;
		}
		
		var neighbours:Array<Tile> = tile.neighbourTiles;
		for (ii in 0 ... neighbours.length) {
			var neighbour:Tile = neighbours[ii];
			if (allNeighbours.indexOf(neighbour) == -1) {
				neighbourRing.push(neighbour);
				allNeighbours.push(neighbour);
			}
		}
	}
	
	
}
