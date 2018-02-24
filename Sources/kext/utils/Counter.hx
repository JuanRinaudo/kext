package kext.utils;

class Counter {

	public var cicleValue:Float = 0; 
	public var tickValue:Float = 0;
	public var currentValue:Float = 0;
	public var cicleCallback:Void -> Void;

	public function new(value:Float, tick:Float, callback:Void->Void, startValue:Float = 0) {
		cicleValue = value;
		tickValue = tick;
		currentValue = startValue;
		cicleCallback = callback;
	}

	public function tick() {
		currentValue += tickValue;
		if(currentValue > cicleValue) {
			currentValue -= cicleValue;
			cicleCallback();
		} 
	}

	public function restart() {
		currentValue = 0;
	}

}