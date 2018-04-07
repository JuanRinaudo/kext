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

class AtlasLoader {

	public static function parse(blob:Blob):AtlasData {
		var frameMap = new Map<String, Rectangle>();
		var json = Json.parse(blob.toString());
		var frameList:Array<Dynamic> = json.frames;
		for(frame in frameList) {
			frameMap.set(frame.filename, rectangleFromFrame(frame.frame));
		}

		var imageName:String = StringTools.replace(json.meta.image, ".png", "");
		var atlas = {
			image: Assets.images.get(imageName),
			frames: frameMap
		};
		return atlas;
	}

	private static function rectangleFromFrame(frame:Dynamic) {
		return new Rectangle(frame.x, frame.y, frame.w, frame.h);
	}

}