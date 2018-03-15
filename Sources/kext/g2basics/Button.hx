package kext.g2basics;

import kha.Image;
import kha.Font;
import kha.math.Vector2;

class Button extends BasicSprite {

	private var text:String = "";
	private var textSize:Int = 12;
	private var font:Font;

	public function new(x:Float, y:Float, image:Image, label:String = "") {
		super(x, y, image);

		text = label;
		font = Application.defaultFont;
	}

	override public function update(delta:Float) {
		
	}

	override public function render(backbuffer:Image) {
		super.render(backbuffer);

		if(text != "") {
			backbuffer.g2.font = font;
			backbuffer.g2.fontSize = textSize;
			backbuffer.g2.drawString(text, 0, 0);
		}
	}

	public inline function inputPressed(inputVector:Vector2):Bool {
		if(inputVector == null) { inputVector = Application.mouse.mousePosition; }
		return Application.mouse.buttonPressed(0) && bounds.checkVectorOverlap(inputVector);
	}

	public inline function inputDown(inputVector:Vector2):Bool {
		if(inputVector == null) { inputVector = Application.mouse.mousePosition; }
		return Application.mouse.buttonDown(0) && bounds.checkVectorOverlap(inputVector);
	}

}