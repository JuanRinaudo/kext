package kext.utils;

class Countdown {

	public var targetValue:Float = 0; 
	public var tickValue:Float = 0;
	public var currentValue:Float = 0;

	public function new(value:Float, tick:Float, startValue:Float = 0) {
		targetValue = value;
		tickValue = tick;
		currentValue = startValue;
	}

	public inline function tick() {
		currentValue = Math.max(currentValue - tickValue, 0);
	}

	public inline function done():Bool {
		return currentValue == 0; 
	}

	public inline  function start() {
		currentValue = targetValue;
	}

}