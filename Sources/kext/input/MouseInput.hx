package kext.input;

import kext.Signal;
import kext.Basic;

import kext.events.MousePressedEvent;
import kext.events.MouseReleasedEvent;
import kext.events.MouseMoveEvent;
import kext.events.MouseWheelEvent;

import kha.input.Mouse;
import kha.math.Vector2;

using kext.input.InputState;

typedef MouseButton = {
	button:Int,
	x:Int,
	y:Int
}

typedef MouseDelta = {
	x: Int,
	y: Int,
	dx: Int,
	dy: Int
}

typedef MouseWheelDelta = {
	delta: Int
}

class MouseInput extends Basic
{
	private var buttonData:Map<Int, InputState> = new Map();
	private var pressedQueue:Array<Int> = [];
	private var releasedQueue:Array<Int> = [];

	public var x(get, null):Float;
	public var y(get, null):Float;
	
	public var position(get, null):Vector2;
	public var posDelta(get, null):Vector2;
	private var _position:Vector2 = new Vector2();
	private var _posDelta:Vector2 = new Vector2();
	
	public var onPressed:Signal<MousePressedEvent> = new Signal();
	public var onReleased:Signal<MouseReleasedEvent> = new Signal();
	public var onMove:Signal<MouseMoveEvent> = new Signal();
	public var onWheelChange:Signal<MouseWheelEvent> = new Signal();
	
	public var mouseWheel(get, null):Int;

	public function new() 
	{
		super();
		
		name = "Mouse Input";
		
		var mouse = Mouse.get(0);
		if(mouse != null) {
			mouse.notify(mouseDownListener, mouseUpListener, mouseMoveListener, mouseWheelListener);
		} else {
			trace("No mouse of index 0 found");
		}
	}
	
	private function mouseDownListener(index:Int, x:Int, y:Int) {
		var gamePosition:Vector2 = Application.screenToGamePosition(new Vector2(x, y));
		_position.x = gamePosition.x;
		_position.y = gamePosition.y;
		_posDelta.x = 0;
		_posDelta.y = 0;
		buttonData.set(index, PRESSED);
		pressedQueue.push(index);
		onPressed.dispatch({index: index, x: x, y: y});
	}
	
	private function mouseUpListener(index:Int, x:Int, y:Int) {
		var gamePosition:Vector2 = Application.screenToGamePosition(new Vector2(x, y));
		_position.x = gamePosition.x;
		_position.y = gamePosition.y;
		_posDelta.x = 0;
		_posDelta.y = 0;
		buttonData.set(index, RELEASED);
		releasedQueue.push(index);
		onReleased.dispatch({index: index, x: x, y: y});
	}
	
	private function mouseMoveListener(x:Int, y:Int, deltaX:Int, deltaY:Int) {
		var gamePosition:Vector2 = Application.screenToGamePosition(new Vector2(x, y));
		_position.x = gamePosition.x;
		_position.y = gamePosition.y;
		_posDelta.x = deltaX;
		_posDelta.y = deltaY;
		onMove.dispatch({x: x, y: y, deltaX: deltaX, deltaY: deltaY});
	}
	
	private function mouseWheelListener(delta:Int) {
		mouseWheel = delta;
		onWheelChange.dispatch({delta: delta});
	}
	
	public function buttonDown(buttonValue:Int):Bool {
		var state:InputState = buttonData.get(buttonValue);
		return state == DOWN || state == PRESSED;
	}
	
	public function buttonUp(buttonValue:Int):Bool {
		var state:InputState = buttonData.get(buttonValue);
		return state == UP || state == RELEASED;
	}
	
	public function buttonPressed(buttonValue:Int):Bool {
		return buttonData.get(buttonValue) == PRESSED;
	}
	
	public function buttonReleased(buttonValue:Int):Bool {
		return buttonData.get(buttonValue) == RELEASED;
	}
	
	override public function update(delta:Float) {
		super.update(delta);
		
		checkQueue(releasedQueue, UP);
		checkQueue(pressedQueue, DOWN);
		
		mouseWheel = 0;
	}
	
	private function checkQueue(queue:Array<Int>, state:InputState) {
		var key:String;
		while (queue.length > 0) {
			var key = queue.pop();
			if (buttonData.exists(key)) {
				buttonData.set(key, state);
			}
		}
	}
	
	public function get_x():Float {
		return _position.x;
	}

	public function get_y():Float {
		return _position.y;
	}

	public function get_position():Vector2 {
		return new Vector2(_position.x, _position.y);
	}

	public function get_posDelta():Vector2 {
		return new Vector2(_posDelta.x, _posDelta.y);
	}
	
	public function get_mouseWheel():Int {
		return this.mouseWheel;
	}
	
	public function clearInput() {
		var buttons = buttonData.keys();
		for (button in buttons) {
			buttonData.set(button, UP);
		}
		
		while (releasedQueue.length > 0) {
			releasedQueue.pop();
		}
		while (pressedQueue.length > 0) {
			pressedQueue.pop();
		}
	}
}