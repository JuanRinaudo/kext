package kext;

import haxe.Json;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import sys.io.File;

using StringTools;

class ExtAssetBuilder {
	
	macro static public function build(type: String): Array<Field> {
		var fields = Context.getBuildFields();
		var content = Json.parse(File.getContent(kha.internal.AssetsBuilder.findResources() + "files.json"));
		var files: Iterable<Dynamic> = content.files;

		var outputFolder = Compiler.getOutput();
		outputFolder = outputFolder.replace("\\", "/");
		outputFolder = outputFolder.substring(0, outputFolder.lastIndexOf("/"));

		for (file in files) {
			var name:String = file.name;
			var filename:String = file.files[0];

			switch(type) {
				case "atlas":
					if(filename.indexOf(".atlas") != -1) {
						fields.push({
							name: StringTools.replace(name, "_atlas", ""),
							doc: null,
							meta: [],
							access: [APublic],
							kind: FVar(macro: kext.loaders.AtlasLoader.AtlasData, macro null),
							pos: Context.currentPos()
						});
					}
				case "frames":
					if(filename.indexOf(".atlas") != -1) {
						var atlas = Json.parse(File.getContent(outputFolder + "/" + filename));
						var frames:Array<Dynamic> = atlas.frames;
						for(f in frames) {
							fields.push({
								name: f.filename,
								doc: null,
								meta: [],
								access: [APublic],
								kind: FVar(macro: kext.loaders.AtlasLoader.FrameData, macro null),
								pos: Context.currentPos()
							});
						}
					}
			}
		}

		return fields;
	}

}