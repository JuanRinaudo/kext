package kext.loaders;

import haxe.Json;

import kha.Blob;

import kext.ExtAssets;
import kext.loaders.AtlasLoader.FrameData;

typedef AnimationFile = {
	animations:Map<String, AnimationData>
}

typedef AnimationData = {
	name:String,
	frames:Array<FrameData>,
	fps:Int,
	frameDelta:Float,
	loop:Bool,
	length:Int
}

class AnimationLoader {

	public static function parse(blob:Blob):AnimationFile {
		var json = Json.parse(blob.toString());

		var animationList:Array<Dynamic> = json.animations;
		var animationMap:Map<String, AnimationData> = new Map();
		for(anim in animationList) {
			var frames:Array<FrameData> = [];
			if(Reflect.hasField(anim, "frames")) {
				var frameList:Array<String> = anim.frames;
				for(frame in frameList) {
					frames.push(ExtAssets.frames.get(frame));
				}
			} else {
				for(i in anim.from ... Math.floor(anim.to + 1)) {
					frames.push(ExtAssets.frames.get(anim.prefix + i));
				}
				if(anim.yoyo) {
					for(i in Math.floor(anim.from + 1) ... Math.floor(anim.to + 1)) {
						frames.push(ExtAssets.frames.get(anim.prefix + (anim.to - i)));
					}
				}
			}

			var animation:AnimationData = {
				name: anim.name,
				frames: frames,
				fps: anim.fps,
				frameDelta: 1 / anim.fps,
				loop: anim.loop,
				length: frames.length
			}
			animationMap.set(anim.name, animation);
			Reflect.setField(ExtAssets.animations, anim.name, animation);
		}

		var animationFile:AnimationFile = {
			animations: animationMap
		}

		return animationFile;
	}

}