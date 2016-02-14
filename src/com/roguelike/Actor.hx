package com.roguelike;
	
import com.roguelike.editor.ActorData;
import com.roguelike.editor.Tile;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import motion.Actuate;
import motion.easing.Cubic;

/**
 * Actor.as
 * - Self animates.
 * - Used for all entities.
 */
class Actor extends Sprite {
	
	public static inline var HOP_HEIGHT:Int = 4;
	public static inline var MOVE_SPEED:Float = 0.1;
	
	// Amimation types.
	public var IDLE:Int = 0;
	public var WALK:Int;
	public var STUN:Int;
	
	public var currentTile:Tile;
	
	private var frameTimings:Array<Array<Int>>;
	private var frameBitmaps:Array<Array<Bitmap>>;
	private var frameHitAreas:Array<Array<Sprite>>;
	private var hitFrames:Array<Array<Int>>;
	private var xShiftFrames:Array<Array<Int>>;
	private var yShiftFrames:Array<Array<Int>>;
	private var xShoveFrames:Array<Array<Int>>;
	private var yShoveFrames:Array<Array<Int>>;
	private var flipFrames:Array<Array<Int>>;
	//private var sfx			:Array<Array<Sound>>;		// sound effects
		
	//public var sfxtransform	:SoundTransform;
	//public var sfxchannel	:SoundChannel;
		
	public  var cpu			:Int;
	public  var hunterpool	:Array<Actor>;	// Targets hunting you
	public  var targetpool	:Array<Actor>;	// Viable targets to choose from
	private var target		:Actor;				// Targeted actor
	private var victim		:Actor;				// Grappled vicitm
	private var grudge		:Actor;				// Preferred target
			
	public var currentFrame:Int = 0;
	public var currentAnimation:Int = 0;
	public var nextAnimation:Int = 0;
		
	public var currentBitmap:Bitmap;
	public var currentHitSprite:Sprite;
	public var frameContainer:Sprite;
			
	// Actor Stats
	public  var actorName	:String;
	public  var health		:Int;
	public  var stamina		:Int;
	public  var recovery	:Int;
	private var willpower	:Int;
	private var walkspeed	:Float;
	private var runspeed	:Int;
	private var attackpower	:Int;
	private var jump		:Int;
	private var jumppower	:Int;
	private var zspeed		:Float;
	private var stats		:Dynamic;
	private var hitPower	:Int;
		
	// Actor location and movement variables
	public var vx			:Int;	// Characters X momentum
	public var vy			:Int;	// Characters Y momentum
	
	// TEMPORARY VARIABLE HOLDERS
	private var tmpxShiftFrames	:Int;	// xShiftFrames[currentAnimation][currentFrame] holder should declare these when needed = faster
	private var tmpyShiftFrames	:Int;	// yShiftFrames[currentAnimation][currentFrame] holder
			
	private var tick		:Int = 0;		
	private var combo		:Int;
		
	// Heath Display
	private var healthdisplay	:Dynamic;
	private var healthtick		:Int;
						
	private var player:Actor;
	private var opponent:Actor;
	private var isMoving:Bool;
	
	private var actorData:ActorData;
		
