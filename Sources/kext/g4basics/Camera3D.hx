package kext.g4basics;

import kha.input.KeyCode;
import kha.math.Vector3;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

import kext.g4basics.Transform3D;

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
	
	public var forward:FastVector3;
	public var lastLookVector:FastVector3;
    
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
		lookAtVector(new FastVector3(0, 0, 0), new FastVector3(0, 0, 0));
    }

    private inline function lookAtVector(to:FastVector3, ?lookUpVector:FastVector3) {
		lastLookVector = to;
		viewMatrix = FastMatrix4.lookAt(transform.position.fast(), to, lookUpVector != null ? lookUpVector : upVector);
		forward = to.sub(transform.position.fast());
		forward.normalize();
	}

	public function lookAt(to:FastVector3, ?lookUpVector:FastVector3)
	{
		lookAtVector(to, lookUpVector);
	}

	public function lookAtXYZ(toX:Float, toY:Float, toZ:Float, ?lookUpVector:FastVector3) {
		lookAtVector(new FastVector3(toX, toY, toZ), lookUpVector);
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

	public function freecamera(speed:Float = 1, rotationsSpeed:Float = 5)
	{
		if(Application.keyboard.keyDown(KeyCode.Shift)) {
			speed *= 10;
			rotationsSpeed *= 5;
		}

		if(Application.mouse.buttonDown(0) && Application.screenRect.pointInside(Application.mouse.position)) {
			transform.rotateXYZ(Application.mouse.posDelta.y * rotationsSpeed * Application.deltaTime, Application.mouse.posDelta.x * rotationsSpeed * Application.deltaTime, 0);
		}

		var moveSpeed:Float = 0;
		var lateralMoveSpeed:Float = 0;
		if(Application.keyboard.keyDown(KeyCode.W)) {
			moveSpeed = speed * Application.deltaTime;
		}
		else if(Application.keyboard.keyDown(KeyCode.S)) {
			moveSpeed = -speed * Application.deltaTime;
		}

		if(Application.keyboard.keyDown(KeyCode.A)) {
			lateralMoveSpeed = speed * Application.deltaTime;
		}
		else if(Application.keyboard.keyDown(KeyCode.D)) {
			lateralMoveSpeed = -speed * Application.deltaTime;	
		}
		
		transform.translate(transform.forward.mult(moveSpeed));
		transform.translate(transform.left.mult(lateralMoveSpeed));
		
		lookAt(transform.position.fast().add(transform.forward.fast()));
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