package kext.g2basics;

import kha.Image;
import kha.Font;
import kha.math.Vector2;

class Button extends BasicSprite {

	public var label:Text;

	public function new(x:Float, y:Float, image:Image, text:String = "", singleAsset:Bool = false) {
		super(x, y, image);

		if(!singleAsset) {
			box.x = image.width;
			box.y = Math.round(image.height / 3);
		}

		label = new Text(x, y, 0, 0, text);
		label.position = position;

		setSubimage(0, 0, box.x, box.y);
		centerOrigin();
	}

	override public function update(delta:Float) {
		var inputVector = Application.mouse.mousePosition;
		if(bounds.checkVectorOverlap(inputVector)) {
			if(Application.mouse.buttonDown(0)) {
				subimage.y = box.y * 2;
			} else {
				subimage.y = box.y;
			}
		} else {
			subimage.y = 0;
		}
	}

	override public function render(backbuffer:Image) {
		super.render(backbuffer);

		label.render(backbuffer);
	}

	public inline function inputPressed(inputVector:Vector2):Bool {
		if(inputVector == null) { inputVector = Application.mouse.mousePosition; }
		return Application.mouse.buttonPressed(0) && bounds.checkVectorOverlap(inputVector);
	}

	public inline function inputReleased(inputVector:Vector2):Bool {
		if(inputVector == null) { inputVector = Application.mouse.mousePosition; }
		return Application.mouse.buttonReleased(0) && bounds.checkVectorOverlap(inputVector);
	}

	public inline function inputDown(inputVector:Vector2):Bool {
		if(inputVector == null) { inputVector = Application.mouse.mousePosition; }
		return Application.mouse.buttonDown(0) && bounds.checkVectorOverlap(inputVector);
	}

}