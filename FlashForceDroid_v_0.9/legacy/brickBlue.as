/*
we'll want to change two things for sure-- 
--first, the bricks should reappear over time in the original level configuration
--Second, the paddles should return to normal size over time regardless of brick bonuses/penalties
also, may wish to add further boons/curses based on which bricks are hit by whom
finally, the stuckhandler needs to be revised (ball can get caught at least in upper-right corner)
	on a related note, some 'invincibility' timer [during which scores won't change] should be implemented to ensure trapped ball 
	doesn't make one score or the other shoot up.
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
	
	public class brickBlue extends MovieClip{
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
		public function brickBlue(enPaddle:enemyPaddle,paddle:MovieClip,ball:MovieClip,theBall:Ball,ePaddle:MovieClip,eSight:MovieClip,startB:Button,myX:Number,myY:Number,level:Array,bricksH:Bricks,mainR:FlashForceMain){//,count:int) {
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
			//ball.startButton.addEventListener(MouseEvent.CLICK, selfDestruct);
			shortTimer.start();
			shortTimer.addEventListener(TimerEvent.TIMER_COMPLETE, tickDone);
			deathTimer.addEventListener(TimerEvent.TIMER, deathStart);
			deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, death);
			setStarHit();
			addEvent();
			
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
		
		public function selfDestruct3(){
				this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				deathTimer.stop();
				deathTimer.reset();
				deathTimer.removeEventListener(TimerEvent.TIMER, deathStart);
				deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, death);
				//this.removeEventListener(Event.ENTER_FRAME, waitToDie)
				ball.startButton.removeEventListener(MouseEvent.CLICK, selfDestruct);
				ball.bricksDestroyed += 1;
				if (this.parent != null) {
					this.parent.removeChild(this);
				}
		}
		
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
				if (ball.bricksDestroyed == lvlCode.length && bricksHandle.numChildren == 0){
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
		
		
		public function waitToDie(event:Event){
			if (ball.killAll == 1){
				selfDestruct2();
			}
			if (this.hitTestObject(evilSight)){
				ePaddle.checkSight("blue",xCoord,yCoord);
			}
			if (mainRef.myBall2 != null){ //START 1 if ball2 exists ...in the case that ball2 exists... also allows for ball2 time to get gc'd if it should leaving game-- interesting tactic we accidentaslly discovered here!
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
			//level overlay can still happen if menu comes up just as a brick is getting hit and is left up long enough
			//and then reset is eventually chosen possibly...
			
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
			removeEventListener(Event.ENTER_FRAME, waitToDie);
			////}
			}
		}
		
		//public function watchPause(event:Event){
			//watch to see 
		//}

	}
	
}
