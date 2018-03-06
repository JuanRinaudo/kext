package kext.g2basics;

import kext.Application;

import kha.Color;
import kha.Image;

import kha.math.Vector2;
import kha.math.FastMatrix3;

import kext.math.Rectangle;
import kext.math.BoundingRect;

class BasicSprite {

	public var position:Vector2;
	public var scale:Vector2;
	public var rotation:Float;

	public var origin:Vector2;
	public var bounds:BoundingRect;

	public var box:Vector2;

	public var transform:FastMatrix3;
	public var image:Image;
	public var subimage:Rectangle;

	public var color:Color;

	public function new(x:Float, y:Float, spriteImage:Image) {
		position = new Vector2(x, y);
		scale = new Vector2(1, 1);
		rotation = 0;

		transform = FastMatrix3.identity();
		image = spriteImage;
		subimage = null;

		origin = new Vector2(0, 0);
		box = new Vector2(image.width, image.height);

		color = Color.White;
		centerOrigin();

		bounds = BoundingRect.fromSprite(this);
	}

	public function draw(backbuffer:Image) {
		backbuffer.g2.color = color;

		transform._00 = scale.x;
		transform._11 = scale.y;
		transform._20 = position.x - origin.x * scale.x;
		transform._21 = position.y - origin.y * scale.y;

		backbuffer.g2.transformation = transform;
		if(subimage != null) {
			backbuffer.g2.drawSubImage(image, 0, 0, subimage.x, subimage.y, subimage.width, subimage.height);
		} else {
			backbuffer.g2.drawImage(image, 0, 0);
		}

		#if debug
			kext.debug.Debug.drawBounds(backbuffer, bounds);
		#end
	}

	public inline function setSubimage(x:Float, y:Float, width:Float, height:Float) {
		subimage = new Rectangle(x, y, width, height);
	}

	public inline function inputPressed(inputVector:Vector2):Bool {
		if(inputVector == null) { inputVector = Application.mouse.mousePosition; }
		return Application.mouse.buttonPressed(0) && bounds.checkVectorOverlap(inputVector);
	}

	public inline function inputDown(inputVector:Vector2):Bool {
		if(inputVector == null) { inputVector = Application.mouse.mousePosition; }
		return Application.mouse.buttonDown(0) && bounds.checkVectorOverlap(inputVector);
	}

	public function centerOrigin() {
		origin.x = image.width * 0.5;
		origin.y = image.height * 0.5;
	}

}