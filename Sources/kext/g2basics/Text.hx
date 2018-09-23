package kext.g2basics;

import kha.Color;
import kha.Image;
import kha.Font;

import kha.math.Vector2;

using Alignment.HorizontalAlign;
using Alignment.VerticalAlign;

class Text extends Basic {

	public var transform:Transform2D;

	public var width:Float;
	public var height:Float;
	
	public var text(default, set):String = "";
	public var fontSize:Int;
	public var font:Font;

	public var color:Color;

	public var lineSpacing(default, set):Float;

	private var textLines:Array<String>;
	private var offsetByLine:Array<Vector2>;

	public var horizontalAlign:HorizontalAlign;
	public var verticalAlign:VerticalAlign;

	public function new(x:Float = 0, y:Float = 0, areaWidth:Float = 0, areaHeight:Float = 0, label:String = "") {
		super();

		transform = Transform2D.fromFloats(x, y);

		width = areaWidth;
		height = areaHeight;

		horizontalAlign = MIDDLE;
		verticalAlign = MIDDLE;

		font = Application.defaultFont;
		fontSize = Application.defaultFontSize;
		text = label;

		lineSpacing = 1;

		color = Color.White;
	}

	public function setOrigin(x:Float, y:Float) {
		transform.originX = width * x;
		transform.originY = height * y;
	}

	override public function update(delta:Float) {
		
	}

	override public function render(backbuffer:Image) {
		backbuffer.g2.pushTransformation(backbuffer.g2.transformation.multmat(transform.getMatrix()));
		backbuffer.g2.font = font;
		backbuffer.g2.fontSize = fontSize;
		backbuffer.g2.color = color;

		var i = 0;
		for(line in textLines) {
			backbuffer.g2.drawString(line, offsetByLine[i].x, offsetByLine[i].y);
			i++;
		}
		backbuffer.g2.popTransformation();
	}

	private function cacheText() {
		textLines = text.split("\n");
		offsetByLine = [];
		var x:Float = 0;
		var y:Float = 0;
		var lineWidth:Float = 0;
		var i = 0;
		for(line in textLines) {
			lineWidth = font.width(fontSize, line);
			y = fontSize * i * lineSpacing;
			switch(horizontalAlign) {
				case LEFT:
					x = 0;
				case MIDDLE:
					x = (width - lineWidth) / 2;
				case RIGHT:
					x = width - lineWidth;
			}
			switch(verticalAlign) {
				case TOP:
					y += 0;
				case MIDDLE:
					y += (height - fontSize * textLines.length * lineSpacing) / 2;
				case BOTTOM:
					y += height - fontSize * textLines.length * lineSpacing;
			}
			offsetByLine.push(new Vector2(x, y));
			i++;
		}
	}

	public function set_text(value:String):String {
		text = value;
		cacheText();
		return text;
	}

	public function set_lineSpacing(value:Float):Float {
		lineSpacing = value;
		cacheText();
		return lineSpacing;
	}

	private static var cachedText:Text = null;
	public static function renderText(backbuffer:Image, text:String,
	  x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0,
	  font:Font = null, fontSize:Int = -1,
	  horizontalAlign:HorizontalAlign = null, verticalAlign:VerticalAlign = null) {	
		if(cachedText == null) { cachedText = new Text(); }

		cachedText.transform.x = x;
		cachedText.transform.y = y;
		cachedText.width = width;
		cachedText.height = height;

		cachedText.text = text;
		if(font != null) { cachedText.font = font; }
		if(fontSize > 0) { cachedText.fontSize = fontSize; }

		if(horizontalAlign != null) { cachedText.horizontalAlign = horizontalAlign; }
		if(verticalAlign != null) { cachedText.verticalAlign = verticalAlign; }

		cachedText.render(backbuffer);
	}

}