package kext;

import haxe.Json;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import sys.io.File;

class KEXTBuilder {
	
	macro static public function build(type: String): Array<Field> {
		var fields = Context.getBuildFields();
		var content = Json.parse(File.getContent(kha.internal.AssetsBuilder.findResources() + "files.json"));
		var files: Iterable<Dynamic> = content.files;

		for (file in files) {
			var name:String = file.name;
			var filename:String = file.files[0];

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
		}

		return fields;
	}

}