package  {
	import flash.display.MovieClip;
	//import fl.controls.Button;
	import flash.system.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	import fl.controls.Button;
	import flash.geom.Point;
import org.flintparticles.common.counters.*;
import org.flintparticles.common.displayObjects.*;
import org.flintparticles.common.initializers.*;
import org.flintparticles.twoD.actions.*;
import org.flintparticles.twoD.emitters.Emitter2D;
import org.flintparticles.twoD.initializers.*;
import org.flintparticles.twoD.renderers.*;
import org.flintparticles.twoD.zones.*;


  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.text.TextField;
  import flash.display.MovieClip;
  import fl.motion.easing.Back;
  import org.flintparticles.common.energyEasing.Bounce;
  
	public class UnitBrick extends MovieClip  {
		private var emitter:Emitter2D;
    	//private var bitmap:Bitmap;
		private var renderer:DisplayObjectRenderer;
		private var stageRef:Stage;
		//private var myRoot:MovieClip;
		public var myBall:MovieClip;
		public var myPaddle:MovieClip;
		public var ball:Ball;
		public var evilPaddle:MovieClip;
		public var evilSight:MovieClip;
		public var startButton:Button;
		public var ePaddle:enemyPaddle;
		var xCoord:Number;
		var yCoord:Number;
		var ex:Explode;
		var myColor:int = 1;
		var bitmapData:BitmapData;
		var shortTimer:Timer = new Timer(200, 1); //this controls the response of bricks to being hit with the ball; if the timer is up the ball reverses x/y vectors.  Otherwise the brick is made inert as per usual, but the ball passes through it.  500 ms is probably too long
		var deathTimer:Timer = new Timer(100,1);
		var rebuild:Boolean = false;
		var lvlCode:Array;
		var bricksHandle:Bricks;
		var mainRef:FlashForceMain;
		var starHit:int;
		var brickID:String; //do we need this and the myColor int?
		
		/*
		now begins the invisibrick validity controls
		*/
		private var isValid:Boolean = false;
		private var isRendered:Boolean = false;
		private var isListening:Boolean = false;
		private var isActivated:Boolean = false;
		private var matrix:BitmapData;
		//private var isInit:Boolean = true;
		private static const COLOR_RED_POWER:int = 1;
		private static const COLOR_GREEN:int = 2;
		private static const COLOR_BLUE_BLOCK:int = 3;

		
		public function UnitBrick(enPaddle:enemyPaddle = null,paddle:MovieClip= null,ball:MovieClip= null,theBall:Ball= null,ePaddle:MovieClip= null,startB:Button= null,myX:Number= 0,myY:Number= 0,level:Array= null,bricksH:Bricks= null,stageR:Stage = null,mainR:FlashForceMain= null) {
			// constructor code
			this.ePaddle = enPaddle;
			this.myBall = ball;
			this.myPaddle = paddle;
			this.ball = theBall;
			this.evilPaddle = ePaddle;
			//this.evilSight = eSight;
			this.startButton = startB;
			this.lvlCode = level;
			this.bricksHandle = bricksH;
			this.stageRef = stageR;
			this.mainRef = mainR;
			xCoord = myX;
			yCoord = myY;
			//this.height = 0;
			//this.width = 0;
			/*taking out the immediate activation here
			this.addEventListener(Event.ENTER_FRAME, waitToDie);
			shortTimer.start();
			shortTimer.addEventListener(TimerEvent.TIMER_COMPLETE, tickDone); //I believe this may be related to issue FR #1 -- what exactly is the function of ball.countHit?
			deathTimer.addEventListener(TimerEvent.TIMER, deathStart);        //also, what EXACTLY does ball.hitControl do?
			deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, death);
			setStarHit();
			addEvent();
			*/
			this.addEventListener(Event.ENTER_FRAME, queryVisible);

		}
		public function queryVisible(event:Event){
			//trace("this.visible is: " + this.visible);
			/*
			trace("UnitBrick.width is: " + this.width);
			trace("UnitBrick.height is: " + this.height);
			trace("UnitBrick.x/y is: " + this.x + "," + this.y);
			trace("UnitBrick.visible is: " + this.visible);
			*/
			trace("stage size: " + bricksHandle.stageSize + "block bricks remaining: " + bricksHandle.brickBlockCount + "bricks 'destroyed': " + ball.bricksDestroyed);
		}
		
		// we'll need to edit some of the below functions so that they don't activate anything till the 
		//invisibrick 'becomes' a specific brick type --DONE I believe...
		
		//Also, the waitToDie methods will need to be renamed to indicate which brick tyope they belong to --DONE hopefully
		//Finally, brickPower at least has its own unique death function --DONE hopefully
		
		//I assume the idea was to have the level generator pass in the brickID OR have the level generator activate the particular waitToDieX function...
		
		//COMMON BRICK FUNCTIONS
		public function addButtonWiredEvent(){
			//we wire each invisibrick object to the startbutton awaiting
			//a click.  When click is received, it sends selfDestruct signal
			//to each invisibrick object to process on itself.
			//Thus it is desirable to have each existing invisibrick hook an 
			//eventlistener to ball.startButton 
			ball.startButton.addEventListener(MouseEvent.CLICK, selfDestruct);
		}
		public function setStarHit(){
			if (xCoord < 55){
				starHit = 0;
			}
			else if (xCoord >= 55 && xCoord < 65){
				starHit = 1;
			}
			else if (xCoord >= 110 && xCoord < 120){
				starHit = 2;
			}
			else if (xCoord >= 165 && xCoord < 175){
				starHit = 3;
			}
			else if (xCoord >= 215 && xCoord < 225){
				starHit = 4;
			}
			else if (xCoord >= 270 && xCoord < 280){
				starHit = 5;
			}
			else if (xCoord >= 325 && xCoord < 335){
				starHit = 6;
			}
			else if (xCoord >= 380 && xCoord < 390){
				starHit = 7;
			}
			else if (xCoord >= 415 && xCoord < 470){
				starHit = 8;
			}
			else if (xCoord >= 470 && xCoord < 500){
				starHit = 9;
			}
		}
		
		public function tickDone(event:TimerEvent){
			if (!ball.punchPower){
			ball.countHit = 0;
			  if (mainRef.myBall2 != null){
				  mainRef.myBall2.countHit = 0;
			  }
			}
			shortTimer.reset();
			shortTimer.start();
			
		}
		
		//Below the invisibrick objects are made inert but are kept in place
		public function setInert(){
			if (brickID == "red"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieR);
				}
				if (brickID == "blue"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieB);
				}
				if (brickID == "green"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieG);
				}
				if (brickID == "power"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieP);
				}
				if (brickID == "block"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieBlock);
				}
				deathTimer.stop();
				deathTimer.reset();
				deathTimer.removeEventListener(TimerEvent.TIMER, deathStart);
				deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, death);
				//this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				//ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct);
				ball.bricksDestroyed += 1;
				
				//below finishes making object inert
				this.height = 0;
				this.width = 0;
				this.visible = false;
				this.isActivated = false;
		}
		
		//Below the invisibrick objects are made inert and returned to origin zone
		public function setCached(){
			if (brickID == "red"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieR);
				}
				if (brickID == "blue"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieB);
				}
				if (brickID == "green"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieG);
				}
				if (brickID == "power"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieP);
				}
				if (brickID == "block"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieBlock);
				}
				deathTimer.stop();
				deathTimer.reset();
				deathTimer.removeEventListener(TimerEvent.TIMER, deathStart);
				deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, death);
				//this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				//ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct); //probably don't need this until we want the invisibrick eligible for GC
				ball.bricksDestroyed += 1;
				
				//below finishes making object inert
				this.height = 0;
				this.width = 0;
				this.scaleX 
				this.visible = false;
				this.isActivated = false;
				
				//May wish to reposition the invisibricks as a stack at 0,0 or something at this point, but shouldn't be necessary...
				this.x = 0;
				this.y = 0;
		}
		
		//Below readies this object for GC if needed
		public function setReleased(){
			if (brickID == "red"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieR);
				}
				if (brickID == "blue"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieB);
				}
				if (brickID == "green"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieG);
				}
				if (brickID == "power"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieP);
				}
				if (brickID == "block"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieBlock);
				}
				deathTimer.stop();
				deathTimer.reset();
				deathTimer.removeEventListener(TimerEvent.TIMER, deathStart);
				deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, death);
				//this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct); //here we definitely want to remove the 'wire' to startButton
				ball.bricksDestroyed += 1;
				
				//below finishes making object inert
				this.height = 0;
				this.width = 0;
				this.visible = false;
				this.isActivated = false;
				
				//below 'destroys' the object -- with invisibrick, we don't want that
				if (this.parent != null) {
					this.parent.removeChild(this); //does this null out the reference? better check... seems it does, yes
				}
				
		}
		
		
		//Death functions will be changed to make the object inert rather than eligible for GC
		
		public function selfDestruct3(){ //need waitToDie methods for each brick type.  So far have waitToDieR...
			//first needs to establish which type of brick we're looking at so it can kill appropriate listeners etc.
				if (brickID == "red"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieR);
				}
				if (brickID == "blue"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieB);
				}
				if (brickID == "green"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieG);
				}
				if (brickID == "power"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieP);
				}
				if (brickID == "block"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieBlock);
				}
				deathTimer.stop();
				deathTimer.reset();
				deathTimer.removeEventListener(TimerEvent.TIMER, deathStart);
				deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, death);
				//this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct);
				ball.bricksDestroyed += 1;
				
				//below finishes making object inert
				this.height = 0;
				this.width = 0;
				this.visible = false;
				
				//below 'destroys' the object -- with invisibrick, we don't want that
				/*
				if (this.parent != null) {
					this.parent.removeChild(this);
				}
				*/
		}
		
		public function selfDestruct2(){
			if (ball.killAll == 1){
				ball.rebuild = false;
				deathTimer.stop();
				deathTimer.reset();
				deathTimer.removeEventListener(TimerEvent.TIMER, deathStart);
				deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, death);
				if (brickID == "red"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieR);
				}
				if (brickID == "blue"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieB);
				}
				if (brickID == "green"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieG);
				}
				if (brickID == "power"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieP);
				}
				if (brickID == "block"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieBlock);
				}
				ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct)
				ball.bricksDestroyed += 1;
				//trace("bricks destroyed: " + ball.bricksDestroyed);
				//below finishes making object inert
				this.height = 0;
				this.width = 0;
				this.visible = false;
				
				//below 'destroys' the object -- with invisibrick, we don't want that
				/*
				if (this.parent != null) {
					this.parent.removeChild(this);
				}
				*/
				//below would repopulate level with brick objects -- don't want this
				/*
				if (ball.bricksDestroyed == lvlCode.length && bricksHandle.numChildren == 0){
					bricksHandle.makeLvl();
				}
				*/
				if (ball.bricksDestroyed == lvlCode.length && bricksHandle.numChildren == 0){
					bricksHandle.gnuMakeLvl();
				}
				
				
			}
		}
		
		public function selfDestruct(event:MouseEvent){
			if (ball.killAll == 1){
				
				if (brickID == "red"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieR);
				}
				if (brickID == "blue"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieB);
				}
				if (brickID == "green"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieG);
				}
				if (brickID == "power"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieP);
				}
				if (brickID == "block"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieBlock);
				}
				//ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct)
				//ball.bricksDestroyed += 1;
				//trace("bricks destroyed: " + ball.bricksDestroyed);
				this.setInert();
				
				/* below is the old way...
				if (this.parent != null) {
					//trace("removal");
					this.parent.removeChild(this);
				}
				if (ball.bricksDestroyed == lvlCode.length && bricksHandle.numChildren == 0){
					//trace("got to makelvl in selfestruct");
					bricksHandle.makeLvl();
				}
				*/
			}
		}
		
		 public function showExplosion()
    	{
     
     	 	//bitmap = new Image1();
			//bitmap = this.bitmap;
      		///this.cacheAsBitmap = true;
			////this.bitmapData = this.bitmapData;
      		emitter = new Emitter2D();
			renderer = new DisplayObjectRenderer();
      		addChild( renderer );
	  		///////var particles:Particle2D = Particle2DUtils.createParticle2DFromDisplayObject(this, renderer, emitter.particleFactory);
      		renderer.addEmitter( emitter );
			emitter.counter = new Blast(20);
			emitter.addInitializer( new ImageClass( RadialDot, 10 ) );
			
			//emitter.addInitializer( new SharedImage( new Dot( 2 ) ) );
			emitter.addInitializer( new ColorInit( 0x00D20000, 0xFFFF6600 ) );
			//emitter.addInitializer( new Velocity( new DiscZone( new Point( 0, 0 ), 100, 20 ) ) );
      		//emitter.addInitializer( new Lifetime( 1 ) );
			emitter.addInitializer( new Velocity( new PointZone( new Point( 0, 65 ) ) ) );
			
	  		var p:Point = renderer.globalToLocal( new Point( (this.x + this.width/2), (this.y + this.height/2)) );
      		emitter.addAction( new Explosion( 8, p.x, p.y, 500 ) );

			emitter.addAction( new Move() );

			emitter.start();
			deathTimer.start();
     	 	
    	}
		public function deathStart(event:TimerEvent){
			if (ball.punchPower){
				trace("hello");
				ball.hitControl = 0;
				if (mainRef.myBall2 != null){
					mainRef.myBall2.hitControl = 0;
				}
			}
			if (brickID == "red"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieR);
				}
				if (brickID == "blue"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieB);
				}
				if (brickID == "green"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieG);
				}
				if (brickID == "power"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieP);
				}
				if (brickID == "block"){
				  this.removeEventListener(Event.ENTER_FRAME, waitToDieBlock);
				}
		}
		
		public function death(event:TimerEvent){
			if (ball.killAll == 0){
				ball.hitControl = 0;
				if (mainRef.myBall2 != null){
					mainRef.myBall2.hitControl = 0;
				}
				////if (!mainRef.isPaused){
			//ball.ex = new Explode(xCoord,yCoord,myColor);
			//ball.addChild(ball.ex); //problem is deifnitely with the fact that the parent this is removed almost instantly
			ball.ex.showExplosion(xCoord,yCoord,myColor);
			
			//ball.bricksDestroyed += 1;
			//trace("bricks destroyed " + ball.bricksDestroyed);
			//ball.hitControl = 0;
			if (brickID == "power"){
				ball.power = new powerUp(this.myPaddle,this.myBall,this.ball,this.evilPaddle,this.startButton,this.xCoord,this.yCoord,this.lvlCode,this.bricksHandle,this.stageRef,this.mainRef);
				ball.addChild(ball.power);
			}
			
			deathTimer.reset();
			this.setInert(); //new way
			//this.parent.removeChild(this); //old way
			
			//we wire each invisibrick object to the startbutton awaiting
			//a click.  When click is received, it sends selfDestruct signal
			//to each invisibrick object to process on itself.
			//Thus it is desirable to have each existing invisibrick hook an 
			//eventlistener to ball.startButton 
			//Question is: should we later remove them or leave them hooked up with the new cache and 'release' architecture?
			//ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct) //Answer is: Probably do not remove wires until it is desireable for invisibrick to be eligible for GC
			
			}
		}
		
		public function returnARGB(rgb:uint, newAlpha:uint):uint{
  			//newAlpha has to be in the 0 to 255 range
  			var argb:uint = 0;
  			argb += (newAlpha<<24);
  			argb += (rgb);
  			return argb;
		}
		
		//ACTIVATE
		public function activateBrick(brickColor:String){
			/*
			if (!bricksHandle.getIsInit()){ //should only run AFTER the first activation
				this.width = 55; //requires actual rendering of some sort before sizes can be set explicitly like this.. see drawRect below
				this.height = 15;
				//trace("height,width after set: " + this.height + "," + this.width);
			}
			*/
			shortTimer.start();
			shortTimer.addEventListener(TimerEvent.TIMER_COMPLETE, tickDone); //I believe this may be related to issue FR #1 -- what exactly is the function of ball.countHit?
			deathTimer.addEventListener(TimerEvent.TIMER, deathStart);        //also, what EXACTLY does ball.hitControl do?
			deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, death);
			setStarHit();
			addButtonWiredEvent(); //readies for on-demand selfDestruct calls
			//SPECIFY BRICK to 'become a brick type'
			//Also need to specify size and graphic for the given brick 
			//here or in the various waitToDieX methods
			if (brickColor == "red"){
				brickID = "red"; //very first thing to happen is the brick ID gets set.  Afetr that's done the common functions will know what to do with this brick
			    /*
			    x,y origin of the rectangles should be based on the layout positioning
			    calculations we have in Bricks, which should be kept as global vars which
			    get flushed to init values every time a level is destroyed and/or needs to be remade
			    */
				//if (bricksHandle.getIsInit()){
					
			      this.graphics.beginFill(0x11ff0000);
				  //matrix = new BitmapData(25,25);
			      //matrix.draw(this.mainRef.getPowerFire());
				  //this.graphics.beginBitmapFill(matrix,null,false,false);
			      this.graphics.drawRect(0,0,55,15);
			      this.graphics.endFill();
				  
				 // trace("height,width after drawrect: " + this.height + "," + this.width);
				//}
				//finally add the onEnterFrame callback listener
				this.addEventListener(Event.ENTER_FRAME, waitToDieR);
			}
			if (brickColor == "blue"){
				brickID = "blue"; //very first thing to happen is the brick ID gets set.  Afetr that's done the common functions will know what to do with this brick
				/*
			    x,y origin of the rectangles should be based on the layout positioning
			    calculations we have in Bricks, which should be kept as global vars which
			    get flushed to init values every time a level is destroyed and/or needs to be remade
			    */
				if (bricksHandle.getIsInit()){
			    this.graphics.beginFill(0x000000ff);
			    this.graphics.drawRect(0,0,55,15);
			    this.graphics.endFill();
				}
				
				//finally add the onEnterFrame callback listener
				this.addEventListener(Event.ENTER_FRAME, waitToDieB);
			}
			if (brickColor == "green"){
				brickID = "green"; //very first thing to happen is the brick ID gets set.  Afetr that's done the common functions will know what to do with this brick
				 /*
			    x,y origin of the rectangles should be based on the layout positioning
			    calculations we have in Bricks, which should be kept as global vars which
			    get flushed to init values every time a level is destroyed and/or needs to be remade
			    */
				if (bricksHandle.getIsInit()){
			    this.graphics.beginFill(0x0000ff00);
			    this.graphics.drawRect(0,0,55,15);
			    this.graphics.endFill();
				}
				
				//finally add the onEnterFrame callback listener
				this.addEventListener(Event.ENTER_FRAME, waitToDieG);
			}
			if (brickColor == "power"){
				brickID = "power"; //very first thing to happen is the brick ID gets set.  Afetr that's done the common functions will know what to do with this brick
				 /*
			    x,y origin of the rectangles should be based on the layout positioning
			    calculations we have in Bricks, which should be kept as global vars which
			    get flushed to init values every time a level is destroyed and/or needs to be remade
			    */
				if (bricksHandle.getIsInit()){
			    this.graphics.beginFill(0x0000ff00);
			    this.graphics.drawRect(0,0,55,15);
			    this.graphics.endFill();
				}
				
				//finally add the onEnterFrame callback listener
				this.addEventListener(Event.ENTER_FRAME, waitToDieP);
			}
			if (brickColor == "block"){
				brickID = "block"; //very first thing to happen is the brick ID gets set.  Afetr that's done the common functions will know what to do with this brick
				 /*
			    x,y origin of the rectangles should be based on the layout positioning
			    calculations we have in Bricks, which should be kept as global vars which
			    get flushed to init values every time a level is destroyed and/or needs to be remade
			    */
				if (bricksHandle.getIsInit()){
			    this.graphics.beginFill(0x00000000);
			    this.graphics.drawRect(0,0,55,15);
			    this.graphics.endFill();
				}
				
				//finally add the onEnterFrame callback listener
				this.addEventListener(Event.ENTER_FRAME, waitToDieBlock);
			}
			
			//If coming from inert, need to set visible
			if (!this.visible){
				this.visible = true;
			}
			
			//set boolean state controls
			//this.isInit = false;
			bricksHandle.setIsInit(false);
			this.isActivated = true;
			
									
		}
		
		public function getBrickID():String{
			return this.brickID;
		}
		public function getActivatedState():Boolean{
			return this.isActivated;
		}
		
		//Specialized functions for each brick type follow...
		
		//BECOME A RED BRICK
		
		public function waitToDieR(event:Event){
			/*this only needs to be done once, on activation, so shouldn't happen in an event callback (especially a common one like onEnterFrame)
			brickID = "red"; //very first thing to happen is the brick ID gets set.  Afetr that's done the common functions will know what to do with this brick
			
			//x,y origin of the rectangles should be based on the layout positioning
			//calculations we have in Bricks, which should be kept as global vars which
			//get flushed to init values every time a level is destroyed and/or needs to be remade
			
			this.graphics.beginFill(0xff00ff);
			this.graphics.drawRect(0,0,55,15);
			this.graphics.endFill();
			*/
			if (ball.killAll == 1){
				selfDestruct2();
			}
			if (this.hitTestObject(evilSight)){
				ePaddle.checkSight("red",xCoord,yCoord);
			}
			if (mainRef.myBall2 != null){ //START 1 if ball2 exists ...in the case that ball2 exists...
			if (startButton.visible == false){//START 2 if !startbutton.visible 
			if (mainRef.numStars > 0){//START 3 if numstars > 0
			if (mainRef.starsArray[starHit] != null){//START 4 if starsarray index is non-null
			//if (ball.getChildAt(ball.numChildren-1).name == "ninjaStars"){
			//Hit by ^^%^&^$ everything...
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit]) && this.hitTestObject(mainRef.myBall2)){//START 5 hittestobject: all
				//if (!ball.punchPower){
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){//START 6 if either hitControl == 0
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){//START 7 if !punchpower
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){//START 8 if either counthit == 0
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }//END 6
			}//END 5
			
			//if hit by myball and a ninja star only
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(mainRef.myBall2)){//START 5 hittestobject: myball and ninjastar
				//if (!ball.punchPower){
				if (ball.hitControl == 0){//START 6 if either hitControl == 0
				 ball.hitControl = 1;
				// mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){//START 7 if !punchpower
				if (ball.countHit == 0){//START 8 if either counthit == 0
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				//mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				//mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				if (ball.control == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (ball.control == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }//END 6
			}//END 5
			
			//if hit by myball2 and a ninja star only
			if (this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(myBall)){//START 5 hittestobject: myball and ninjastar
				//if (!ball.punchPower){
				if (mainRef.myBall2.hitControl == 0){//START 6 if either hitControl == 0
				 //ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){//START 7 if !punchpower
				if (mainRef.myBall2.countHit == 0){//START 8 if either counthit == 0
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				mainRef.myBall2.ballYSpeed *= -1;
				//mainRef.myBall2.ballYSpeed *= -1;
				////}
				mainRef.myBall2.countHit++;
				//mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				if (mainRef.myBall2.control2 == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (mainRef.myBall2.control2 == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }//END 6
			}//END 5
			
			//Hit by just a ninja star...
			if (this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(myBall) && !this.hitTestObject(mainRef.myBall2)){//START 16
				trace("hey!!!!!!!RED");
				if (!mainRef.isPaused){//START 17
				//myPaddle.width += 5;
				//evilPaddle.width -= 5;
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 17
			}//END 16
			
			}//END 4 //should close if starsarray index != null

			
			//Hit by both balls but not a ninja star
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.myBall2)){
				//if (!ball.punchPower){
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}
				}
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			} 
			
			//
			////if (this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit])){
			//
			// moved up...
			
			//Hit by just a ninja star...
			if (this.hitTestObject(mainRef.starsArray[starHit])){
				trace("hey!!!!!!!RED");
				if (!mainRef.isPaused){
				//myPaddle.width += 5;
				//evilPaddle.width -= 5;
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
			}
			

			}//END 3, so no more ninja star possibility after here
			
			//Hit by both balls 
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.myBall2)){
				//if (!ball.punchPower){
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}
				}
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			} 
			
			//Hit by myBall only...
			if (this.hitTestObject(myBall)){// || this.hitTestObject(mainRef.myBall2)){ //these should split up for the purpose of redirecting balls distinctly
				if (ball.punchPower){
				 if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  //}
			  //}
			 }
			 if (!ball.punchPower){
			  if (ball.hitControl == 0){
				 ball.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (ball.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				////}
				ball.countHit++;
				
				}
			    }
			  ////}
			 ////}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			}
			}
			//somewhere in her insert the case where brick is hit by only ball2...
			if (this.hitTestObject(mainRef.myBall2)){// || this.hitTestObject(mainRef.myBall2)){ //these should split up for the purpose of redirecting balls distinctly
				if (ball.punchPower){
				 if (mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  //}
			  //}
			 }
			 if (!ball.punchPower){
			  if (mainRef.myBall2.hitControl == 0){
				 mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (mainRef.myBall2.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				
				////if (!ball.punchPower){
				mainRef.myBall2.ballYSpeed *= -1;
				////}
				mainRef.myBall2.countHit++;
				
				}
			    }
			  ////}
			 ////}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				if (mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			}
			}
			
			} //should close if startbutton is false
		   } //should close if ball2 exists
		   else{//begisn case where ball2 is not present
			   if (startButton.visible == false){
			if (mainRef.numStars > 0){
			if (mainRef.starsArray[starHit] != null){
			//if (ball.getChildAt(ball.numChildren-1).name == "ninjaStars"){
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit])){ // || this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit])){
				//if (!ball.punchPower){
				if (ball.hitControl == 0){
				 ball.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (ball.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				////}
				ball.countHit++;
				
				}
				}
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			}
			if (this.hitTestObject(mainRef.starsArray[starHit])){
				trace("hey!!!!!!!RED");
				if (!mainRef.isPaused){
				//myPaddle.width += 5;
				//evilPaddle.width -= 5;
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
			}
			}
			}
			if (this.hitTestObject(myBall)){
				if (ball.punchPower){
				 if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  //}
			  //}
			 }
			 if (!ball.punchPower){
			  if (ball.hitControl == 0){
				 ball.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (ball.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				////}
				ball.countHit++;
				
				}
			    }
			  ////}
			 ////}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			}
			}
			}
		   
		   }

		

	} //Should be the END OF waitToDieR
	
	//BECOME A Green BRICK
		
		public function waitToDieG(event:Event){
			
			if (ball.killAll == 1){
				selfDestruct2();
			}
			if (this.hitTestObject(evilSight)){
				ePaddle.checkSight("green",xCoord,yCoord);
			}
			if (mainRef.myBall2 != null){ //START 1 if ball2 exists ...in the case that ball2 exists...
			if (startButton.visible == false){//START 2 if !startbutton.visible 
			if (mainRef.numStars > 0){//START 3 if numstars > 0
			if (mainRef.starsArray[starHit] != null){//START 4 if starsarray index is non-null
			
			//Hit by ^^%^&^$ everything...
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit]) && this.hitTestObject(mainRef.myBall2)){//START 5 hittestobject: all
				
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){//START 6 if either hitControl == 0
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){//START 7 if !punchpower
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){//START 8 if either counthit == 0
					
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				
			  }//END 6
			}//END 5
			
			//if hit by myball and a ninja star only
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(mainRef.myBall2)){//START 5 hittestobject: myball and ninjastar
				
				if (ball.hitControl == 0){//START 6 if either hitControl == 0
				 ball.hitControl = 1;
				
				if (!ball.punchPower){//START 7 if !punchpower
				if (ball.countHit == 0){//START 8 if either counthit == 0
					
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				
				if (ball.control == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (ball.control == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				
			  }//END 6
			}//END 5
			
			//if hit by myball2 and a ninja star only
			if (this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(myBall)){//START 5 hittestobject: myball and ninjastar
				
				if (mainRef.myBall2.hitControl == 0){//START 6 if either hitControl == 0
				
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){//START 7 if !punchpower
				if (mainRef.myBall2.countHit == 0){//START 8 if either counthit == 0
					
				mainRef.myBall2.ballYSpeed *= -1;
				
				mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				
				if (mainRef.myBall2.control2 == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (mainRef.myBall2.control2 == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				
			  }//END 6
			}//END 5
			
			//Hit by just a ninja star...
			if (this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(myBall) && !this.hitTestObject(mainRef.myBall2)){//START 16
				trace("hey!!!!!!!Green");
				if (!mainRef.isPaused){//START 17
				
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 17
			}//END 16
			
			}//END 4 //should close if starsarray index != null

			
			//Hit by both balls but not a ninja star
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.myBall2)){
				
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){
					
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}
				}
				
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				
				}
				
			  }
			} 
			
			//Hit by just a ninja star...
			if (this.hitTestObject(mainRef.starsArray[starHit])){
				trace("hey!!!!!!!Green");
				if (!mainRef.isPaused){
				
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
			}
			

			}//END 3, so no more ninja star possibility after here
			
			//Hit by both balls 
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.myBall2)){
				
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){
					
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}
				}
				
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				
				}
				
			  }
			} 
			
			//Hit by myBall only...
			if (this.hitTestObject(myBall)){// || this.hitTestObject(mainRef.myBall2)){ //these should split up for the purpose of redirecting balls distinctly
				if (ball.punchPower){
				 if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			 }
			 if (!ball.punchPower){
			  if (ball.hitControl == 0){
				 ball.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0){
					
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}
			    }
			 
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			  }
			}
			}
			//somewhere in her insert the case where brick is hit by only ball2...
			if (this.hitTestObject(mainRef.myBall2)){// || this.hitTestObject(mainRef.myBall2)){ //these should split up for the purpose of redirecting balls distinctly
				if (ball.punchPower){
				 if (mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			 }
			 if (!ball.punchPower){
			  if (mainRef.myBall2.hitControl == 0){
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){
				if (mainRef.myBall2.countHit == 0){
					
				mainRef.myBall2.ballYSpeed *= -1;
				
				mainRef.myBall2.countHit++;
				
				}
			    }
			  
				if (mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			  }
			}
			}
			
			} //should close if startbutton is false
		   } //should close if ball2 exists
		   else{//begisn case where ball2 is not present
			   if (startButton.visible == false){
			if (mainRef.numStars > 0){
			if (mainRef.starsArray[starHit] != null){
			
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit])){ // || this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit])){
				
				if (ball.hitControl == 0){
				 ball.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0){
					
					
				
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}
				}
				
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
				
			  }
			}
			if (this.hitTestObject(mainRef.starsArray[starHit])){
				trace("hey!!!!!!!Green");
				if (!mainRef.isPaused){
				
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
			}
			}
			}
			if (this.hitTestObject(myBall)){
				if (ball.punchPower){
				 if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			 }
			 if (!ball.punchPower){
			  if (ball.hitControl == 0){
				 ball.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0){
					
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}
			    }
			 
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			  }
			}
			}
			}
		   
		   }

		

	}//should be the end of waitToDieG
	
	//BECOME A Blue BRICK
		
		public function waitToDieB(event:Event){
			
			if (ball.killAll == 1){
				selfDestruct2();
			}
			if (this.hitTestObject(evilSight)){
				ePaddle.checkSight("blue",xCoord,yCoord);
			}
			if (mainRef.myBall2 != null){ //START 1 if ball2 exists ...in the case that ball2 exists...
			if (startButton.visible == false){//START 2 if !startbutton.visible 
			if (mainRef.numStars > 0){//START 3 if numstars > 0
			if (mainRef.starsArray[starHit] != null){//START 4 if starsarray index is non-null
			
			//Hit by ^^%^&^$ everything...
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit]) && this.hitTestObject(mainRef.myBall2)){//START 5 hittestobject: all
				
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){//START 6 if either hitControl == 0
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){//START 7 if !punchpower
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){//START 8 if either counthit == 0
					
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				
			  }//END 6
			}//END 5
			
			//if hit by myball and a ninja star only
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(mainRef.myBall2)){//START 5 hittestobject: myball and ninjastar
				
				if (ball.hitControl == 0){//START 6 if either hitControl == 0
				 ball.hitControl = 1;
				
				if (!ball.punchPower){//START 7 if !punchpower
				if (ball.countHit == 0){//START 8 if either counthit == 0
					
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				
				if (ball.control == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (ball.control == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				
			  }//END 6
			}//END 5
			
			//if hit by myball2 and a ninja star only
			if (this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(myBall)){//START 5 hittestobject: myball and ninjastar
				
				if (mainRef.myBall2.hitControl == 0){//START 6 if either hitControl == 0
				
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){//START 7 if !punchpower
				if (mainRef.myBall2.countHit == 0){//START 8 if either counthit == 0
					
				mainRef.myBall2.ballYSpeed *= -1;
				
				mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				
				if (mainRef.myBall2.control2 == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (mainRef.myBall2.control2 == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				
			  }//END 6
			}//END 5
			
			//Hit by just a ninja star...
			if (this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(myBall) && !this.hitTestObject(mainRef.myBall2)){//START 16
				trace("hey!!!!!!!blue");
				if (!mainRef.isPaused){//START 17
				
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 17
			}//END 16
			
			}//END 4 //should close if starsarray index != null

			
			//Hit by both balls but not a ninja star
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.myBall2)){
				
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){
					
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}
				}
				
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				
				}
				
			  }
			} 
			
			//Hit by just a ninja star...
			if (this.hitTestObject(mainRef.starsArray[starHit])){
				trace("hey!!!!!!!blue");
				if (!mainRef.isPaused){
				
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
			}
			

			}//END 3, so no more ninja star possibility after here
			
			//Hit by both balls 
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.myBall2)){
				
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){
					
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}
				}
				
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				
				}
				
			  }
			} 
			
			//Hit by myBall only...
			if (this.hitTestObject(myBall)){// || this.hitTestObject(mainRef.myBall2)){ //these should split up for the purpose of redirecting balls distinctly
				if (ball.punchPower){
				 if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			 }
			 if (!ball.punchPower){
			  if (ball.hitControl == 0){
				 ball.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0){
					
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}
			    }
			 
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			  }
			}
			}
			//somewhere in her insert the case where brick is hit by only ball2...
			if (this.hitTestObject(mainRef.myBall2)){// || this.hitTestObject(mainRef.myBall2)){ //these should split up for the purpose of redirecting balls distinctly
				if (ball.punchPower){
				 if (mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			 }
			 if (!ball.punchPower){
			  if (mainRef.myBall2.hitControl == 0){
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){
				if (mainRef.myBall2.countHit == 0){
					
				mainRef.myBall2.ballYSpeed *= -1;
				
				mainRef.myBall2.countHit++;
				
				}
			    }
			  
				if (mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}

				if (mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			  }
			}
			}
			
			} //should close if startbutton is false
		   } //should close if ball2 exists
		   else{//begisn case where ball2 is not present
			   if (startButton.visible == false){
			if (mainRef.numStars > 0){
			if (mainRef.starsArray[starHit] != null){
			
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit])){ // || this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit])){
				
				if (ball.hitControl == 0){
				 ball.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0){
					
					
				
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}
				}
				
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
				
			  }
			}
			if (this.hitTestObject(mainRef.starsArray[starHit])){
				trace("hey!!!!!!!blue");
				if (!mainRef.isPaused){
				
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
			}
			}
			}
			if (this.hitTestObject(myBall)){
				if (ball.punchPower){
				 if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			 }
			 if (!ball.punchPower){
			  if (ball.hitControl == 0){
				 ball.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0){
					
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}
			    }
			 
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			  }
			}
			}
			}
		   
		   }

		

	}//should be the end of waitToDieB
	
	//BECOME A power BRICK
		
		public function waitToDieP(event:Event){
			
			if (ball.killAll == 1){
				selfDestruct2();
			}
			if (this.hitTestObject(evilSight)){
				ePaddle.checkSight("power",xCoord,yCoord);
			}
			if (mainRef.myBall2 != null){ //START 1 if ball2 exists ...in the case that ball2 exists...
			if (startButton.visible == false){//START 2 if !startbutton.visible 
			if (mainRef.numStars > 0){//START 3 if numstars > 0
			if (mainRef.starsArray[starHit] != null){//START 4 if starsarray index is non-null
			
			//Hit by ^^%^&^$ everything...
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit]) && this.hitTestObject(mainRef.myBall2)){//START 5 hittestobject: all
				
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){//START 6 if either hitControl == 0
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){//START 7 if !punchpower
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){//START 8 if either counthit == 0
					
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				
			  }//END 6
			}//END 5
			
			//if hit by myball and a ninja star only
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(mainRef.myBall2)){//START 5 hittestobject: myball and ninjastar
				
				if (ball.hitControl == 0){//START 6 if either hitControl == 0
				 ball.hitControl = 1;
				
				if (!ball.punchPower){//START 7 if !punchpower
				if (ball.countHit == 0){//START 8 if either counthit == 0
					
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				
				if (ball.control == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (ball.control == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				
			  }//END 6
			}//END 5
			
			//if hit by myball2 and a ninja star only
			if (this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(myBall)){//START 5 hittestobject: myball and ninjastar
				
				if (mainRef.myBall2.hitControl == 0){//START 6 if either hitControl == 0
				
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){//START 7 if !punchpower
				if (mainRef.myBall2.countHit == 0){//START 8 if either counthit == 0
					
				mainRef.myBall2.ballYSpeed *= -1;
				
				mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				
				if (mainRef.myBall2.control2 == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (mainRef.myBall2.control2 == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				
				if (!mainRef.isPaused){//START 15 
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				
			  }//END 6
			}//END 5
			
			//Hit by just a ninja star...
			if (this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(myBall) && !this.hitTestObject(mainRef.myBall2)){//START 16
				trace("hey!!!!!!!power");
				if (!mainRef.isPaused){//START 17
				
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 17
			}//END 16
			
			}//END 4 //should close if starsarray index != null

			
			//Hit by both balls but not a ninja star
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.myBall2)){
				
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){
					
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}
				}
				
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				
				}
				
			  }
			} 
			
			//Hit by just a ninja star...
			if (this.hitTestObject(mainRef.starsArray[starHit])){
				trace("hey!!!!!!!power");
				if (!mainRef.isPaused){
				
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
			}
			

			}//END 3, so no more ninja star possibility after here
			
			//Hit by both balls 
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.myBall2)){
				
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){
					
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}
				}
				
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				
				}
				
			  }
			} 
			
			//Hit by myBall only...
			if (this.hitTestObject(myBall)){// || this.hitTestObject(mainRef.myBall2)){ //these should split up for the purpose of redirecting balls distinctly
				if (ball.punchPower){
				 if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			 }
			 if (!ball.punchPower){
			  if (ball.hitControl == 0){
				 ball.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0){
					
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}
			    }
			 
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			  }
			}
			}
			//somewhere in her insert the case where brick is hit by only ball2...
			if (this.hitTestObject(mainRef.myBall2)){// || this.hitTestObject(mainRef.myBall2)){ //these should split up for the purpose of redirecting balls distinctly
				if (ball.punchPower){
				 if (mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			 }
			 if (!ball.punchPower){
			  if (mainRef.myBall2.hitControl == 0){
				 mainRef.myBall2.hitControl = 1;
				
				if (!ball.punchPower){
				if (mainRef.myBall2.countHit == 0){
					
				mainRef.myBall2.ballYSpeed *= -1;
				
				mainRef.myBall2.countHit++;
				
				}
			    }
			  
				if (mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			  }
			}
			}
			
			} //should close if startbutton is false
		   } //should close if ball2 exists
		   else{//begisn case where ball2 is not present
			   if (startButton.visible == false){
			if (mainRef.numStars > 0){
			if (mainRef.starsArray[starHit] != null){
			
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit])){ // || this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit])){
				
				if (ball.hitControl == 0){
				 ball.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0){
					
					
				
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}
				}
				
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
				
			  }
			}
			if (this.hitTestObject(mainRef.starsArray[starHit])){
				trace("hey!!!!!!!power");
				if (!mainRef.isPaused){
				
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
			}
			}
			}
			if (this.hitTestObject(myBall)){
				if (ball.punchPower){
				 if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			 }
			 if (!ball.punchPower){
			  if (ball.hitControl == 0){
				 ball.hitControl = 1;
				
				if (!ball.punchPower){
				if (ball.countHit == 0){
					
				ball.ballYSpeed *= -1;
				
				ball.countHit++;
				
				}
			    }
			 
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				}
				
			  }
			}
			}
			}
		   
		   }

		

	}//should be the end of waitToDieP
	
	//BECOME A Block BRICK
		
		public function waitToDieBlock(event:Event){
			
			if (ball.killAll == 1){
				selfDestruct2();
			}
			if (this.hitTestObject(evilSight)){
				ePaddle.checkSight("block",xCoord,yCoord);
			}
			if (mainRef.myBall2 != null){ //START 1 if ball2 exists ...in the case that ball2 exists...
			if (startButton.visible == false){//START 2 if !startbutton.visible 
			if (mainRef.numStars > 0){//START 3 if numstars > 0
			if (mainRef.starsArray[starHit] != null){//START 4 if starsarray index is non-null
			
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit]) && this.hitTestObject(mainRef.myBall2)){//START 5 hittestobject: all
				//if (!ball.punchPower){
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){//START 6 if either hitControl == 0
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){//START 7 if !punchpower
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){//START 8 if either counthit == 0
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				/* we don't want block brick hits to resize either paddle
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..

					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				
				if (!mainRef.isPaused){//START 15 
				 if (ball.punchPower){
					deathTimer.reset(); //we don't want the block brick to die in the normal circumstance
					deathTimer.start(); //only if punchpower is on.
				 }
				 if (!ball.punchPower){
						ball.hitControl = 0; //necessary to restore hit listening fucntion to other bricks, as this is usually done in the death method, but block doe3sn't normally die...
					}
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }//END 6
			}//END 5
			
			//if hit by myball and a ninja star only
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(mainRef.myBall2)){//START 5 hittestobject: myball and ninjastar
				//if (!ball.punchPower){
				if (ball.hitControl == 0){//START 6 if either hitControl == 0
				 ball.hitControl = 1;
				// mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){//START 7 if !punchpower
				if (ball.countHit == 0){//START 8 if either counthit == 0
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				//mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				//mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				/*
				if (ball.control == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (ball.control == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				
				if (!mainRef.isPaused){//START 15 
				if (ball.punchPower){
					deathTimer.reset(); //we don't want the block brick to die in the normal circumstance
					deathTimer.start(); //only if punchpower is on.
				 }
				 if (!ball.punchPower){
						ball.hitControl = 0; //necessary to restore hit listening fucntion to other bricks, as this is usually done in the death method, but block doe3sn't normally die...
					}
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }//END 6
			}//END 5
			
			//if hit by myball2 and a ninja star only
			if (this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(myBall)){//START 5 hittestobject: myball and ninjastar
				//if (!ball.punchPower){
				if (mainRef.myBall2.hitControl == 0){//START 6 if either hitControl == 0
				 //ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){//START 7 if !punchpower
				if (mainRef.myBall2.countHit == 0){//START 8 if either counthit == 0
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				mainRef.myBall2.ballYSpeed *= -1;
				//mainRef.myBall2.ballYSpeed *= -1;
				////}
				mainRef.myBall2.countHit++;
				//mainRef.myBall2.countHit++;
				
				}//END 8 if either counhit == 0
				}//END 7 if !punchpower
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				/*
				if (mainRef.myBall2.control2 == 1){//START 9 if either control == 1
					if (myPaddle.width <= 235){//START 10 if mypaddlewidth...
					myPaddle.width += 5;
					}//END 10 if mypaddle width...
					if (evilPaddle.width >= 25){//START 11 if evilpaddlewidth...
					evilPaddle.width -= 5;
					}//END 11 if evilpaddlewidth...
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 9 if either control == 1
				if (mainRef.myBall2.control2 == 2){//START 12 if either control == 2
					if (myPaddle.width >= 25){//START 13 if mypaddlewidth...
					myPaddle.width -= 5;
					}//END 13 if mypaddle width..
					if (evilPaddle.width <= 235){//START 14 if evilpaddlewidth...
					evilPaddle.width += 5;
					}//END 14 if evilpaddlewidth..
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}//END 12 if either control == 2
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				
				if (!mainRef.isPaused){//START 15 
				if (ball.punchPower){
					deathTimer.reset(); //we don't want the block brick to die in the normal circumstance
					deathTimer.start(); //only if punchpower is on.
				 }
				 if (!ball.punchPower){
						ball.hitControl = 0; //necessary to restore hit listening fucntion to other bricks, as this is usually done in the death method, but block doe3sn't normally die...
					}
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 15
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }//END 6
			}//END 5
			
			//Hit by just a ninja star...
			if (this.hitTestObject(mainRef.starsArray[starHit]) && !this.hitTestObject(myBall) && !this.hitTestObject(mainRef.myBall2)){//START 16
				trace("hey!!!!!!!block");
				if (!mainRef.isPaused){//START 17
				//myPaddle.width += 5;
				//evilPaddle.width -= 5;
				//deathTimer.reset(); //no case in which ninja star should kill a block brick
				//deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}//END 17
			}//END 16
			
			}//END 4 //should close if starsarray index != null
			/*
			//Hit by both balls but not a ninja star
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.myBall2)){
				//if (!ball.punchPower){
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}
				}
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			} 
			*/
			//
			////if (this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit])){
			//
			/* moved up...
			//Hit by just a ninja star...
			if (this.hitTestObject(mainRef.starsArray[starHit])){
				trace("hey!!!!!!!RED");
				if (!mainRef.isPaused){
				//myPaddle.width += 5;
				//evilPaddle.width -= 5;
				deathTimer.reset();
				deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
			}
			*/
			
			}//END 3, so no more ninja star possibility after here
			
			//Hit by both balls 
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.myBall2)){
				//if (!ball.punchPower){
				if (ball.hitControl == 0 || mainRef.myBall2.hitControl == 0){
				 ball.hitControl = 1;
				 mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (ball.countHit == 0 || mainRef.myBall2.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				mainRef.myBall2.ballYSpeed *= -1;
				////}
				ball.countHit++;
				mainRef.myBall2.countHit++;
				
				}
				}
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				/*
				if (ball.control == 1 || mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2 || mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				if (ball.punchPower){
					deathTimer.reset(); //we don't want the block brick to die in the normal circumstance
					deathTimer.start(); //only if punchpower is on.
				 }
				if (!ball.punchPower){
						ball.hitControl = 0; //necessary to restore hit listening fucntion to other bricks, as this is usually done in the death method, but block doe3sn't normally die...
					}
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			} 
			
			//Hit by myBall only...
			if (this.hitTestObject(myBall)){// || this.hitTestObject(mainRef.myBall2)){ //these should split up for the purpose of redirecting balls distinctly
				if (ball.punchPower){
					/*
				 if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset(); //already know punchpower is on here
				deathTimer.start();
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  //}
			  //}
			 }
			 if (!ball.punchPower){
			  if (ball.hitControl == 0){
				 ball.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (ball.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				////}
				ball.countHit++;
				
				}
			    }
			  ////}
			 ////}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				/*
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				if (ball.punchPower){
					deathTimer.reset(); //we don't want the block brick to die in the normal circumstance
					deathTimer.start(); //only if punchpower is on.
				 }
				 if (!ball.punchPower){
						ball.hitControl = 0; //necessary to restore hit listening fucntion to other bricks, as this is usually done in the death method, but block doe3sn't normally die...
					}
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			}
			}
			//somewhere in her insert the case where brick is hit by only ball2...
			if (this.hitTestObject(mainRef.myBall2)){// || this.hitTestObject(mainRef.myBall2)){ //these should split up for the purpose of redirecting balls distinctly
				if (ball.punchPower){
					/*
				 if (mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset(); //we know punchPower is true here
				deathTimer.start();
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  //}
			  //}
			 }
			 if (!ball.punchPower){
			  if (mainRef.myBall2.hitControl == 0){
				 mainRef.myBall2.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (mainRef.myBall2.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				
				////if (!ball.punchPower){
				mainRef.myBall2.ballYSpeed *= -1;
				////}

				mainRef.myBall2.countHit++;
				
				}
			    }
			  ////}
			 ////}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				/*
				if (mainRef.myBall2.control2 == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (mainRef.myBall2.control2 == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				if (ball.punchPower){
					deathTimer.reset(); //we don't want the block brick to die in the normal circumstance
					deathTimer.start(); //only if punchpower is on.
				 }
				 if (!ball.punchPower){
						ball.hitControl = 0; //necessary to restore hit listening fucntion to other bricks, as this is usually done in the death method, but block doe3sn't normally die...
					}
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			}
			}
			
			} //should close if startbutton is false
		   } //should close if ball2 exists
		   else{//begisn case where ball2 is not present
			   if (startButton.visible == false){
			if (mainRef.numStars > 0){
			if (mainRef.starsArray[starHit] != null){
			//if (ball.getChildAt(ball.numChildren-1).name == "ninjaStars"){
			if (this.hitTestObject(myBall) && this.hitTestObject(mainRef.starsArray[starHit])){ // || this.hitTestObject(mainRef.myBall2) && this.hitTestObject(mainRef.starsArray[starHit])){
				//if (!ball.punchPower){
				if (ball.hitControl == 0){
				 ball.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (ball.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				////}
				ball.countHit++;
				
				}
				}
				//}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				/*
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				if (ball.punchPower){
					deathTimer.reset(); //we don't want the block brick to die in the normal circumstance
					deathTimer.start(); //only if punchpower is on.
				 }
				 if (!ball.punchPower){
						ball.hitControl = 0; //necessary to restore hit listening fucntion to other bricks, as this is usually done in the death method, but block doe3sn't normally die...
					}
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			}
			if (this.hitTestObject(mainRef.starsArray[starHit])){
				trace("hey!!!!!!!block");
				if (!mainRef.isPaused){
				//myPaddle.width += 5;
				//evilPaddle.width -= 5;
				//deathTimer.reset();//in no case should the ninja stars destory a block brick
				//deathTimer.start();
				mainRef.numStars--;
				ball.removeChild(mainRef.starsArray[starHit]);
				mainRef.starsArray[starHit] = null;
				}
			}
			}
			}
			if (this.hitTestObject(myBall)){
				if (ball.punchPower){
					/*
				 if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
				deathTimer.reset(); //already know punchpower is on here so no additional controls needed
				deathTimer.start();
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  //}
			  //}
			 }
			 if (!ball.punchPower){
			  if (ball.hitControl == 0){
				 ball.hitControl = 1;
				//trace(ball.countHit);
				//trace(shortTimer.currentCount);
				//aBall.ballYSpeed *= -1; //myBall is not a Ball object; rather it is a MovieClip, and thus unaware of the ballYSpeed property...
											//need to address this, as currently ball does not bounce off of bricks.
				//ball.countHit++;
				if (!ball.punchPower){
				if (ball.countHit == 0){
					//ball.ballYSpeed *= 1;
					
				//}
				//else{
				
				////if (!ball.punchPower){
				ball.ballYSpeed *= -1;
				////}
				ball.countHit++;
				
				}
			    }
			  ////}
			 ////}
				////if (ball.hitControl == 0){
				  ////ball.hitControl = 1;
				//ball.countHit++;
				/*
				if (ball.control == 1){
					if (myPaddle.width <= 235){
					myPaddle.width += 5;
					}
					if (evilPaddle.width >= 25){
					evilPaddle.width -= 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				if (ball.control == 2){
					if (myPaddle.width >= 25){
					myPaddle.width -= 5;
					}
					if (evilPaddle.width <= 235){
					evilPaddle.width += 5;
					}
					evilSight.x = evilPaddle.x + (evilPaddle.width/2);
				}
				*/
				/////ball.bricksDestroyed += 1; //keeps track of the bricks destroyed so far-- when that number reaches the level array.length, then level is gone and regen timer starts.
				//for (i:int = 0; i <
				//ball.xLocations
				//var e:Explode = new Explode(this); //passing this reference to the brick to die into Explode keeps it from being gc'd!
				//////////showExplosion();
				////this.parent.removeChild(this);
				if (!mainRef.isPaused){
					if (ball.punchPower){
						deathTimer.reset(); //we don't want the block brick to die in the normal circumstance
						deathTimer.start(); //only if punchpower is on.
				 	}
				 	if (!ball.punchPower){
						ball.hitControl = 0; //necessary to restore hit listening fucntion to other bricks, as this is usually done in the death method, but block doe3sn't normally die...
					}
				}
				////removeEventListener(Event.ENTER_FRAME, waitToDie);
			  }
			}
			}
			}
		   
		   }
			/*
			if (this.hitTestObject(mainRef.ninjaStars)){
				if (!mainRef.isPaused){
				deathTimer.reset();
				deathTimer.start();
				mainRef.removeChild(mainRef.ninjaStars);
				}
			}
			*/
			
		//}

		

	}//should be the end of waitToDieBlock
	
	
}


}