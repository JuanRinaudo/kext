package kext.data;

import kha.Assets;
import kha.Blob;

import kext.Application;
import kext.utils.Counter;

import haxe.Json;
import haxe.io.Bytes;

class DataWatcher {
	private static var watchModificationTimes:Map<String, Float> = new Map();
	
	static public function watchJSONRefreshOnChange(object:Dynamic, filename:String, watchTime:Float = 0.3) {
		var callback:Void -> Void = null;
		#if kha_debug_html5
		callback = watchAndChangeFile.bind(object, filename);
		#elseif js
		callback = reloadAndChangeFile.bind(object, filename);
		#end

		var counter:Counter = new Counter(1, Application.deltaTime, callback, true);
		Application.addCounterUpdate(counter);
		reloadAndChangeFile(object, filename);
	}

	#if kha_debug_html5
	static public function watchAndChangeFile(object:Dynamic, filename:String) {
		var fs = untyped __js__("require('fs')");
        var path = untyped __js__("require('path')");
        var app = untyped __js__("require('electron').remote.require('electron').app");
		var url = if (path.isAbsolute(filename)) filename else path.join(app.getAppPath(), filename);
        var modificationTime:Float;
		fs.stat(url, function (err, data) {
			modificationTime = data.mtime.getTime();

			if(watchModificationTimes.exists(filename)) {
				var oldModificationTime = watchModificationTimes.get(filename);
				if(modificationTime - oldModificationTime < 10) {
					return;
				}
			}
			watchModificationTimes.set(filename, modificationTime);

			reloadAndChangeFile(object, filename);
		});
	}
	#end

	static public function reloadAndChangeFile(object:Dynamic, filename:String) {
		Assets.loadBlobFromPath(filename, function(blob:Blob) {
			var json:Dynamic = Json.parse(blob.toString());
			
			for(fieldname in Reflect.fields(json)) {
				Reflect.setField(object, fieldname, Reflect.field(json, fieldname));
			}
		});
	}
	
}