	/**
	 * Constructor.
	 * @param {ActorData} actorData
	 */
	public function new(actorData:ActorData):Void {
		
		super();
		
		this.actorData = actorData;
		this.actorName = actorData.name;
		
		frameContainer = new Sprite();
		frameContainer.mouseChildren = false;
		currentBitmap = new Bitmap();
		currentBitmap.visible = true;
		
		// Copy over the animation types to our local variables.
		for (idxAnimation in 0...actorData.animationTypes.length) {
			var animationType:String = actorData.animationTypes[idxAnimation];
			try {
				Reflect.setField(this, animationType, idxAnimation);
			} catch(e:String) {
				trace("Actor.hx " + animationType + " does not exist on Actor.hx " + e);
			}
		}
		
		frameBitmaps = new Array<Array<Bitmap>>();
		frameHitAreas = new Array<Array<Sprite>>();
		frameTimings = actorData.frameTimings;
		hitFrames = actorData.hitFrames;
		xShiftFrames = actorData.xShiftFrames;
		yShiftFrames = actorData.yShiftFrames;
		xShoveFrames = actorData.xShoveFrames;
		yShoveFrames = actorData.yShoveFrames;
		flipFrames = actorData.flipFrames;
			
		for (idxAnimation in 0...frameTimings.length) {
			
			var bitmapArray:Array<Bitmap> = new Array<Bitmap>();
			var hitAreaArray:Array<Sprite> = new Array<Sprite>();
			
			for (idxFrame in 0...frameTimings[idxAnimation].length) {
				
				// Add the bitmap cell.
				var frameBitmap:Bitmap = new Bitmap(actorData.frameBitmapDatas[idxAnimation][idxFrame]);
				frameBitmap.visible = false;
				bitmapArray.push(frameBitmap);
				frameContainer.addChild(frameBitmap);
				
				// Add the cell hitArea.
				var hitAreaSprite:Sprite = new Sprite();
				hitAreaSprite.graphics.copyFrom(actorData.frameHitAreas[idxAnimation][idxFrame].graphics);
				hitAreaSprite.visible = false;
				hitAreaSprite.mouseEnabled = false;
				hitAreaArray.push(hitAreaSprite);
				frameContainer.addChild(hitAreaSprite);
			}
			
			frameBitmaps.push(bitmapArray);
			frameHitAreas.push(hitAreaArray);			
		}
				
		currentBitmap.bitmapData = frameBitmaps[0][0].bitmapData;
		currentHitSprite = frameHitAreas[0][0];
		
		#if flash
			this.hitArea = currentHitSprite;
		#end
						
		frameContainer.x = -Math.floor(currentBitmap.width / 2);
		frameContainer.y = -Math.floor(currentBitmap.height) + 1;
		frameContainer.mouseChildren = false;
		frameContainer.mouseEnabled = false;
		
		addChild(frameContainer);
	}
	
	/**
	 * Force a change in the animation
	 * @param {Int} newAnimation
	 * @param {Int} nextAnimation
	 * @param {Bool} updateNow - force the bitmapData to change this frame
	 */
	public function setAnimation(newAnimation:Int = 0, nextAnimation:Int = 0, updateNow:Bool = false):Void {
			
		// There is no change in the current animation.
		if (currentAnimation == newAnimation) {
			return;
		}
			
		currentFrame = tick = 0;
		currentAnimation = newAnimation;
		this.nextAnimation = nextAnimation;
			
		// Update the frame of the actor immediately.
		//if (updateNow) {
		//	currentBitmap.visible = false;
		//	currentBitmap = frameBitmaps[currentAnimation][currentFrame];
		//	currentBitmap.visible = false;
		//	currentHitSprite.visible = false;
		//	currentHitSprite = frameHitAreas[currentAnimation][currentFrame];
		//	currentHitSprite.visible = true;
		//	this.hitArea = currentHitSprite;
		//}
			
	}
		
