package roguelike;
	
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;

/**
 * Actor.as
 * - Self animates.
 * - Used for all entities.
 */
class Actor extends Sprite {
		
	public var IDLE:Int = 0;
	public var WALK:Int;
	public var STUN:Int;
	
	private var cellBitmaps:Array<Array<Bitmap>>;
	private var cellHitSprites:Array<Array<Sprite>>;
	
	private var frames		:Array<Array<Int>>; 		// Frame timings
	private var hit			:Array<Array<Int>>;			// Hit power
	private var xshift		:Array<Array<Int>>;  		// x displacement
	private var yshift		:Array<Array<Int>>;  		// y displacement
	private var xshove		:Array<Array<Int>>;  		// Add x momentum
	private var yshove		:Array<Array<Int>>;  		// Add y momentum
	private var flip		:Array<Array<Int>>; 		// flip frames
	private var blockHigh	:Array<Array<Int>>; 		// flip frames
	private var blockLow	:Array<Array<Int>>; 		// flip frames
	private var dodge		:Array<Array<Int>>; 		// flip frames
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
	public var cellContainer:Sprite;
			
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
	private var tmpxshift	:Int;	// xshift[currentAnimation][currentFrame] holder should declare these when needed = faster
	private var tmpyshift	:Int;	// yshift[currentAnimation][currentFrame] holder
			
	private var tick		:Int = 0;		
	private var combo		:Int;
		
	// Heath Display
	private var healthdisplay	:Dynamic;
	private var healthtick		:Int;
						
	private var player:Actor;
	private var opponent:Actor;
	
	private var actorData:Dynamic;
		
	/**
	 * Constructor.
	 * @param {Dynamic} actorData
	 */
	public function new(actorData:Dynamic):Void {
		
		super();
		
		this.actorData = actorData;
		
		cellContainer = new Sprite();
		cellContainer.mouseChildren = false;
		
		cellBitmaps	= new Array<Array<Bitmap>>();
		cellHitSprites = new Array<Array<Sprite>>();
		
		frames = new Array<Array<Int>>();
		hit = new Array<Array<Int>>();
		xshift = new Array<Array<Int>>();
		yshift = new Array<Array<Int>>();
		xshove = new Array<Array<Int>>();
		yshove = new Array<Array<Int>>();
		flip = new Array<Array<Int>>();
				
		// Populate local variables with actionData
		var actionData:Dynamic = Reflect.field(actorData, "actions");
		var fields:Array<String> = Reflect.fields(actionData);
		var fieldName:String;
		var index:Int = 1;
		var idx:Int = 0;
		try{
			for (i in 0...fields.length) {
				
				fieldName = fields[i];
				
				// Reserve IDLE = 0, regardless of where in the logic IDLE is defined
				if (fieldName.toUpperCase() == "IDLE") {
					idx = 0;
				} else {
					idx = index++;
				}
				
				trace(i + " " + fields[i] + " setting idx to " + idx + " index:" + index);
				Reflect.setField(Reflect.field(actionData, fieldName), "idx", idx);
				Reflect.setField(this, fields[i].toUpperCase(), idx);
				//sfx[index]			= $actor.actions[action].sfx;
				frames[idx]	= Reflect.field(Reflect.field(actionData, fieldName), "timing");
				hit[idx]	= Reflect.field(Reflect.field(actionData, fieldName), "hit");
				xshift[idx] = Reflect.field(Reflect.field(actionData, fieldName), "xshift");
				yshift[idx] = Reflect.field(Reflect.field(actionData, fieldName), "yshift");
				xshove[idx] = Reflect.field(Reflect.field(actionData, fieldName), "xshove");
				yshove[idx] = Reflect.field(Reflect.field(actionData, fieldName), "yshove");
				flip[idx] = Reflect.field(Reflect.field(actionData, fieldName), "flip");
								
				var cellBmds:Array<BitmapData> = Reflect.field(Reflect.field(actionData, fieldName), "bitmaps");
				var cellShapes:Array<Sprite> = Reflect.field(Reflect.field(actionData, fieldName), "shapes");
				
				cellBitmaps[idx] = new Array<Bitmap>();
				cellHitSprites[idx] = new Array<Sprite>();
				for (j in 0...cellBmds.length) {
				
					// Add the bitmap cell.
					var cellBitmap:Bitmap = new Bitmap(cellBmds[j]);
					cellBitmap.visible = false;
					cellBitmaps[idx][j] = cellBitmap;
					cellContainer.addChild(cellBitmap);
				
					// Add the cell hitArea.
					var hitSprite:Sprite = new Sprite();
					hitSprite.graphics.copyFrom(cellShapes[j].graphics);
					hitSprite.visible = false;
					hitSprite.mouseEnabled = false;
					cellHitSprites[idx][j] = hitSprite;
					cellContainer.addChild(hitSprite);
				}
			}

		} catch(e:String) {
			trace("Unable to set variable " + e);
			return;
		}
		
		var statsData:Dynamic = Reflect.field(actorData, "stats");
		actorName = Reflect.field(statsData, "NAME");
		
		currentBitmap = new Bitmap();
		currentBitmap.bitmapData = cellBitmaps[0][0].bitmapData;
		currentBitmap.visible = true;
		
		currentHitSprite = cellHitSprites[0][0];
		//currentHitSprite.visible = false;
		#if flash
			this.hitArea = currentHitSprite;
		#end
						
		cellContainer.x = -Math.floor(currentBitmap.width / 2);
		cellContainer.y = -Math.floor(currentBitmap.height) + 1;
		cellContainer.mouseChildren = false;
		cellContainer.mouseEnabled = false;
		
		addChild(cellContainer);
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
		//	currentBitmap = cellBitmaps[currentAnimation][currentFrame];
		//	currentBitmap.visible = false;
		//	currentHitSprite.visible = false;
		//	currentHitSprite = cellHitSprites[currentAnimation][currentFrame];
		//	currentHitSprite.visible = true;
		//	this.hitArea = currentHitSprite;
		//}
			
	}
		
