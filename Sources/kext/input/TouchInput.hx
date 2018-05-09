package kext.input;

import kext.Signal;
import kext.Basic;
import kext.events.TouchStartEvent;
import kext.events.TouchEndEvent;
import kext.events.TouchMoveEvent;
import kext.math.Rectangle;

import kha.math.Vector2;
import kha.input.Surface;

using kext.input.InputState;

class TouchInput extends Basic
{
	private var touchData:Map<Int, InputState>;
	private var touchPosition:Map<Int, Vector2>;
	private var pressedQueue:Array<Int>;
	private var releasedQueue:Array<Int>;

	public var touches:Array<Int>;
	
	public var onTouchStart:Signal<TouchStartEvent> = new Signal();
	public var onTouchEnd:Signal<TouchEndEvent> = new Signal();
	public var onTouchMove:Signal<TouchMoveEvent> = new Signal();

	public function new() 
	{
		super();
		
		name = "Touch Input";
		
		touchData = new Map<Int, InputState>();
		touchPosition = new Map<Int, Vector2>();
		pressedQueue = [];
		releasedQueue = [];

		touches = [];

		var surface = Surface.get(0);
		if(surface != null) {
			surface.notify(touchStartListener, touchEndListener, touchMoveListener);
		} else {
			trace("No surface of index 0 found");
		}
	}

	public function isTouching() {
		return touches.length > 0;
	}
	
	private function touchStartListener(index:Int, x:Int, y:Int) {
		touchData.set(index, PRESSED);
		touches.push(index);
		pressedQueue.push(index);
		
		var gamePosition:Vector2 = Application.screenToGamePosition(new Vector2(x, y));
		onTouchStart.dispatch({index: index, x: gamePosition.x, y: gamePosition.y});
	}
	
	private function touchEndListener(index:Int, x:Int, y:Int) {
		touchData.set(index, PRESSED);
		touches.remove(index);
		pressedQueue.push(index);
		
		var gamePosition:Vector2 = Application.screenToGamePosition(new Vector2(x, y));
		onTouchEnd.dispatch({index: index, x: gamePosition.x, y: gamePosition.y});
	}
	
	private function touchMoveListener(index:Int, x:Int, y:Int) {
		var lastPosition:Vector2 = touchPosition.get(index);
		if(lastPosition == null) {
			lastPosition = new Vector2(0, 0);
			touchPosition.set(index, lastPosition);
		}
		var gamePosition:Vector2 = Application.screenToGamePosition(new Vector2(x, y));
		var deltaX:Float = gamePosition.x - lastPosition.x;
		var deltaY:Float = gamePosition.y - lastPosition.y;
		lastPosition.x = gamePosition.x;
		lastPosition.y = gamePosition.y;
		onTouchMove.dispatch({index: index, x: gamePosition.x, y: gamePosition.y, deltaX: deltaX, deltaY: deltaY});
	}
	
	public function touchDown(touchValue:Int = 0):Bool {
		var state:InputState = touchData.get(touchValue);
		return state == DOWN || state == PRESSED;
	}
	
	public function touchUp(touchValue:Int = 0):Bool {
		var state:InputState = touchData.get(touchValue);
		return state == UP || state == RELEASED;
	}
	
	public function touchPressed(touchValue:Int = 0):Bool {
		return touchData.get(touchValue) == PRESSED;
	}
	
	public function touchReleased(touchValue:Int = 0):Bool {
		return touchData.get(touchValue) == RELEASED;
	}
	
	override public function update(delta:Float) {
		super.update(delta);
		
		checkQueue(releasedQueue, UP);
		checkQueue(pressedQueue, DOWN);
	}

	public function getTouchesInArea(area:Rectangle):Array<Vector2> {
		var areaTouches:Array<Vector2> = [];
		for(touch in touches) {
			var position:Vector2 = touchPosition.get(touch);
			if(position != null && area.pointInside(position)) {
				areaTouches.push(position);
			}
		}
		return areaTouches;
	}
	
	private function checkQueue(queue:Array<Int>, state:InputState) {
		var key:Int;
		while (queue.length > 0) {
			var key = queue.pop();
			if (touchData.exists(key)) {
				touchData.set(key, state);
			}
		}
	}
	
	public function clearInput() {
		var touchs = touchData.keys();
		for (touch in touchs) {
			touchData.set(touch, UP);
		}
		
		while (releasedQueue.length > 0) {
			releasedQueue.pop();
		}
		while (pressedQueue.length > 0) {
			pressedQueue.pop();
		}
	}
}