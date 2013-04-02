package {

	//import required packages
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;

	//draw package
	public class DrawPackage extends MovieClip {
		//global variable declerations
		var gameStarted:Boolean=false;
		var gameTimer:Timer;
		var bitmapNames:Array=[];
		var sourceBitmaps:Array=[];
		var canvasBD:BitmapData;
		var canvasBitmap:Bitmap;
		var Units:Array=[];
		var pressedKeys:Array=[];
		var lastUnitNumber:int=0;

		//create game
		public function DrawPackage() {
			trace("create game");

			//create keyboard listeners
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownListener);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpListener);

			//create timer
			gameTimer=new Timer(15);
			gameTimer.addEventListener(TimerEvent.TIMER, loopGame);

			//create canvas child and bitmapData
			canvasBD=new BitmapData(600,600,true,0x00000000);
			canvasBitmap=new Bitmap(canvasBD);
			addChild(canvasBitmap);

			//////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////
			// unit images

			//select image link names from the library
			bitmapNames[0]="Background";
			bitmapNames[1]="Block1";
			bitmapNames[2]="Block2";
			bitmapNames[3]="Block3";
			bitmapNames[4]="Block4";
			bitmapNames[5]="Bouncer";
			bitmapNames[6]="Ball";

			//////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////
			// unit images - end

			//cache bitmap data
			for (var i=0; i<bitmapNames.length; i++) {
				//get the bitmap
				var tMC:Class=getDefinitionByName(bitmapNames[i]) as Class;

				//create bitmap class
				var newMc=new tMC(0,0);

				//determine the additional size needed for the bitmap to rotate without cutting the borders
				var xDif:int=Math.sqrt(Math.pow(newMc.width*0.5,2)+Math.pow(newMc.height*0.5,2))*2-newMc.width,yDif:int=Math.sqrt(Math.pow(newMc.width*0.5,2)+Math.pow(newMc.height*0.5,2))*2-newMc.height;
				if (newMc.height>newMc.width) {
					xDif=xDif+newMc.height-newMc.width;
				} else {
					yDif=yDif+newMc.width-newMc.height;
				}

				//save bitmap data
				var imageBitmap:Bitmap=new Bitmap(newMc.bitmapData);

				//create an additional, larger bitmap data to save the old bitmap data on
				var spriteMapBitmap:BitmapData=new BitmapData(newMc.width+xDif,newMc.height+yDif,true,0x00000000);

				//draw the first bitmap data in the center of the larger bitmap data
				var moveMatrix:Matrix = new Matrix();
				moveMatrix.translate(Math.ceil(xDif * 0.5),Math.ceil(yDif * 0.5));
				spriteMapBitmap.draw(newMc,moveMatrix);

				//save the final bitmap data
				sourceBitmaps[i]=spriteMapBitmap;
			}

			//start game
			startStopGame();
		}

		//start-stop game
		public function startStopGame():void {
			if (! gameStarted) {
				trace("start game");

				//////////////////////////////////////////////////////////
				//////////////////////////////////////////////////////////
				// create breakout units

				//create background
				createUnit("Background","Background",new Point(265, 250),0);

				//create blocks
				for (var i=0; i<8; i++) {
					for (var n=0; n<6; n++) {
						if ((n==5&&(i<2||i>5))||(n==3&&(i>2&&i<5))||(n==1&&(i==2||i==5))) {
							createUnit("MetalBlock","Block4",new Point(69 + i * 59, 75 + n * 29),0);
						} else if (n < 2) {
							createUnit("Block","Block1",new Point(69 + i * 59, 75 + n * 29),0);
						} else if (n < 4) {
							createUnit("Block","Block2",new Point(69 + i * 59, 75 + n * 29),0);
						} else {
							createUnit("Block","Block3",new Point(69 + i * 59, 75 + n * 29),0);
						}
					}
				}

				//create bouncer
				createUnit("Bouncer","Bouncer",new Point(275, 480),0);
				Units[getUnit("Bouncer")].velocity=0;

				//create ball
				createUnit("Ball","Ball",new Point(275, 300),0);
				Units[getUnit("Ball")].timeUntilStart=100;
				Units[getUnit("Ball")].velocityx=0;
				Units[getUnit("Ball")].velocityy=5;

				//create ball
				createUnit("Life1","Ball",new Point(20, 20),0);
				createUnit("Life2","Ball",new Point(60, 20),0);
				createUnit("Life3","Ball",new Point(100, 20),0);

				//////////////////////////////////////////////////////////
				//////////////////////////////////////////////////////////
				// create breakout units - end

				//start the game timer
				gameStarted=true;
				gameTimer.start();
			} else {
				trace("stop game");

				//stop the game timer
				gameStarted=false;
				gameTimer.stop();

				//remove all units 
				destroyUnit("All");
			}
		}

		//game loop
		private function loopGame(e:TimerEvent) {
			//update game
			updateGame();
			
			//clear the canvas bitmap
			canvasBD.colorTransform(new Rectangle(0,0,stage.width,stage.height),new ColorTransform(1,1,1,0,0,0,0));

			//draw game
			drawGame();
		}

		//update the game
		private function updateGame():void {
			//////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////
			// update breakout units
			//move bouncer
			if (pressedKeys[37]) {
				Units[getUnit("Bouncer")].velocity = (Units[getUnit("Bouncer")].velocity * 3 - 10) / 4;
			} else if (pressedKeys[39]) {
				Units[getUnit("Bouncer")].velocity = (Units[getUnit("Bouncer")].velocity * 3 + 10) / 4;
			} else {
				Units[getUnit("Bouncer")].velocity=Units[getUnit("Bouncer")].velocity*3/4;
			}
			Units[getUnit("Bouncer")].x=Units[getUnit("Bouncer")].x+Units[getUnit("Bouncer")].velocity;
			if (Units[getUnit("Bouncer")].x<50&&Units[getUnit("Bouncer")].velocity<0||Units[getUnit("Bouncer")].x>500&&Units[getUnit("Bouncer")].velocity>0) {
				Units[getUnit("Bouncer")].velocity=Units[getUnit("Bouncer")].velocity*-1;
				if (Units[getUnit("Bouncer")].x<50) {
					Units[getUnit("Bouncer")].x=50;
				} else if (Units[getUnit("Bouncer")].x>500) {
					Units[getUnit("Bouncer")].x=500;
				}
			}

			//move ball
			if (Units[getUnit("Ball")].timeUntilStart>0) {
				Units[getUnit("Ball")].timeUntilStart=Units[getUnit("Ball")].timeUntilStart-1;
			} else {
				Units[getUnit("Ball")].x=Units[getUnit("Ball")].x+Units[getUnit("Ball")].velocityx;
				Units[getUnit("Ball")].y=Units[getUnit("Ball")].y+Units[getUnit("Ball")].velocityy;
			}

			//bounce ball against wall and ceiling
			if (Units[getUnit("Ball")].x<15&&Units[getUnit("Ball")].velocityx<0||Units[getUnit("Ball")].x>535&&Units[getUnit("Ball")].velocityx>0) {
				Units[getUnit("Ball")].velocityx=Units[getUnit("Ball")].velocityx*-1;
			}
			if (Units[getUnit("Ball")].y<15&&Units[getUnit("Ball")].velocityy<0) {
				Units[getUnit("Ball")].velocityy=Units[getUnit("Ball")].velocityy*-1;
			} else if (Units[getUnit("Ball")].y > 550) {
				//ball fell down
				Units[getUnit("Ball")].x=275;
				Units[getUnit("Ball")].y=300;
				Units[getUnit("Ball")].velocityx=0;
				Units[getUnit("Ball")].velocityy=5;
				Units[getUnit("Ball")].timeUntilStart=100;

				//decrease lifes
				if (getUnit("Life3")>-1) {
					destroyUnit("Life3");
				} else if (getUnit("Life2")>-1) {
					destroyUnit("Life2");
				} else if (getUnit("Life1")>-1) {
					destroyUnit("Life1");
				} else {
					startStopGame();
					startStopGame();
				}
			}

			//reset game if all blocks are gone
			n=0;
			for (i=0; i<Units.length; i++) {
				if (Units[i].name=="Block") {
					n=n+1;
				}
			}
			if (n==0) {
				startStopGame();
				startStopGame();
			}

			//check for collisions
			for (var i=0; i<Units.length; i++) {
				for (var n=0; n<Units.length; n++) {
					if (Units[i].name=="Ball"&&Units[n].name=="Bouncer"||
					Units[i].name=="Ball"&&Units[n].name=="Block"||
					Units[i].name=="Ball"&&Units[n].name=="MetalBlock") {
						if (getCollision(i, n)) {
							trace("collision between " + Units[i].name + " and " + Units[n].name);

							if (Units[i].name=="Ball"&&Units[n].name=="Bouncer") {
								//bounce ball against bouncer
								if (Units[i].velocityy>0) {
									if (Units[i].velocityy>6) {
										Units[i].velocityy=Units[i].velocityy*-1;
									} else {
										Units[i].velocityy=Units[i].velocityy*-1.05;
									}
									Units[i].velocityx = Units[i].velocityx + (Units[i].x - Units[n].x) * 0.05;
								}
								Units[getUnit("Ball")].x=Units[getUnit("Ball")].x+Units[getUnit("Ball")].velocityx;
								Units[getUnit("Ball")].y=Units[getUnit("Ball")].y+Units[getUnit("Ball")].velocityy;
							} else if (Units[i].name=="Ball"&&(Units[n].name=="Block"||Units[n].name=="MetalBlock")) {
								//bounce ball against block
								if (Math.abs(Units[i].x-Units[n].x)<30) {
									if ((Units[i].y < Units[n].y && Units[i].velocityy > 0) || (Units[i].y > Units[n].y && Units[i].velocityy < 0)) {
										Units[i].velocityy=Units[i].velocityy*-1 + (0.01 - Math.random() * 10 / 1000);
									}
								} else if (Math.abs(Units[i].y-Units[n].y)<30) {
									if ((Units[i].x < Units[n].x && Units[i].velocityx > 0) || (Units[i].x > Units[n].x && Units[i].velocityx < 0)) {
										Units[i].velocityx=Units[i].velocityx*-1;
									}
								} else {
									Units[i].velocityx=Units[i].velocityx*-1;
									Units[i].velocityy=Units[i].velocityy*-1;
								}
								Units[getUnit("Ball")].x=Units[getUnit("Ball")].x+Units[getUnit("Ball")].velocityx;
								Units[getUnit("Ball")].y=Units[getUnit("Ball")].y+Units[getUnit("Ball")].velocityy;

								//destroy block
								if (Units[n].name=="Block") {
									Units.splice(n,1);
									n=n-1;
									if (i>n) {
										i=i-1;
									}
								}
							}
						}
					}
				}
			}

			//////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////
			// update breakout units - end
		}

		//draw the game
		private function drawGame():void {
			//draw units
			for (var i=0; i<Units.length; i++) {
				//update bitmap data if unit has rotated
				if (!(Units[i].rotation == Units[i].oldRotation)) {
					//set the comparison rotation to the current rotation
					Units[i].oldRotation=Units[i].rotation;

					//rotate the bitmap data using a matrix
					var angle = Math.PI * 2 * (Units[i].rotation / 360);
					var rotationMatrix:Matrix = new Matrix();
					rotationMatrix.translate(-sourceBitmaps[Units[i].bitmapNumber].width * 0.5,-sourceBitmaps[Units[i].bitmapNumber].height * 0.5);
					rotationMatrix.rotate(angle);
					rotationMatrix.translate(sourceBitmaps[Units[i].bitmapNumber].width * 0.5,sourceBitmaps[Units[i].bitmapNumber].height * 0.5);

					//create a new bitmap data and save a rotated version of the source bitmap data on it
					var matrixImage:BitmapData=new BitmapData(sourceBitmaps[Units[i].bitmapNumber].width,sourceBitmaps[Units[i].bitmapNumber].height,true,0x00000000);
					matrixImage.draw(sourceBitmaps[Units[i].bitmapNumber], rotationMatrix);

					//save the rotated bitmap
					Units[i].bitmap=matrixImage;
				}

				//copy the pixels to the canvas movie clip
				canvasBD.copyPixels(Units[i].bitmap, Units[i].bitmap.rect , new Point(Units[i].x - Units[i].bitmap.width * 0.5,Units[i].y - Units[i].bitmap.height * 0.5), null, null, true);
			}
		}

		//create unit
		private function createUnit(id,bitmap:String,position:Point,rotation:int) {
			//create new unit object
			var tempUnit:Object=new Object();

			//set all unit properties
			tempUnit.name=id;
			tempUnit.x=position.x;
			tempUnit.y=position.y;
			tempUnit.oldRotation;
			tempUnit.rotation=rotation;
			tempUnit.bitmapNumber=0;

			//set a temporary empty bitmap
			var emptyBitmapData:BitmapData=new BitmapData(1,1,true,0x00000000);
			tempUnit.bitmap=emptyBitmapData;

			//find the bitmap number
			for (var i=0; i<bitmapNames.length; i++) {
				if (bitmapNames[i]==bitmap) {
					tempUnit.bitmapNumber=i;
				}
			}

			//add the unit object to the units array
			Units.push(tempUnit);

			trace("unit number " + Units.length + " created");
		}

		//destroy units
		private function destroyUnit(id:String) {
			//find and destroy all the units with the id
			var n=0;
			for (var i=0; i<Units.length; i++) {
				if (Units[i].name==id||id=="All") {
					Units.splice(i,1);
					i=i-1;
					n=n+1;
				}
			}

			//return the number of destroyed units
			return n;
		}

		//get the units array number for the id
		private function getUnit(id:String) {
			//get the last unit again
			if (lastUnitNumber<Units.length&&Units[lastUnitNumber].name==id) {
				return lastUnitNumber;
			} else {
				for (var i=0; i<Units.length; i++) {
					if (Units[i].name==id) {
						//return the units array number
						lastUnitNumber=i;
						return i;
						break;
					}
					if (i==Units.length-1) {
						//return -1 if no units with the id was found
						return -1;
					}
				}
			}
		}

		//set units bitmap
		private function setUnitBitmap(id,bitmap:String) {
			//find what the bitmap number is
			var u=-1;
			for (i=0; i<bitmapNames.length; i++) {
				if (bitmapNames[i]==bitmap) {
					u=i;
					break;
				}
			}

			//set the bitmap for all the units with the id
			for (var i=0; i<Units.length; i++) {
				if (Units[i].name==id) {
					Units[i].oldRotation=new int  ;
					Units[i].bitmapNumber=u;
				}
			}
		}

		//get collision
		private function getCollision(n, i:int) {
			if (!(Units[i]==Units[n]) && (Units[i].x - Units[i].bitmap.width * 0.5 > Units[n].x - Units[n].bitmap.width * 0.5 && Units[i].x - Units[i].bitmap.width * 0.5 < Units[n].x + Units[n].bitmap.width * 0.5 ||
			 Units[n].x - Units[n].bitmap.width * 0.5 > Units[i].x - Units[i].bitmap.width * 0.5 && Units[n].x - Units[n].bitmap.width * 0.5 < Units[i].x + Units[i].bitmap.width * 0.5) &&
			 (Units[i].y - Units[i].bitmap.height * 0.5 > Units[n].y - Units[n].bitmap.height * 0.5 && Units[i].y - Units[i].bitmap.height * 0.5 < Units[n].y + Units[n].bitmap.height * 0.5 ||
			 Units[n].y - Units[n].bitmap.height * 0.5 > Units[i].y - Units[i].bitmap.height * 0.5 && Units[n].y - Units[n].bitmap.height * 0.5 < Units[i].y + Units[i].bitmap.height * 0.5) &&
			Units[i].bitmap.hitTest(new Point(Units[i].x - Units[i].bitmap.width * 0.5,Units[i].y - Units[i].bitmap.height * 0.5),255,Units[n].bitmap,new Point(Units[n].x - Units[n].bitmap.width * 0.5,Units[n].y - Units[n].bitmap.height * 0.5),255)) {
				return true;
			} else {
				return false;
			}
		}

		//key down event
		private function keyDownListener(e:KeyboardEvent) {
			trace("down e.keyCode=" + e.keyCode);

			//set the pressed key to false
			pressedKeys[e.keyCode]=true;
		}

		//key up event
		private function keyUpListener(e:KeyboardEvent) {
			trace("up e.keyCode=" + e.keyCode);

			//set the released key to false
			pressedKeys[e.keyCode]=false;
		}
	}
}