	/**
	 * Called everyframe to animate the actor.
	 */
	public function animate():Void {
			
		// If end of frame, go to next frame
		if(tick == frameTimings[currentAnimation][currentFrame]) {
				
			tick = 0;
				
			// Animation turnover
			if (++currentFrame == frameTimings[currentAnimation].length) {
					
				// If stunned, repeat stun animation until recovery time = 0
				if( recovery > 0) {
					if( --recovery > 0) {
						nextAnimation = STUN;
						
					} else { 
						nextAnimation = IDLE;
						if ( health <= 0 ) {
							stamina = 1;
						} else {
							stamina = 3;
						}
					}
				} 
					
				//comboChain = (comboChain == 3) ? 2 : 0;
				currentFrame = 0;
				currentAnimation = nextAnimation;
				nextAnimation = IDLE;
			}
		}
			
		// IMPLEMENT NEW FRAME IF TICK HAS BEEN RESET
		if ( tick++ == 0) {
				
			// ADD ADDITIONAL X VELOCITY
			vx += Std.int(scaleX * xShoveFrames[currentAnimation][currentFrame]);
				
			// ADD ADDITIONAL Y VELOCITY
			if (yShoveFrames[currentAnimation][currentFrame] > 0) {
				vy += yShoveFrames[currentAnimation][currentFrame];
				//if( altitude != altitude ) altitude = elevation;
			}
				
			// SHIFT BITMAP PIXELS
			frameContainer.x -= tmpxShiftFrames;
			frameContainer.x += (tmpxShiftFrames = xShiftFrames[currentAnimation][currentFrame]);
			frameContainer.y -= tmpyShiftFrames;
			frameContainer.y += (tmpyShiftFrames = yShiftFrames[currentAnimation][currentFrame]);
				
			// FLIP FRAME
			scaleX *= flipFrames[currentAnimation][currentFrame];
				
			// HIT FRAME
			hitPower = hitFrames[currentAnimation][currentFrame];
			if (hitPower > 0) {
				//opponent.punch(currentAnimation, hitPower);
			}
				
			// PLAY SFX
			//if( sfx[currentAnimation][currentFrame] != null )
			//sfxchannel = sfx[currentAnimation][currentFrame].play( 0, 0, sfxtransform );
				
			// Update the frame.
			currentBitmap.visible = false;
			currentBitmap = frameBitmaps[currentAnimation][currentFrame];
			currentBitmap.visible = true;
			//currentHitSprite.visible = false;
			currentHitSprite = frameHitAreas[currentAnimation][currentFrame];
			//currentHitSprite.visible = false;
			#if flash
				this.hitArea = currentHitSprite;
			#end
		}
			
		x += vx;
	}
	
	/*
	 * Move the actor to another Tile
	 */
	public function moveToTile(tileKey:Int):Void {
		
		if (isMoving) {
			return;
		}
		
		var newTile:Tile = currentTile.getNeighbourTile(tileKey);
		
		if (newTile != null) {
			
			if (newTile.x < currentTile.x) {
				scaleX = -1;
			} else if (newTile.x > currentTile.x) {
				scaleX = 1;
			}
			
			if(newTile.elevation > 0) {
			
				currentTile.highlight(false);
			
				var xDistance:Float = (newTile.x - currentTile.x);
				var yDistance:Float = (newTile.y - currentTile.y);
			
				if (xDistance >= 0 && yDistance >= 0 || yDistance > 0) {
					newTile.addOccupant(this, -xDistance, -yDistance);
					currentTile.highlight(false);
					Actuate.tween(this, MOVE_SPEED * 2, {x:0, y:0}).ease(Cubic.easeInOut).onComplete(completeMoveTile, [newTile]);
				} else {
					Actuate.tween(this, MOVE_SPEED * 2, {x:xDistance, y:yDistance}).ease(Cubic.easeInOut).onComplete(completeMoveTile, [newTile]);
				}
				isMoving = true;
			}
			//Actuate.tween(this, MOVE_SPEED * 2, { x:xDistance } ).onComplete(completeMoveTile, [newTile]);
		}
			
	}
	
	private function changeTile():Void {
		
		//Actuate.tween(this, MOVE_SPEED, {y:0}).ease(Cubic.easeIn);
				
	}
	
	private function completeMoveTile(newTile:Tile):Void {
		newTile.addOccupant(this);
		currentTile.highlight(true);
		//setAnimation(IDLE);
		isMoving = false;
	}
	
	/*
	 * Clone the actor
	 * @return {Actor}
	 */
	public function clone():Actor {
		return new Actor(actorData);
	}
		
	
}
