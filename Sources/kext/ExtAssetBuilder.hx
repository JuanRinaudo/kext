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
		#if kha_android_java
		outputFolder += ("/app/src/main/assets");
		#elseif kha_android
		outputFolder += ("/../../android-native");
		#else
		outputFolder = outputFolder.substring(0, outputFolder.lastIndexOf("/"));
		#end

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
						var json = Json.parse(File.getContent(outputFolder + "/" + filename));
						var frameList:Array<Dynamic> = json.frames;
						for(frame in frameList) {
							fields.push({
								name: frame.filename,
								doc: null,
								meta: [],
								access: [APublic],
								kind: FVar(macro: kext.loaders.AtlasLoader.FrameData, macro null),
								pos: Context.currentPos()
							});
						}
					}
				case "animationFiles":
					if(filename.indexOf(".anim") != -1) {
						fields.push({
							name: StringTools.replace(name, "_anim", ""),
							doc: null,
							meta: [],
							access: [APublic],
							kind: FVar(macro: kext.loaders.AnimationLoader.AnimationFile, macro null),
							pos: Context.currentPos()
						});
					}
				case "animations":
					if(filename.indexOf(".anim") != -1) {
						var json = Json.parse(File.getContent(outputFolder + "/" + filename));
						var animationList:Array<Dynamic> = json.animations;
						for(anim in animationList) {
							fields.push({
								name: anim.name,
								doc: null,
								meta: [],
								access: [APublic],
								kind: FVar(macro: kext.loaders.AnimationLoader.AnimationData, macro null),
								pos: Context.currentPos()
							});
						}
					}
			}
		}

		return fields;
	}

}