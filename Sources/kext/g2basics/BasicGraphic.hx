package kext.g2basics;

import kha.Color;
import kha.Image;

import kha.math.Vector2;
import kha.math.FastMatrix3;

class BasicSprite {

	public var position:Vector2;
	public var scale:Vector2;
	public var rotation:Float;

	public var origin:Vector2;
	public var box:Vector2;

	public var transform:FastMatrix3;

	public var color:Color;

	public var drawFunction:(Image) -> Void;

	public function new(x:Float, y:Float) {
		position = new Vector2(x, y);
		scale = new Vector2(1, 1);
		rotation = 0;

		origin = new Vector2(0, 0);
		box = new Vector2(0, 0);

		transform = FastMatrix3.identity();
		color = Color.White;

		setDrawRectangle(32, 32);
	}

	public function draw(backbuffer:Image) {
		backbuffer.g2.color = color;

		transform._00 = scale.x;
		transform._11 = scale.y;
		transform._20 = position.x - origin.x * scale.x;
		transform._21 = position.y - origin.y * scale.y;

		backbuffer.g2.transformation = transform;
		drawFunction(backbuffer);
	}

	public function centerOrigin() {
		origin.x = box.x * 0.5;
		origin.y = box.y * 0.5;
	}

	private function drawImage(backbuffer:Image, image:Image) {
		backbuffer.g2.drawImage(image, 0, 0);
	}

	private function drawRectangle(backbuffer:Image, width:Float, height:Float) {
		backbuffer.g2.fillRect(0, 0, width, height);
	}

	public function setDrawRectangle(width:Float, height:Float) {
		drawFunction = drawRectangle.bind(_, width, height);
		box.x = width;
		box.y = height;
	}

	public function setDrawImage(image:Image) {
		drawFunction = drawImage.bind(_, image);
		box.x = image.width;
		box.y = image.height;
	}

}