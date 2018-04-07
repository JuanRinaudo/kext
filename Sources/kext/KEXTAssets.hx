package kext;

import haxe.Json;

import kha.Assets;
import kha.Blob;

import kext.loaders.AtlasLoader;
import kext.loaders.AtlasLoader.AtlasData;

@:keep
@:build(kext.KEXTBuilder.build("atlas"))
private class AtlasList {
	public function new() {
		
	}

	public function get(name: String): AtlasData {
		return Reflect.field(this, name);
	}
}

class KEXTAssets {

	private static var onCompleteCallback:Void -> Void;

	public static var atlas:AtlasList = new AtlasList();

	public static function parseAssets(manifestJson:Blob, completeCallback:Void -> Void) {
		onCompleteCallback = completeCallback;
		
		var json = Json.parse(manifestJson.toString());
		var assetList:Array<Dynamic> = json.assets;
		for(asset in assetList) {
			switch(asset.type) {
				case "atlas":
					Reflect.setField(atlas, StringTools.replace(asset.name, "_atlas", ""), AtlasLoader.parse(Assets.blobs.get(asset.name)));
			}
		}

		onCompleteCallback();
	}

}