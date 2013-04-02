package  {
	import flash.display.*;
	import flash.events.*;
	import flash.display.Graphics;
	import flash.display.Shape;
	import fl.controls.Label;
	import flash.utils.Timer;
	import fl.controls.Button;
	import flash.ui.Mouse;
	

	public class Ball extends MovieClip {
		
		//These variables are needed for moving the ball
		var ballXSpeed:Number = 5.5; //X Speed of the Ball
		var ballYSpeed:Number = 5.5; //Y Speed of the Ball
		var leftWallHit:int = 0; //monitors hits in-a-row on left wall
		var rightWallHit:int = 0; //monitors hits in-a-row on right wall
		var topHit:int = 0; //monitors hits in-a-row on ceiling
		var bottomHit:int = 0; //monitors hits in-a-row on floor [probably not needed]
		var leftWallHit2:int = 0; //monitors hits in-a-row on left wall
		var rightWallHit2:int = 0; //monitors hits in-a-row on right wall
		var topHit2:int = 0; //monitors hits in-a-row on ceiling
		var bottomHit2:int = 0; //monitors hits in-a-row on floor [probably not needed]
		var theBackground:MovieClip = new myBackground();
		var ex:Explode = new Explode();
		var power:powerUp;
		var trackLvl:int;
		//var splitTimer:Timer = new Timer(5000, 1);
		//var mainRef:FlashForceMain = new FlashForceMain();//causes a $%&&*( infinite loop!!
		//var h:Graphics = new Graphics();
		//h.
		//var rect:Shape = new Shape();
		public var myBall:MovieClip;
		//public var myBall2:MovieClip;
		public var myPaddle:MovieClip;
		public var evilPaddle:MovieClip;
		public var evilSight:MovieClip;
		public var countHit:int;
		public var hitControl:int = 0;
		//var myBall2:MovieClip;
		var playerHP:Number = 100;
		var enemyHP:Number = 100;
		var playerScore:int = 0;
		var enemyScore:int = 0;
		public var score:Label; //the player's score label
		public var eScore:Label; //the enemy's score label
		var control:int = 0;	//this variable will be used to track which paddle the ball just bounced off
		var bricksDestroyed:int = 0; //incremented when a brick is in its 'death' function, currently before the brick is removed from displaylist.  should be fine. 6/2/2011
		var factor2:Number = 0.8; 
		public var xLocations:Array = new Array();
		var noHurtTimer:Timer = new Timer(500,1);
		var noHurt:int = 0;
		public var startButton:Button;
		var theStage:Stage;
		var doomCount:int = 0; //zero in game, 1 when someone wins, then reinitialized to zero on restart
		var winnerLabel:Label = new Label();
		var killAll:int = 0;
		//var callParts:CallParts; //reuse the Explode object!  Just introduce a new function in Explode to govern the type of particle effect you want here IF NECESSARY
		var stuckTimer:Timer = new Timer(250,1);
		var rebuild:Boolean = false;
		var punchPower:Boolean = false;
		var moveTimer:Timer = new Timer(1000/30);//timer to control ball motion instead of enterFrame...
		var levelSize:int; //to be instant6iated/set dynamically via Bricks once a level is generated
	    var winner:int; //set when a player wins or loses. 1=player win 2=enemy win
		////ball2.y = (factor2 * ball2.y) + ((1-factor2) * position2);
		///////var shortTimer:Timer = new Timer(500, 1);
		//var brickRed:MovieClip;
		
		public function Ball(paddle:MovieClip,ball:MovieClip,ePaddle:MovieClip,startB:Button,stageRef:Stage,eSight:MovieClip) {
			score = new Label();
			//addChild(score);
			eScore = new Label();
			//addChild(eScore);
			this.myBall = ball;
			//this.myBall2 = ball2;
			this.myPaddle = paddle;
			this.evilPaddle = ePaddle;
			this.startButton = startB;
			this.theStage = stageRef;
			this.evilSight = eSight;
			//myBall2 = new Ball(myPaddle,myBall,evilPaddle,startButton,theStage,evilSight);
			//this.mainRef = main;
			//this.xLocations = xL;
			countHit = 0;
			myBall.addEventListener(Event.ENTER_FRAME, ballMotion);
			noHurtTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hurtAgain);
			stuckTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetHits);
			//splitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, endMultiply);
			score.x = 0;
			score.y = 30;
			score.width = 200;
			score.text = "PLAYER SCORE: " + playerScore;
			eScore.x = 275.85;
			eScore.y = 30;
			eScore.width = 200;
			eScore.text = "ENEMY SCORE: " + enemyScore;
			addChild(score);
			addChild(eScore);
			addChild(ex);
			//moveTimer.addEventListener(TimerEvent.TIMER, expMotion);
			//moveTimer.start();
			
			//brickRed = new brickRed(this.myPaddle,this.myBall);
			//addChild(brickRed);
			tempLvlSizeSet();
			
		}
		
		public function tempLvlSizeSet(){
			//this is a temporary hard-coded setting of levelSize prior to genLevel method completion
			levelSize = 30;
		}
		
		public function expMotion(e:TimerEvent){
			/*
			trace("Ball driver width: " + this.width); //should be okay....
			trace("Ball driver height: " + this.height);
			*/
			myBall.x += 5.01 * ballXSpeed;
			myBall.y += 5.01 * ballYSpeed;
			////myBall.x += (factor2 * ballXSpeed) //+ ((1-factor2) * ballXSpeed);
			////myBall.y += (factor2 * ballYSpeed) //+ ((1-factor2) * ballYSpeed);
			//need to get control right before stuckhandlers encountered
			if (myBall.hitTestObject(myPaddle)){
				control = 1;
				
			}
			
			//collision with evil paddle
			if (myBall.hitTestObject(evilPaddle)){
				control = 2;
				
			}
			
			//Bouncing the ball off of the walls
			if(myBall.x >= stage.stageWidth-myBall.width){
				//if the ball hits the right side
				//of the screen, then bounce off
				ballXSpeed *= -1;
				rightWallHit += 1;
				leftWallHit = 0;
				topHit = 0;
				bottomHit = 0;
				stuckTimer.reset();
				stuckTimer.start();
				if (rightWallHit > 3){
					stuckHandler();
				}
			}
			if(myBall.x <= 0){
				//if the ball hits the left side
				//of the screen, then bounce off
				ballXSpeed *= -1;
				leftWallHit += 1;
				rightWallHit = 0;
				topHit = 0;
				bottomHit = 0;
				stuckTimer.reset();
				stuckTimer.start();
				if (leftWallHit > 3){
					stuckHandler();
				}
			}
			if(myBall.y >= stage.stageHeight-myBall.height){
				//if the ball hits the bottom
				//then bounce up
				
				////theBackground.
				
				if (punchPower){
					punchPower = false;
				}
				
				ballYSpeed *= -1;
				bottomHit += 1;
				topHit = 0;
				if (noHurt == 0){
				enemyScore += 1;
				//addChild(eScore);
				//callParts = new CallParts((myBall.x + (myBall.width/2)),450);
				ex.showExplosion(myBall.x,myBall.y,3);
				
				//addChild(callParts);
				eScore.text = "ENEMY SCORE: " + enemyScore;
					if (enemyScore >= 10){
						enemyWin();
						/*
						winnerLabel.x = 240;
						winnerLabel.y = 100;
						winnerLabel.width = 150;
						winnerLabel.text = "Computer Wins!";
						addChild(winnerLabel);
						myBall.x = 275;
						evilPaddle.x = 275;
						evilSight.x = evilPaddle.x + (evilPaddle.width/2);
						evilSight.rotation = 0;
						myBall.y = 272;
						ballXSpeed = 0;
						ballYSpeed = 0;
						control = 0;
						////killAll = 1;
						doomCount = 1;
						//trace("" + theStage.numChildren);
						//trace("" + theStage.getChildAt(0));
						//////reset();
						//startButton.visible = true;
						*/
					}
				}
				stuckTimer.reset();
				stuckTimer.start();
				if (bottomHit > 3){
					stuckHandler3();
				}
				noHurtTimer.start();
				noHurt = 1;
			}
			if(myBall.y <= 50){
				//if the ball hits the top
				//then bounce down
				
				if (punchPower){
					punchPower = false;
				}
				
				ballYSpeed *= -1;
				topHit += 1;
				bottomHit = 0;
				//addChild(score);
				if (noHurt == 0){
				playerScore += 1;
				//callParts = new CallParts((myBall.x + (myBall.width/2)),50);
				//addChild(callParts);
				ex.showExplosion(myBall.x,myBall.y,2);
				
				score.text = "PLAYER SCORE: " + playerScore;
					if (playerScore >= 10){
						playerWin();
						/*
						winnerLabel.x = 240;
						winnerLabel.y = 100;
						winnerLabel.width = 150;
						winnerLabel.text = "You Win!";
						addChild(winnerLabel);
						myBall.x = 275;
						evilPaddle.x = 275;
						evilSight.x = evilPaddle.x + (evilPaddle.width/2);
						evilSight.rotation = 0;
						//myBall.y = 172; //this might be the cause of a level overlay-- ball might be touching top level of bricks if it hasnt been destroyed and when you hit start button to reset it gets screwed up 2/13/2011
						myBall.y = 72; //try this height instead.  Still, should try to place a control in to avoid that lingering reference stopping gc of old bricks. 2/13/2011
						ballXSpeed = 0;
						ballYSpeed = 0;
						control = 2;
						////killAll = 1;//one isolated circumstance where thigns go wrong--when someone wins and there are no bricks on stage, no bricks are added when you press start again
						doomCount = 1;
						//trace("" + theStage.numChildren);
						//////reset();
						//startButton.visible = true;
						*/
					}
				}
				stuckTimer.reset();
				stuckTimer.start();
				if (topHit > 3){
					stuckHandler2();
				}
				noHurtTimer.start();
				noHurt = 1;
			}
			
			//collision with paddlw
			if (myBall.hitTestObject(myPaddle)){
				control = 1;
				calcBallAngle();
			}
			
			//collision with evil paddle
			if (myBall.hitTestObject(evilPaddle)){
				control = 2;
				calcBallAngle2();
			}
			
			//collision with a brick
			//if (this.parent.contains(brickRed)){
				//if (myBall.hitTestObject(brickRed)){
				
					//brickHitHandler();
				//}
			//}
			
			e.updateAfterEvent();
		}
		
		public function resetHits(event:TimerEvent){
			topHit = 0;
			bottomHit = 0;
			rightWallHit = 0;
			leftWallHit = 0;
		}
		
		public function ballMotion(event:Event){
			
			/*
			trace("Ball driver width: " + this.width); //should be okay....
			trace("Ball driver height: " + this.height);
			*/
			myBall.x += 1.51 * ballXSpeed;
			myBall.y += 1.51 * ballYSpeed;
			////myBall.x += (factor2 * ballXSpeed) //+ ((1-factor2) * ballXSpeed);
			////myBall.y += (factor2 * ballYSpeed) //+ ((1-factor2) * ballYSpeed);
			//need to get control right before stuckhandlers encountered
			if (myBall.hitTestObject(myPaddle)){
				control = 1;
				
			}
			
			//collision with evil paddle
			if (myBall.hitTestObject(evilPaddle)){
				control = 2;
				
			}
			
			//Bouncing the ball off of the walls
			if(myBall.x >= stage.stageWidth-myBall.width){
				//if the ball hits the right side
				//of the screen, then bounce off
				ballXSpeed *= -1;
				rightWallHit += 1;
				leftWallHit = 0;
				topHit = 0;
				bottomHit = 0;
				stuckTimer.reset();
				stuckTimer.start();
				if (rightWallHit > 3){
					stuckHandler();
				}
			}
			if(myBall.x <= 0){
				//if the ball hits the left side
				//of the screen, then bounce off
				ballXSpeed *= -1;
				leftWallHit += 1;
				rightWallHit = 0;
				topHit = 0;
				bottomHit = 0;
				stuckTimer.reset();
				stuckTimer.start();
				if (leftWallHit > 3){
					stuckHandler();
				}
			}
			if(myBall.y >= stage.stageHeight-myBall.height){
				//if the ball hits the bottom
				//then bounce up
				
				////theBackground.
				
				if (punchPower){
					punchPower = false;
				}
				
				ballYSpeed *= -1;
				bottomHit += 1;
				topHit = 0;
				if (noHurt == 0){
				enemyScore += 1;
				//addChild(eScore);
				//callParts = new CallParts((myBall.x + (myBall.width/2)),450);
				//addChild(callParts);
				ex.showExplosion(myBall.x,myBall.y,3);
				
				eScore.text = "ENEMY SCORE: " + enemyScore;
					if (enemyScore >= 10){
						enemyWin();
						/*
						winnerLabel.x = 240;
						winnerLabel.y = 100;
						winnerLabel.width = 150;
						winnerLabel.text = "Computer Wins!";
						addChild(winnerLabel);
						myBall.x = 275;
						evilPaddle.x = 275;
						evilSight.x = evilPaddle.x + (evilPaddle.width/2);
						evilSight.rotation = 0;
						myBall.y = 272;
						ballXSpeed = 0;
						ballYSpeed = 0;
						control = 0;
						////killAll = 1;
						doomCount = 1;
						//trace("" + theStage.numChildren);
						//trace("" + theStage.getChildAt(0));
						//////reset();
						//startButton.visible = true;
						*/
					}
				}
				stuckTimer.reset();
				stuckTimer.start();
				if (bottomHit > 3){
					stuckHandler3();
				}
				noHurtTimer.start();
				noHurt = 1;
			}
			if(myBall.y <= 50){   //CONDITION SHOULD BE  myBall.y <= 50 FOR RELEASE
				//if the ball hits the top
				//then bounce down
				
				if (punchPower){
					punchPower = false;
				}
				
				ballYSpeed *= -1;
				topHit += 1;
				bottomHit = 0;
				//addChild(score);
				if (noHurt == 0){
				playerScore += 1;
				//callParts = new CallParts((myBall.x + (myBall.width/2)),50); //CONDITION SHOULD BE  myBall.y <= 50 FOR RELEASE
				//addChild(callParts);
				ex.showExplosion(myBall.x,myBall.y,2);
				
				score.text = "PLAYER SCORE: " + playerScore;
					if (playerScore >= 10){
						playerWin();
						/*
						winnerLabel.x = 240;
						winnerLabel.y = 100;
						winnerLabel.width = 150;
						winnerLabel.text = "You Win!";
						addChild(winnerLabel);
						myBall.x = 275;
						evilPaddle.x = 275;
						evilSight.x = evilPaddle.x + (evilPaddle.width/2);
						evilSight.rotation = 0;
						//myBall.y = 172; //this might be the cause of a level overlay-- ball might be touching top level of bricks if it hasnt been destroyed and when you hit start button to reset it gets screwed up 2/13/2011
						myBall.y = 72; //try this height instead.  Still, should try to place a control in to avoid that lingering reference stopping gc of old bricks. 2/13/2011
						ballXSpeed = 0;
						ballYSpeed = 0;
						control = 2;
						////killAll = 1;//one isolated circumstance where thigns go wrong--when someone wins and there are no bricks on stage, no bricks are added when you press start again
						doomCount = 1;
						//trace("" + theStage.numChildren);
						//////reset();
						//startButton.visible = true;
						*/
					}
				}
				stuckTimer.reset();
				stuckTimer.start();
				if (topHit > 3){
					stuckHandler2();
				}
				noHurtTimer.start();
				noHurt = 1;
			}
			
			//collision with paddlw
			if (myBall.hitTestObject(myPaddle)){
				control = 1;
				calcBallAngle();
			}
			
			//collision with evil paddle
			if (myBall.hitTestObject(evilPaddle)){
				control = 2;
				calcBallAngle2();
			}
			
			//collision with a brick
			//if (this.parent.contains(brickRed)){
				//if (myBall.hitTestObject(brickRed)){
				
					//brickHitHandler();
				//}
			//}
			
		}
		
		
		
		public function enemyWin(){
						winner = 2;
						winnerLabel.x = 240;
						winnerLabel.y = 100;
						winnerLabel.width = 150;
						winnerLabel.text = "Computer Wins!";
						addChild(winnerLabel);
						myBall.x = 275;
						evilPaddle.x = 275;
						evilSight.x = evilPaddle.x + (evilPaddle.width/2);
						evilSight.rotation = 0;
						myBall.y = 272;
						ballXSpeed = 0;
						ballYSpeed = 0;
						control = 0;
						////killAll = 1;
						doomCount = 1;
		}
		public function playerWin(){
						winner = 1;
						winnerLabel.x = 240;
						winnerLabel.y = 100;
						winnerLabel.width = 150;
						winnerLabel.text = "You Win!";
						addChild(winnerLabel);
						myBall.x = 275;
						evilPaddle.x = 275;
						evilSight.x = evilPaddle.x + (evilPaddle.width/2);
						evilSight.rotation = 0;
						//myBall.y = 172; //this might be the cause of a level overlay-- ball might be touching top level of bricks if it hasnt been destroyed and when you hit start button to reset it gets screwed up 2/13/2011
						myBall.y = 72; //try this height instead.  Still, should try to place a control in to avoid that lingering reference stopping gc of old bricks. 2/13/2011
						ballXSpeed = 0;
						ballYSpeed = 0;
						control = 2;
						////killAll = 1;//one isolated circumstance where thigns go wrong--when someone wins and there are no bricks on stage, no bricks are added when you press start again
						doomCount = 1;
		}
		
		public function calcBallAngle(){
			//ballPosition is the position of the ball is on the paddle
			var ballPosition:Number = myBall.x - myPaddle.x;
			//hitPercent converts ballPosition into a percent
			//All the way to the left is -.5
			//All the way to the right is .5
			//The center is 0
			var hitPercent:Number = (ballPosition / (myPaddle.width - myBall.width)) - .5;
			//Gets the hitPercent and makes it a larger number so the
			//ball actually bounces
			ballXSpeed = hitPercent * 10;
			//ballXSpeed = ballXSpeed + (hitPercent + 1.0);
			//Making the ball bounce back up
			ballYSpeed *= -1;
			
		}
		
		public function calcBallAngle2(){
			//ballPosition is the position of the ball is on the paddle
			var ballPosition:Number = myBall.x - evilPaddle.x;
			//hitPercent converts ballPosition into a percent
			//All the way to the left is -.5
			//All the way to the right is .5
			//The center is 0
			var hitPercent:Number = (ballPosition / (evilPaddle.width - myBall.width)) - .5;
			//Gets the hitPercent and makes it a larger number so the
			//ball actually bounces
			ballXSpeed = hitPercent * 10;
			//ballXSpeed = ballXSpeed + (hitPercent + 1.0);
			//Making the ball bounce back up
			ballYSpeed *= -1;
			
		}
		
		
		
		
		public function stuckHandler(){
			if (rightWallHit > 3){
				myBall.x -= (myBall.width + 1);
				if (control == 1){
					myBall.y -= (Math.abs(myPaddle.y - myBall.y) + 1);
				}
				if (control == 2){
					myBall.y += (Math.abs(evilPaddle.y - myBall.y) + 1);
				}
			}
			if (leftWallHit > 3){
				myBall.x += (myBall.width + 1);
				if (control == 1){
					myBall.y -= (Math.abs(myPaddle.y - myBall.y) + 1);
				}
				if (control == 2){
					myBall.y += (Math.abs(evilPaddle.y - myBall.y) + 1);
				}
			}
			leftWallHit = 0;
			rightWallHit = 0;
		}
		
		public function stuckHandler2(){
			myBall.y += (myBall.height * 3);
			topHit = 0;
		}
		
		
		public function stuckHandler3(){
			myBall.y -= (myBall.height * 3);
			bottomHit = 0;
		}
		
		
		//public function brickHitHandler(){
			//ballYSpeed *= -1;
		//}
		
		public function hurtAgain(event:TimerEvent){
			noHurt = 0;
			noHurtTimer.reset();
			
		}
		/*
		public function multiply(){
			myBall2 = new Ball(this.myPaddle,this.myBall,this.evilPaddle,this.startButton,this.theStage,this.evilSight);
			myBall2.x = myBall.x + (myBall.width + 5);
			myBall2.y = myBall.y;
			addChild(myBall2);
			myBall2.addEventListener(Event.ENTER_FRAME, ballMotion2);
			
			
		}
		
		public function endMultiply(event:TimerEvent){
			myBall2.removeEventListener(Event.ENTER_FRAME, ballMotion2);
			removeChild(myBall2);
		}
		*/
		//The reset function will reset all properties to their initial values/values appropriate for ending a game and standing by for a new one
		/*
		public function reset(){
			//problem here might be that the stage itself has no children-- the classes that have addChild() are the parents...
			for (var i:int = 0; i < theStage.numChildren; i++){
				if (theStage.getChildAt(i+1) != null){
					theStage.removeChildAt(i);
				}
				if (theStage.getChildAt(i+1) == null){
					theStage.removeChildAt(i);
					Mouse.show();
					startButton.visible = true;
					break;
				}
			}
		*/
		/*
			//These variables are needed for moving the ball
		ballXSpeed = 0; //X Speed of the Ball
		ballYSpeed = 0; //Y Speed of the Ball
		leftWallHit = 0; //monitors hits in-a-row on left wall
		rightWallHit = 0; //monitors hits in-a-row on right wall
		topHit = 0; //monitors hits in-a-row on ceiling
		bottomHit = 0; //monitors hits in-a-row on floor [probably not needed]
		//theBackground:MovieClip = new myBackground();
		//var h:Graphics = new Graphics();
		//h.
		//var rect:Shape = new Shape();
		//public var myBall:MovieClip;
		//public var myPaddle:MovieClip;
		//public var evilPaddle:MovieClip;
		countHit = 0;
		playerHP = 100;
		enemyHP = 100;
		playerScore = 0;
		enemyScore = 0;
		//public var score:Label;
		//public var eScore:Label;
		control = 0;	//this variable will be used to track which paddle the ball just bounced off
		bricksDestroyed = 0;
		factor2 = 0.8; 
		//public var xLocations:Array = new Array();
		//noHurtTimer:Timer = new Timer(500,1);
		noHurt = 0;
		*/
		//}
		
	}
	
}
