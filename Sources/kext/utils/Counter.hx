package kext.utils;

class Counter {

	public var targetValue:Float = 0; 
	public var tickDelta:Float = 0;
	public var currentValue:Float = 0;
	public var callback:Void -> Void;
	public var loop:Bool;
	public var running:Bool;

	public function new(toValue:Float, tickValue:Float, endCallback:Void->Void, doLoop:Bool = false, startValue:Float = 0) {
		targetValue = toValue;
		tickDelta = tickValue;
		currentValue = startValue;
		callback = endCallback;
		loop = doLoop;
		running = true;
	}

	public function tick() {
		if(running) {
			currentValue += tickDelta;
			if(currentValue > targetValue) {
				if(loop) { currentValue -= targetValue; }
				else { running = false; }
				callback();
			}
		}
	}

	public function done() {
		return running == false;
	}

	public function restart(startValue:Float = 0) {
		currentValue = startValue;
		running = true;
	}

}