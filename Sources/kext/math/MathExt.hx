package kext.math;

import kha.math.Vector3;
import kha.math.Vector4;

class MathExt {

	public static inline function clamp(value:Float, min:Float, max:Float):Float {
		return Math.max(Math.min(value, max), min);
	}

	public static inline function eulerToQuaternion(euler:Vector3):Vector4 {
		var cr:Float = Math.cos(euler.x * 0.5);
		var sr:Float = Math.sin(euler.x * 0.5);
		var cp:Float = Math.cos(euler.y * 0.5);
		var sp:Float = Math.sin(euler.y * 0.5);
		var cy:Float = Math.cos(euler.z * 0.5);
		var sy:Float = Math.sin(euler.z * 0.5);

		return new Vector4(
			cy * sr * cp - sy * cr * sp,
			cy * cr * sp + sy * sr * cp,
			sy * cr * cp - cy * sr * sp,
			cy * cr * cp + sy * sr * sp
		);
	}

	public static inline function quaternionToEuler(quaternion:Vector4):Vector3 {
		var roll:Float = 0; // roll (x-axis rotation)
		var pitch:Float = 0; // pitch (y-axis rotation)
		var yaw:Float = 0; // yaw (z-axis rotation)
		
		var sinr:Float = 2.0 * (quaternion.w * quaternion.x + quaternion.y * quaternion.z);
		var cosr:Float = 1.0 - 2.0 * (quaternion.x * quaternion.x + quaternion.y * quaternion.y);
		roll = Math.atan2(sinr, cosr);

		var sinp:Float = 2.0 * (quaternion.w * quaternion.y - quaternion.z * quaternion.x);
		if (Math.abs(sinp) >= 1)
			pitch = Math.PI / 2 * (sinp >= 0 ? 1 : -1); // use 90 degrees if out of range
		else
			pitch = Math.asin(sinp);

		var siny:Float = 2.0 * (quaternion.w * quaternion.z + quaternion.x * quaternion.y);
		var cosy:Float = 1.0 - 2.0 * (quaternion.y * quaternion.y + quaternion.z * quaternion.z);  
		yaw = Math.atan2(siny, cosy);

		return new Vector3(roll, pitch, yaw);
	}

}