package kext.g4basics;

import kext.g4basics.Transform3D;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

class Camera3D extends Basic {

    public var orthogonalPerspective:Bool;
    public var size:Float;
    public var fovY:Float;
    public var aspectRatio:Float;
    public var viewMatrix:FastMatrix4;
    public var projectionMatrix:FastMatrix4;
    public var projectionViewMatrix(get, null):FastMatrix4;

    public var nearPlane(default, set):Float;
	public var farPlane(default, set):Float;

    public var transform:Transform3D;
    
#if js
	public var upVector:FastVector3 = new FastVector3(0, 1, 0);
#else
	public var upVector:FastVector3 = new FastVector3(0, -1, 0);
#end

    public function new() {
        super();

        orthogonalPerspective = false;
        size = 0;
        fovY = 0;
        aspectRatio = 0;
        viewMatrix = null;
        projectionMatrix = null;
    
		nearPlane = 0.1;
		farPlane = 100;

        transform = new Transform3D();

		perspective(45, 1);
		lookAt(new FastVector3(0, 0, -1).mult(10), new FastVector3(0, 0, 0));
    }

    public function lookAt(from:FastVector3, to:FastVector3) {
		viewMatrix = FastMatrix4.lookAt(from, to, upVector);
	}

	public function lookAtXYZ(fromX:Float, fromY:Float, fromZ:Float, toX:Float, toY:Float, toZ:Float) {
		viewMatrix = FastMatrix4.lookAt(new FastVector3(fromX, fromY, fromZ), new FastVector3(toX, toY, toZ), upVector);
	}

	public function orthogonal(size:Float, aspectRatio:Float) {
		orthogonalPerspective = true;
		this.size = size;
		this.aspectRatio = aspectRatio;
		projectionMatrix = FastMatrix4.orthogonalProjection(-size * aspectRatio, size * aspectRatio, -size, size, farPlane, nearPlane);
	}

	public function perspective(fovY:Float, aspectRatio:Float) {
		orthogonalPerspective = false;
		this.fovY = fovY;
		this.aspectRatio = aspectRatio;
		projectionMatrix = FastMatrix4.perspectiveProjection(fovY, aspectRatio, farPlane, nearPlane);
	}

	private inline function refreshCamera() {
		if(orthogonalPerspective) {
			orthogonal(size, aspectRatio);
		} else {
			perspective(fovY, aspectRatio);
		}
	}

	public function set_nearPlane(value:Float):Float {
		nearPlane = value;
		refreshCamera();
		return nearPlane;
	}

	public function set_farPlane(value:Float):Float {
		farPlane = value;
		refreshCamera();
		return farPlane;
	}

    public inline function get_projectionViewMatrix():FastMatrix4 {
        return projectionMatrix.multmat(viewMatrix);
    }

}