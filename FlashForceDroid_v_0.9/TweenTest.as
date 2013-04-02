package  {

import flash.display.*;
import flash.events.*;
import flash.ui.Keyboard;
public class TweenTest{
	
var velocity:Number = 0;
var acceleration:Number = 0.5;
var friction:Number = 0.94;

var isRightKeyDown:Boolean = false;
var isLeftKeyDown:Boolean = false;

stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);

function keyDownHandler(e:KeyboardEvent):void {
	if(e.keyCode == Keyboard.RIGHT) {
		isRightKeyDown = true;
	}
	if(e.keyCode == Keyboard.LEFT) {
		isLeftKeyDown = true;
	}
}
function keyUpHandler(e:KeyboardEvent):void {
	if(e.keyCode == Keyboard.RIGHT) {
		isRightKeyDown = false;
	}
	if(e.keyCode == Keyboard.LEFT) {
		isLeftKeyDown = false;
	}
}
function enterFrameHandler(e:Event):void {
	if(isRightKeyDown) {
		velocity += acceleration;
		if (velocity > 10) {
			velocity = 10;
		}
	} else if(isLeftKeyDown) {
		velocity -= acceleration;
		if (velocity < -10) {
			velocity = -10;
		}
	}
	velocity *= friction;
	this.x += velocity;
}
}
}
