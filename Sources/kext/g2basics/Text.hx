package kext.g2basics;

import kha.Color;
import kha.Image;
import kha.Font;

import kha.math.Vector2;
import kha.math.FastMatrix3;

using Alignment.HorizontalAlign;
using Alignment.VerticalAlign;

class Text extends Basic {

	public var position:Vector2;
	public var width:Float;
	public var height:Float;
	
	public var text(default, set):String = "";
	public var fontSize:Int;
	public var font:Font;

	public var color:Color;

	private var transform:FastMatrix3;

	private var textLines:Array<String>;
	private var offsetByLine:Array<Vector2>;

	public var horizontalTextAlign:HorizontalAlign;
	public var verticalTextAlign:VerticalAlign;

	public function new(x:Float, y:Float, areaWidth:Float, areaHeight:Float, label:String = "") {
		super();

		position = new Vector2(x, y);

		width = areaWidth;
		height = areaHeight;

		horizontalTextAlign = MIDDLE;
		verticalTextAlign = MIDDLE;

		font = Application.defaultFont;
		fontSize = Application.defaultFontSize;
		text = label;

		color = Color.White;

		transform = FastMatrix3.identity();
	}

	override public function update(delta:Float) {
		
	}

	override public function render(backbuffer:Image) {
		var i = 0;
		for(line in textLines) {
			transform._20 = position.x + offsetByLine[i].x - width * 0.5;
			transform._21 = position.y + offsetByLine[i].y - height * 0.5;

			backbuffer.g2.transformation = transform;
			backbuffer.g2.font = font;
			backbuffer.g2.fontSize = fontSize;
			backbuffer.g2.color = color;
			backbuffer.g2.drawString(line, 0, 0);
			i++;
		}
	}

	public function set_text(value:String):String {
		text = value;

		textLines = text.split("\n");
		offsetByLine = [];
		var x:Float = 0;
		var y:Float = 0;
		var lineWidth:Float = 0;
		var i = 0;
		for(line in textLines) {
			lineWidth = font.width(fontSize, line);
			y = fontSize * i;
			switch(horizontalTextAlign) {
				case LEFT:
					x = 0;
				case MIDDLE:
					x = (width - lineWidth) / 2;
				case RIGHT:
					x = width - lineWidth;
			}
			switch(verticalTextAlign) {
				case TOP:
					y += 0;
				case MIDDLE:
					y += (height - fontSize * textLines.length) / 2;
				case BOTTOM:
					y += height - fontSize * textLines.length;
			}
			offsetByLine.push(new Vector2(x, y));
			i++;
		}
		
		return text;
	}

}