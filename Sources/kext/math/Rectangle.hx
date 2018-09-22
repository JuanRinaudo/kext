package kext.math;

import kha.math.Vector2;

@:structInit
class Rectangle
{
	
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	
	public inline function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0): Void {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public inline function scale(x:Float, y:Float):Rectangle {
		return new Rectangle(x * x, y * y, width * x, height * y);
	}

	public inline function pointInside(vector:Vector2) {
		if(vector.x < x || vector.x > x + width) { return false; }
		if(vector.y < y || vector.y > y + height) { return false; }
		
		return true;
	}
	
	public function toString():String {
		return "{x: " + x + ", y: " + y + ", width: " + width + ", height: " + height + "}";
	}
	
}