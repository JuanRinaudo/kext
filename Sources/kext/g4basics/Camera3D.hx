package kext.g4basics;

import kha.math.Vector3;
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
    
	public var upVector:FastVector3 = new FastVector3(0, 1, 0);

    public function new() {
        super();

        orthogonalPerspective = false;
        size = 0;
        fovY = 0;
        aspectRatio = 0;
        viewMatrix = null;
        projectionMatrix = null;
    
		nearPlane = 0.1;
		farPlane = 5000;

        transform = new Transform3D();
		transform.setPosition(new Vector3(0, -10, -10));

		perspective(Math.PI * 0.5, 1);
		lookAt(transform.position.fast(), new FastVector3(0, 0, 0));
    }

    public function lookAt(to:FastVector3, lookUpVector:FastVector3 = null) {
		viewMatrix = FastMatrix4.lookAt(transform.position.fast(), to, lookUpVector != null ? lookUpVector : upVector);
	}

	public function lookAtXYZ(toX:Float, toY:Float, toZ:Float) {
		viewMatrix = FastMatrix4.lookAt(transform.position.fast(), new FastVector3(toX, toY, toZ), upVector);
	}

	public function orthogonal(size:Float, aspectRatio:Float) {
		orthogonalPerspective = true;
		this.size = size;
		this.aspectRatio = aspectRatio;
		projectionMatrix = FastMatrix4.orthogonalProjection(-size * aspectRatio, size * aspectRatio, -size, size, nearPlane, farPlane);
	}

	public function perspective(fovY:Float, aspectRatio:Float) {
		orthogonalPerspective = false;
		this.fovY = fovY;
		this.aspectRatio = aspectRatio;
		projectionMatrix = FastMatrix4.perspectiveProjection(fovY, aspectRatio, nearPlane, farPlane);
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