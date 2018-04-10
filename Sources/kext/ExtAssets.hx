package kext;

import haxe.Json;

import kha.Assets;
import kha.Blob;

import kext.loaders.AtlasLoader;
import kext.loaders.AtlasLoader.AtlasData;
import kext.loaders.AtlasLoader.FrameData;

import kext.loaders.AnimationLoader;
import kext.loaders.AnimationLoader.AnimationData;

@:keep
@:build(kext.ExtAssetBuilder.build("atlas"))
private class AtlasList {
	public function new() {
		
	}

	public function get(name: String): AtlasData {
		return Reflect.field(this, name);
	}
}

@:keep
@:build(kext.ExtAssetBuilder.build("frames"))
private class FrameList {
	public function new() {
		
	}

	public function get(name: String): FrameData {
		return Reflect.field(this, name);
	}
}

@:keep
@:build(kext.ExtAssetBuilder.build("animationFiles"))
private class AnimationFileList {
	public function new() {
		
	}

	public function get(name: String): AnimationFile {
		return Reflect.field(this, name);
	}
}

@:keep
@:build(kext.ExtAssetBuilder.build("animations"))
private class AnimationList {
	public function new() {
		
	}

	public function get(name: String): AnimationData {
		return Reflect.field(this, name);
	}
}

class ExtAssets {

	private static var onCompleteCallback:Void -> Void;

	public static var atlas:AtlasList = new AtlasList();
	public static var frames:FrameList = new FrameList();
	
	public static var animationFiles:AnimationFileList = new AnimationFileList();
	public static var animations:AnimationList = new AnimationList();

	public static function parseAssets(manifestJson:Blob, completeCallback:Void -> Void) {
		onCompleteCallback = completeCallback;
		
		var json = Json.parse(manifestJson.toString());
		var assetList:Array<Dynamic> = json.assets;
		for(asset in assetList) {
			switch(asset.type) {
				case "atlas":
					parseAtlas(StringTools.replace(asset.name, "_atlas", ""), Assets.blobs.get(asset.name));
				case "animations":
					parseAnimation(StringTools.replace(asset.name, "_anim", ""), Assets.blobs.get(asset.name));
			}
		}

		onCompleteCallback();
	}

	public static function parseAtlas(name:String, atlasBlob:Blob) {
		Reflect.setField(atlas, name, AtlasLoader.parse(atlasBlob));
	}

	public static function parseAnimation(name:String, animationBlob:Blob) {
		Reflect.setField(animationFiles, name, AnimationLoader.parse(animationBlob));
	}

}