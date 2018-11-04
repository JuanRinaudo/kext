package kext.g4basics;

import kha.graphics4.MipMapFilter;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureUnit;
import kha.Image;

class Texture {

    public var image:Image;
    public var textureUnit:TextureUnit;
    public var textureUnitName:String;

    public var verticalAddresing:TextureAddressing;
    public var horizontalAddresing:TextureAddressing;
    public var minificationFilter:TextureFilter;
    public var magnificationFilter:TextureFilter;
    public var mipMapFilter:MipMapFilter;

    public function new(image:Image, textureUnitName:String) {
        this.image = image;
        textureUnit = null;
        this.textureUnitName = textureUnitName;

        verticalAddresing = Repeat;
        horizontalAddresing = Repeat;
        minificationFilter = PointFilter;
        magnificationFilter = PointFilter;
        mipMapFilter = NoMipFilter;
    }

}