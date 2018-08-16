package kext.data;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Json;

class DataBuilder {

	static private function getType(data:Dynamic, fieldname:String) {
		var value:Dynamic = Reflect.field(data, fieldname);
		var dynArray:Array<Dynamic>;
		
		if(Type.typeof(value) == Type.typeof(1)) {
			return FVar(macro: Int, macro $v{value});
		} else if(Type.typeof(value) == Type.typeof(0.1)) {
			return FVar(macro: Float, macro $v{value});
		} else if(Type.typeof(value) == Type.typeof(true)) {
			return FVar(macro: Bool, macro $v{value});
		} else if(Type.getClassName(Type.getClass(value)) == "String") {
			return FVar(macro: String, macro $v{value});
		} else if(Type.typeof(value) == Type.typeof({})) {
			if(Reflect.hasField(value, "x") && Reflect.hasField(value, "y") && Reflect.fields(value).length == 2) {
				return FVar(macro: kha.math.Vector2, macro $v{value});
			} else if(Reflect.hasField(value, "x") && Reflect.hasField(value, "y") &&
				Reflect.hasField(value, "width") && Reflect.hasField(value, "height") && Reflect.fields(value).length == 4) {
				return FVar(macro: kext.math.Rectangle, macro $v{value});
			} else {
				return FVar(macro: Dynamic, macro $v{value});
			}
		} else if(Type.getClassName(Type.getClass(value)) == "Array") {
			if(Type.typeof(value[0]) == Type.typeof(1)) {
				return FVar(macro: Array<Int>, macro $v{value});
			} else if(Type.typeof(value[0]) == Type.typeof(0.1)) {
				return FVar(macro: Array<Float>, macro $v{value});
			} else if(Type.typeof(value[0]) == Type.typeof(true)) {
				return FVar(macro: Array<Bool>, macro $v{value});
			} else if(Type.getClassName(Type.getClass(value)) == "String") {
				return FVar(macro: Array<String>, macro $v{value});
			} else if(Type.typeof(value[0]) == Type.typeof({})) {
				if(Reflect.hasField(value[0], "x") && Reflect.hasField(value[0], "y") && Reflect.fields(value[0]).length == 2) {
					return FVar(macro: Array<kha.math.Vector2>, macro $v{value});
				} else if(Reflect.hasField(value[0], "x") && Reflect.hasField(value[0], "y") &&
					Reflect.hasField(value[0], "width") && Reflect.hasField(value[0], "height") && Reflect.fields(value[0]).length == 4) {
					return FVar(macro: Array<kext.math.Rectangle>, macro $v{value});
				} else {
					return FVar(macro: Array<Dynamic>, macro $v{value});
				}
			} else {
				return FVar(macro: Array<Dynamic>, macro $v{value});
			}
		} else {
			return FVar(macro: Dynamic, macro $v{value});
		}
	}

	static private function getFilePath(filename:String) {
		return '../$filename';
	}

	static private function getFile(path:String) {
		try {
			return Json.parse(sys.io.File.getContent(path));
		} catch(e:Dynamic) {
			return Context.error('Failed to load file $path: $e', Context.currentPos());
		}
	}

	macro static public function getJSONData(filename:String):Array<Field> {
		var output:String = Compiler.getOutput();
		output = StringTools.replace(output, "\\", "/");
		output = output.substring(0, output.lastIndexOf("/"));

		var path:String = getFilePath(filename);
		var data:Iterable<Dynamic> = getFile(path);
		
		var fields = Context.getBuildFields();
		for(fieldname in Reflect.fields(data)) {
			fields.push({
				name: fieldname,
				doc: null,
				meta: [],
				access: [APublic],
				kind: getType(data, fieldname),
				pos: Context.currentPos()
			});
		}
		return fields;
	}
}