package kext.g2basics;

import kha.Image;
import kha.math.FastMatrix3;

class BasicTileset extends BasicSprite {

    public var width:UInt;
    public var height:UInt;
    public var tileWidth:UInt;
    public var tileHeight:UInt;
    public var tilesetWidth:UInt;
    public var tilesetHeight:UInt;
    public var data:Array<UInt>;

	public function new(x:Float, y:Float, spriteImage:Image) {
		super(x, y, spriteImage);

        width = 0;
        height = 0;
        tileWidth = 0;
        tileHeight = 0;
        data = null;

        transform.originX = transform.originY = 0;
    }

    public function setupTiledata(width:UInt, height:UInt, tileWidth:UInt, tileHeight:UInt, initialValue:UInt) {
        this.width = width;
        this.height = height;
        this.tileWidth = tileWidth;
        this.tileHeight = tileHeight;
        tilesetWidth = Math.round(image.width / tileWidth);
        tilesetHeight = Math.round(image.height / tileHeight);

        data = [for(i in 0...height) { for(j in 0...width) { initialValue; } }];
    }

	override public function render(backbuffer:Image) {
		backbuffer.g2.color = color;
		var matrix:FastMatrix3 = transform.getMatrix();

        var value:UInt = 0;
        for(i in 0...height) {
            for(j in 0...width) {
                value = data[i * width + j];
                if(value != -1) {
                    matrix._20 += j * tileWidth; //Translate
                    matrix._21 += i * tileHeight;
		            backbuffer.g2.pushTransformation(backbuffer.g2.transformation.multmat(matrix));
                    backbuffer.g2.drawSubImage(image, 0, 0, (value % tilesetWidth) * tileWidth, Math.floor(value / tilesetHeight) * tileHeight , tileWidth, tileHeight);
                    backbuffer.g2.popTransformation();
                    matrix._20 -= j * tileWidth; //RestoreTranslation
                    matrix._21 -= i * tileHeight;
                }
            }
        }

		#if debug
		kext.debug.Debug.drawBounds(backbuffer, bounds);
		#end
	}

}