	/**
	 * Called everyframe to animate the actor.
	 */
	public function animate():Void {
			
		// If end of frame, go to next frame
		if(tick == frames[currentAnimation][currentFrame]) {
				
			tick = 0;
				
			// Animation turnover
			if (++currentFrame == frames[currentAnimation].length) {
					
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
			vx += Std.int(scaleX * xshove[currentAnimation][currentFrame]);
				
			// ADD ADDITIONAL Y VELOCITY
			if (yshove[currentAnimation][currentFrame] > 0) {
				vy += yshove[currentAnimation][currentFrame];
				//if( altitude != altitude ) altitude = elevation;
			}
				
			// SHIFT BITMAP PIXELS
			cellContainer.x -= tmpxshift;
			cellContainer.x += (tmpxshift = xshift[currentAnimation][currentFrame]);
			cellContainer.y -= tmpyshift;
			cellContainer.y += (tmpyshift = yshift[currentAnimation][currentFrame]);
				
			// FLIP FRAME
			scaleX *= flip[currentAnimation][currentFrame];
				
			// HIT FRAME
			hitPower = hit[currentAnimation][currentFrame];
			if (hitPower > 0) {
				//opponent.punch(currentAnimation, hitPower);
			}
				
			// PLAY SFX
			//if( sfx[currentAnimation][currentFrame] != null )
			//sfxchannel = sfx[currentAnimation][currentFrame].play( 0, 0, sfxtransform );
				
			// Update the frame.
			currentBitmap.visible = false;
			currentBitmap = cellBitmaps[currentAnimation][currentFrame];
			currentBitmap.visible = true;
			//currentHitSprite.visible = false;
			currentHitSprite = cellHitSprites[currentAnimation][currentFrame];
			//currentHitSprite.visible = false;
			#if flash
				this.hitArea = currentHitSprite;
			#end
		}
			
		x += vx;
	}
	
	/*
	 * Clone the actor
	 * @return {Actor}
	 */
	public function clone():Actor {
		return new Actor(actorData);
	}
		
	
}
