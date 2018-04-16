package kext.loaders;

import haxe.Json;

import kha.Assets;
import kha.Blob;
import kha.Image;
import kha.math.Vector2;

import kext.math.Rectangle;

typedef AtlasData = {
	image:Image,
	frames:Map<String, FrameData>
}

typedef FrameData = {
	name:String,
	image:Image,
	rectangle:Rectangle,
	sourceDelta:Vector2
}

class AtlasLoader {

	public static function parse(blob:Blob):AtlasData {
		var json = Json.parse(blob.toString());

		var imageName:String = StringTools.replace(json.meta.image, ".png", "");
		var image:Image = Assets.images.get(imageName);

		var frameMap = new Map<String, FrameData>();
		var frameList:Array<Dynamic> = json.frames;
		for(frame in frameList) {
			var rectangle:Rectangle = rectangleFromFrame(frame.frame);
			var sourceDelta:Vector2 = new Vector2(-frame.spriteSourceSize.x, -frame.spriteSourceSize.y);
			var frameData:FrameData = {
				name: frame.filename,
				image: image,
				rectangle: rectangle,
				sourceDelta: sourceDelta
			};
			frameMap.set(frame.filename, frameData);
			Reflect.setField(ExtAssets.frames, frame.filename, frameData);
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