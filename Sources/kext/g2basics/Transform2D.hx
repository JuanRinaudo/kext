package kext.g2basics;

import kha.math.Vector2;
import kha.math.FastMatrix3;

class Transform2D {
	
	//Read only vectors
	public var position(get, null):Vector2;
	public var scale(get, null):Vector2;
	public var origin(get, null):Vector2;
	private var _position(default, null):Vector2;
	private var _scale(default, null):Vector2;
	private var _origin(default, null):Vector2;

	private var transform:FastMatrix3;
	private var dirty:Bool = true;

	public var x(get, set):Float;
	public var y(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var originX(get, set):Float;
	public var originY(get, set):Float;
	public var angle(default, set):Float;

	public function new(position:Vector2, scale:Vector2, angle:Float = 0, origin:Vector2 = null) {
		_position = position;
		_scale = scale;
		this.angle = angle;
		_origin = origin;

		if(_origin == null) {
			_origin = new Vector2(0, 0);
		}
		
		transform = FastMatrix3.identity();
		dirty = true;
	}

	public function getMatrix():FastMatrix3 {
		if(dirty) {
			transform._00 = _scale.x;
			transform._11 = _scale.y;
			transform._20 = _position.x - _origin.x * _scale.x;
			transform._21 = _position.y - _origin.y * _scale.y;
			dirty = false;
		}
		return transform;
	}

	public inline function get_x():Float {
		return _position.x;
	}

	public inline function set_x(value:Float):Float {
		_position.x = value;
		dirty = true;
		return _position.x;
	}

	public inline function get_y():Float {
		return _position.y;
	}

	public inline function set_y(value:Float):Float {
		_position.y = value;
		dirty = true;
		return _position.y;
	}

	public inline function get_scaleX():Float {
		return _scale.x;
	}

	public inline function set_scaleX(value:Float):Float {
		_scale.x = value;
		dirty = true;
		return _scale.x;
	}

	public inline function get_scaleY():Float {
		return _scale.y;
	}

	public inline function set_scaleY(value:Float):Float {
		_scale.y = value;
		dirty = true;
		return _scale.y;
	}
	
	public inline function get_originX():Float {
		return _origin.x;
	}

	public inline function set_originX(value:Float):Float {
		_origin.x = value;
		dirty = true;
		return _origin.x;
	}

	public inline function get_originY():Float {
		return _origin.y;
	}

	public inline function set_originY(value:Float):Float {
		_origin.y = value;
		dirty = true;
		return _origin.y;
	}

	public inline function set_angle(value:Float):Float {
		angle = value;
		dirty = true;
		return angle;
	}

	public inline function get_position():Vector2 {
		return new Vector2(x, y);
	}
	
	public inline function get_scale():Vector2 {
		return new Vector2(scaleX, scaleY);
	}

	public inline function get_origin():Vector2 {
		return new Vector2(originX, originY);
	}

	public static function fromFloats(x:Float = 0, y:Float = 0, scaleX:Float = 1, scaleY:Float = 1,
		angle:Float = 0, originX:Float = 0, originY:Float = 0):Transform2D {
		return new Transform2D(new Vector2(x, y), new Vector2(scaleX, scaleY), angle, new Vector2(originX, originY));
	}

}