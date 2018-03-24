package kext.g2basics;

import kext.Application;

import kha.Color;
import kha.Image;

import kha.math.Vector2;
import kha.math.FastMatrix3;

import kext.math.Rectangle;
import kext.math.BoundingRect;

class BasicSprite extends Basic {

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

	public var exists:Bool;

	public function new(x:Float, y:Float, spriteImage:Image) {
		super();

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

		exists = true;
	}

	override public function render(backbuffer:Image) {
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
		box.x = width;
		box.y = height;
		centerOrigin();
		bounds.setScaleFromCenter();
	}

	public function centerOrigin() {
		if(subimage != null) {
			origin.x = subimage.width * 0.5;
			origin.y = subimage.height * 0.5;
		} else {
			origin.x = image.width * 0.5;
			origin.y = image.height * 0.5;
		}
	}

	public function getScaleToSize(width:Float, height:Float) {
		var scaleX:Float = width / image.width;
		var scaleY:Float = height / image.height;
		var scale = Math.max(scaleX, scaleY);
		return scale;
	}

}