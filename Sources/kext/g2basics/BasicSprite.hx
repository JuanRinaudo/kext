package kext.g2basics;

import kext.Application;

import kha.Color;
import kha.Image;

import kha.math.Vector2;
import kha.math.FastMatrix3;

import kext.math.Rectangle;
import kext.math.BoundingRect;

import kext.loaders.AtlasLoader.FrameData;

class BasicSprite extends Basic {

	public var position:Vector2;
	public var scale:Vector2;
	public var rotation:Float;

	public var origin:Vector2;
	public var bounds:BoundingRect;

	public var box:Vector2;

	private var transform:FastMatrix3;
	public var image:Image;
	public var subimage:Rectangle;
	public var frame:FrameData;

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
		frame = null;

		origin = new Vector2(0, 0);
		
		if(image != null) {
			box = new Vector2(image.width, image.height);
		} else {
			box = new Vector2(0, 0);
		}

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
		setSubimageRectangle(new Rectangle(x, y, width, height));
	}

	public function setSubimageRectangle(rectangle:Rectangle, sourceDelta:Vector2 = null) {
		frame = null;
		subimage = rectangle;
		if(sourceDelta != null) {
			box.x = rectangle.width + sourceDelta.x;
			box.y = rectangle.height + sourceDelta.y;
		} else {
			box.x = rectangle.width;
			box.y = rectangle.height;
		}
		centerOrigin();
	}

	public inline function setFrame(frame:FrameData) {
		image = frame.image;
		setSubimageRectangle(frame.rectangle, frame.sourceDelta);
		this.frame = frame;
	}

	public function centerOrigin() {
		origin.x = box.x * 0.5;
		origin.y = box.y * 0.5;
	}

	public function getScaleToSize(width:Float, height:Float) {
		var scaleX:Float = width / image.width;
		var scaleY:Float = height / image.height;
		var scale = Math.max(scaleX, scaleY);
		return scale;
	}

	public static function fromFrame(x:Float, y:Float, frame:FrameData) {
		var sprite:BasicSprite = new BasicSprite(x, y, frame.image);
		sprite.setSubimageRectangle(frame.rectangle);
		return sprite;
	}

}