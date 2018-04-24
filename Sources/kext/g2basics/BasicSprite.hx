package kext.g2basics;

import kha.Color;
import kha.Image;

import kha.math.Vector2;

import kext.math.Rectangle;
import kext.math.BoundingRect;

import kext.loaders.AtlasLoader.FrameData;

class BasicSprite extends Basic {

	public var transform:Transform2D;

	public var bounds:BoundingRect;

	public var box:Vector2;

	public var image:Image;
	public var subimage:Rectangle;
	public var frame:FrameData;

	public var color:Color;

	public var exists:Bool;

	public function new(x:Float, y:Float, spriteImage:Image) {
		super();

		transform = Transform2D.fromFloats(x, y, 1, 1, 0);

		image = spriteImage;
		subimage = null;
		frame = null;
		
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
		backbuffer.g2.transformation = transform.getMatrix();

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
		box.x = rectangle.width;
		box.y = rectangle.height;
		centerOrigin(sourceDelta);
	}

	public inline function setFrame(frame:FrameData) {
		image = frame.image;
		setSubimageRectangle(frame.rectangle, frame.sourceDelta);
		this.frame = frame;
	}

	public function centerOrigin(offset:Vector2 = null) {
		if(offset == null) { offset = new Vector2(0, 0); }
		transform.originX = box.x * 0.5 + offset.x * 0.5;
		transform.originY = box.y * 0.5 + offset.y * 0.5;
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