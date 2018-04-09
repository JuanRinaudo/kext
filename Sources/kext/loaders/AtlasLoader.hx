package kext.loaders;

import haxe.Json;

import kha.Assets;
import kha.Blob;
import kha.Image;

import kext.math.Rectangle;

typedef AtlasData = {
	image:Image,
	frames:Map<String, Rectangle>
}

typedef FrameData = {
	image:Image,
	rectangle:Rectangle
}

class AtlasLoader {

	public static function parse(blob:Blob):AtlasData {
		var json = Json.parse(blob.toString());

		var imageName:String = StringTools.replace(json.meta.image, ".png", "");
		var image:Image = Assets.images.get(imageName);

		var frameMap = new Map<String, Rectangle>();
		var frameList:Array<Dynamic> = json.frames;
		for(frame in frameList) {
			var rectangle:Rectangle = rectangleFromFrame(frame.frame);
			frameMap.set(frame.filename, rectangle);
			Reflect.setField(ExtAssets.frames, frame.filename, {image:image, rectangle: rectangle});
		}

		var atlas = {
			image: image,
			frames: frameMap
		};
		
		return atlas;
	}

	private static function rectangleFromFrame(frame:Dynamic) {
		return new Rectangle(frame.x, frame.y, frame.w, frame.h);
	}

}