package kext.g4basics;

import kha.math.Vector3;
import kha.math.Vector4;
import kha.math.FastMatrix4;

import kext.math.MathExt;

class Transform3D {
	
	//Read only vectors
	public var position(get, null):Vector3;
	public var scale(get, null):Vector3;
	public var origin(get, null):Vector3;
	public var rotationEuler(get, null):Vector3;
	public var rotationQuaternion(get, null):Vector4;
	private var _position(default, null):Vector3;
	private var _scale(default, null):Vector3;
	private var _origin(default, null):Vector3;
	private var _rotation(default, null):Vector3;

	private var transform:FastMatrix4;
	private var dirty:Bool = true;

	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var scaleZ(get, set):Float;
	public var originX(get, set):Float;
	public var originY(get, set):Float;
	public var originZ(get, set):Float;
	public var rotationX(get, set):Float;
	public var rotationY(get, set):Float;
	public var rotationZ(get, set):Float;

	public function new(position:Vector3 = null, scale:Vector3 = null, rotation:Vector3 = null, origin:Vector3 = null) {
		_position = position;
		_scale = scale;
		_origin = origin;
		_rotation = rotation;

		if(_position == null) { _position = new Vector3(0, 0, 0); }
		if(_scale == null) { _scale = new Vector3(1, 1, 1); }
		if(_origin == null) { _origin = new Vector3(0, 0, 0); }
		if(_rotation == null) { _rotation = new Vector3(0, 0, 0); }
	
		transform = FastMatrix4.identity();
		dirty = true;
	}

	public function fromMatrix(transform:FastMatrix4) {
		_scale.x = transform._00;
		_scale.y = transform._11;
		_scale.z = transform._22;
		_position.x = transform._30;
		_position.y = transform._31;
		_position.z = transform._32;
		dirty = true;
	}

	public function getMatrix():FastMatrix4 {
		if(dirty) {
			transform = FastMatrix4.identity();
			transform._00 = _scale.x;
			transform._11 = _scale.y;
			transform._22 = _scale.z;
			transform._30 = _position.x - _origin.x * _scale.x;
			transform._31 = _position.y - _origin.y * _scale.y;
			transform._32 = _position.z - _origin.z * _scale.z;
			transform = transform.multmat(FastMatrix4.rotation(_rotation.x, _rotation.y, _rotation.z));
			dirty = false;
		}
		return transform;
	}
	
	public inline function translate(delta:Vector3) {
		_position.x += delta.x;
		_position.y += delta.y;
		_position.z += delta.z;
		dirty = true;
	}

	public inline function scaleTransform(delta:Vector3) {
		_scale.x *= delta.x;
		_scale.y *= delta.y;
		_scale.z *= delta.z;
		dirty = true;
	}

	public inline function rotate(delta:Vector3) {
		_rotation.x += delta.x;
		_rotation.y += delta.y;
		_rotation.z += delta.z;
		dirty = true;
	}

	public inline function setPositionXYZ(x:Float, y:Float, z:Float) {
		_position.x = x;
		_position.y = y;
		_position.z = z;
		dirty = true;
	}

	public inline function setPosition(value:Vector3) {
		_position.x = value.x;
		_position.y = value.y;
		_position.z = value.z;
		dirty = true;
	}

	public inline function setScaleXYZ(x:Float, y:Float, z:Float) {
		_scale.x = x;
		_scale.y = y;
		_scale.z = z;
		dirty = true;
	}

	public inline function setScale(value:Vector3) {
		_scale.x = value.x;
		_scale.y = value.y;
		_scale.z = value.z;
		dirty = true;
	}
	
	public inline function setRotationXYZ(x:Float, y:Float, z:Float) {
		_rotation.x = x;
		_rotation.y = y;
		_rotation.z = z;
		dirty = true;
	}

	public inline function setRotation(value:Vector3) {
		_rotation.x = value.x;
		_rotation.y = value.y;
		_rotation.z = value.z;
		dirty = true;
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

	public inline function get_z():Float {
		return _position.z;
	}

	public inline function set_z(value:Float):Float {
		_position.z = value;
		dirty = true;
		return _position.z;
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

	public inline function get_scaleZ():Float {
		return _scale.z;
	}

	public inline function set_scaleZ(value:Float):Float {
		_scale.z = value;
		dirty = true;
		return _scale.z;
	}
	
	public inline function get_rotationX():Float {
		return _rotation.x;
	}

	public inline function set_rotationX(value:Float):Float {
		_rotation.x = value;
		dirty = true;
		return _rotation.x;
	}

	public inline function get_rotationY():Float {
		return _rotation.y;
	}

	public inline function set_rotationY(value:Float):Float {
		_rotation.y = value;
		dirty = true;
		return _rotation.y;
	}

	public inline function get_rotationZ():Float {
		return _rotation.z;
	}

	public inline function set_rotationZ(value:Float):Float {
		_rotation.z = value;
		dirty = true;
		return _rotation.z;
	}
	
	public inline function get_originX():Float {
		return _rotation.x;
	}

	public inline function set_originX(value:Float):Float {
		_rotation.x = value;
		dirty = true;
		return _rotation.x;
	}

	public inline function get_originY():Float {
		return _origin.y;
	}

	public inline function set_originY(value:Float):Float {
		_origin.y = value;
		dirty = true;
		return _origin.y;
	}

	public inline function get_originZ():Float {
		return _origin.z;
	}

	public inline function set_originZ(value:Float):Float {
		_origin.z = value;
		dirty = true;
		return _origin.z;
	}

	public inline function get_position():Vector3 {
		return new Vector3(_position.x, _position.y, _position.z);
	}
	
	public inline function get_scale():Vector3 {
		return new Vector3(_scale.x, _scale.y, _scale.z);
	}

	public inline function get_origin():Vector3 {
		return new Vector3(_origin.x, _origin.y, _origin.z);
	}

	public inline function get_rotationEuler():Vector3 {
		return new Vector3(_rotation.x, _rotation.y, _rotation.z);
	}

	public inline function get_rotationQuaternion():Vector4 {
		return MathExt.eulerToQuaternion(_rotation);
	}

	public static function fromFloats(x:Float = 0, y:Float = 0, z:Float = 0,
		scaleX:Float = 1, scaleY:Float = 1, scaleZ:Float = 1,
		rotationX:Float = 0, rotationY:Float = 0, rotationZ:Float = 0,
		originX:Float = 0, originY:Float = 0, originZ:Float = 0):Transform3D {
		return new Transform3D(
			new Vector3(x, y, z),
			new Vector3(scaleX, scaleY, scaleZ),
			new Vector3(rotationX, rotationY, rotationZ),
			new Vector3(originX, originY, originZ)
		);
	}

}