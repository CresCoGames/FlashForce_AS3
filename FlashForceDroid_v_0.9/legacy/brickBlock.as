/*
the block brick is unique in that it does not get destroyed by any ball object UNLESS the ball has punchPower on.
It stops ninja stars and fireballs, and balls bounce off it as normal.  If punchpower is active, it can be destroyed
by either ball just as the other bricks are destroyed and traveled through in that case.

****need something to check if only brickBlocks are left at any point and if so, start the Bricks level remake stuff in motion.
best way would be to keep count of any 5 codes found in the level code when it is loaded, then have the remake level
checker check for a number of bricks destroyed from levelcodelength-brickBlockCount to levelcodelength. 

This must also then
sweep the board of any remaining brickBlocks before making the level again... sort of does this now, but then it won't actually make the level again.
*/

package  {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	import fl.controls.Button;
	import flash.geom.Point;
import org.flintparticles.common.counters.*;
import org.flintparticles.common.displayObjects.RadialDot;
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
  import fl.controls.progressBarClasses.IndeterminateBar;
	
	public class brickBlock extends MovieClip{
		private var emitter:Emitter2D;
    	//private var bitmap:Bitmap;
		private var renderer:DisplayObjectRenderer;
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
		//var myColor:int = 5;
		var myColor:int = 3;
		var bitmapData:BitmapData;
		var shortTimer:Timer = new Timer(500, 1);
		var deathTimer:Timer = new Timer(100,1);
		var rebuild:Boolean = false;
		var lvlCode:Array;
		var bricksHandle:Bricks;
		var mainRef:FlashForceMain;
		var starHit:int;
		//public var countHit:int;
		//var aBall:Ball;
		public function brickBlock(enPaddle:enemyPaddle,paddle:MovieClip,ball:MovieClip,theBall:Ball,ePaddle:MovieClip,eSight:MovieClip,startB:Button,myX:Number,myY:Number,level:Array,bricksH:Bricks,mainR:FlashForceMain){//,count:int) {
			this.ePaddle = enPaddle;
			this.myBall = ball;
			this.myPaddle = paddle;
			this.ball = theBall;
			this.evilPaddle = ePaddle;
			this.evilSight = eSight;
			this.startButton = startB;
			this.lvlCode = level;
			this.bricksHandle = bricksH;
			this.mainRef = mainR;
			xCoord = myX;
			yCoord = myY;
			
			
			//this.countHit = count;
			this.addEventListener(Event.ENTER_FRAME, waitToDie);
			//addEventListener(Event.ENTER_FRAME, screamlikeabitch);
			//ball.startButton.addEventListener(MouseEvent.CLICK, selfDestruct);
			shortTimer.start();
			shortTimer.addEventListener(TimerEvent.TIMER_COMPLETE, tickDone);
			deathTimer.addEventListener(TimerEvent.TIMER, deathStart);
			deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, death);
			setStarHit();
			addEvent();
			//selfDestructBlock();
			//aBall = new Ball(this.myPaddle,this.myBall);
			//addChild(this);
			//myRoot = MovieClip(root);
		}
		public function addEvent(){
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
		
		public function screamlikeabitch(e:Event){
			//trace(mainRef.ball2Counter + " WAAAAA");
			if (this.name != null){
				trace("exists: " + this.name);
			}
			else{
				removeEventListener(Event.ENTER_FRAME, screamlikeabitch);
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
		public function selfDestructBlock(){
				//ball.rebuild = false;
				trace("time to destroy the block");
				deathTimer.stop();
				deathTimer.reset();
				deathTimer.removeEventListener(TimerEvent.TIMER, deathStart);
				deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, death);
				this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct)
				ball.bricksDestroyed += 1;
				//trace("bricks destroyed: " + ball.bricksDestroyed);
				if (this.parent != null) {
					this.parent.removeChild(this);
					
				}
				
				//continued to report birckBlockCount for some reason when count had been made 0 by a makeLvl call on reset button hit...
		}
		
		public function selfDestruct3(){
				this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				deathTimer.stop();
				deathTimer.reset();
				deathTimer.removeEventListener(TimerEvent.TIMER, deathStart);
				deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, death);
				//this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct)
				ball.bricksDestroyed += 1;
				if (this.parent != null) {
					this.parent.removeChild(this);
				}
		}
		/*
		public function selfDestruct2(){
			if (ball.killAll == 1){
				ball.rebuild = false;
				deathTimer.stop();
				deathTimer.reset();
				deathTimer.removeEventListener(TimerEvent.TIMER, deathStart);
				deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, death);
				this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct)
				ball.bricksDestroyed += 1;
				//trace("bricks destroyed: " + ball.bricksDestroyed);
				if (this.parent != null) {
					this.parent.removeChild(this);
				}
				trace("bricks destroyed from block: " + ball.bricksDestroyed);
				trace("brci children from block: " + bricksHandle.numChildren);
				if (ball.bricksDestroyed == lvlCode.length && bricksHandle.numChildren == 0){ //this condition needs alteration so that it isn't skipped while brick blocks are in the process of being destoryed.  See frameWaiter...
					trace("ehwhat!");
					bricksHandle.makeLvl();
				}
			}
		}
		
		public function selfDestruct(event:MouseEvent){
			if (ball.killAll == 1){
				
				this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct)
				ball.bricksDestroyed += 1;
				//trace("bricks destroyed: " + ball.bricksDestroyed);
				if (this.parent != null) {
					//trace("removal");
					this.parent.removeChild(this);
				}
				if (ball.bricksDestroyed == lvlCode.length && bricksHandle.numChildren == 0){
					//trace("got to makelvl in selfestruct");
					bricksHandle.makeLvl();
				}
			}
		}
		
		*/
		public function waitToDie(event:Event){
			//trace(mainRef.ball2Counter + " WAAAAA");
			//trace("brickblockcount: " + bricksHandle.brickBlockCount);
			
			//before anything, 
			//if (this.parent == null){ //should this stay??
				//selfDestructBlock();
			//}
			if (ball.killAll == 1){ //may want to alter these so they are logically disparate eventualities
				selfDestruct2();
				
			}
			if (bricksHandle.brickBlockDie && ball.killAll == 0){
				selfDestructBlock();
			}
			if (this.hitTestObject(evilSight)){
				ePaddle.checkSight("block",xCoord,yCoord);
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
				trace("hey!!!!!!!RED");
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
				trace("hey!!!!!!!RED");
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
			emitter.addInitializer( new ImageClass( RadialDot, 2 ) );
			
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
     	 	//////emitter.addAction( new DeathZone( new RectangleZone( -5, -5, 505, 355 ), true ) );
     		//emitter.addAction( new Move() );
			////if (this.cacheAsBitmap == true){
     		////var particles:Array = Particle2DUtils.createRectangleParticlesFromBitmapData( this.bitmapData, 10, emitter.particleFactory, 56, 47 );
			///}
			//var particles:Particle2D = Particle2DUtils.createParticle2DFromDisplayObject(victim, null, emitter.particleFactory);
						//var yo:Array = Particle2DUtils.			
						
	  		////emitter.addExistingParticles( particles, false );
			
	  
	  
      
     		////renderer = new DisplayObjectRenderer();
      		////addChild( renderer );
	  		///////var particles:Particle2D = Particle2DUtils.createParticle2DFromDisplayObject(this, renderer, emitter.particleFactory);
      		////renderer.addEmitter( emitter );
      		//emitter.start();
	  
	  		////var p:Point = renderer.globalToLocal( new Point( (this.x + this.width/2), (this.y + this.height/2)) );
      		////emitter.addAction( new Explosion( 8, p.x, p.y, 500 ) );
			
			///////this.parent.removeChild(this);
				
			///////removeEventListener(Event.ENTER_FRAME, waitToDie);
	  		
      
    		//  stage.addEventListener( MouseEvent.CLICK, explode, false, 0, true );
    	}
		public function deathStart(event:TimerEvent){
			if (ball.punchPower){
				trace("hello");
				ball.hitControl = 0;
				if (mainRef.myBall2 != null){
					mainRef.myBall2.hitControl = 0;
				}
			}
			removeEventListener(Event.ENTER_FRAME, waitToDie);
		}
		public function death(event:TimerEvent){
			if (ball.killAll == 0){
				ball.hitControl = 0;
				if (mainRef.myBall2 != null){
					mainRef.myBall2.hitControl = 0;
				}
				////if (!mainRef.isPaused){
			ball.ex = new Explode(xCoord,yCoord,myColor);
			
			ball.addChild(ball.ex); //problem is deifnitely with the fact that the parent this is removed almost instantly
			ball.ex.showExplosion();
			
			ball.bricksDestroyed += 1;
			//trace("bricks destroyed " + ball.bricksDestroyed);
			//ball.hitControl = 0;
			deathTimer.reset();
			this.parent.removeChild(this);
			ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct)
			//removeEventListener(Event.ENTER_FRAME, waitToDie);
				////}
			}
		}

	}
	
}
