package kext.loaders;

import kha.Blob;
import kha.math.FastMatrix4;

import haxe.io.StringInput;

import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;

typedef Metric = {
	key:String,
	value:Dynamic
}

typedef Node = {
	key:String,
	name:String,
	geometryName:String,
	transform:FastMatrix4
}

typedef Geometry = {
	key:String,
	vertexes:Float32Array,
	normals:Float32Array,
	uvs:Float32Array,
	indices:Uint32Array,
	triangleCount:UInt,
	vertexCount:UInt
}

typedef OGEXMeshData = {
	metrics:Array<Metric>,
	nodes:Array<Node>,
	geometries:Array<Geometry>
}

class OGEXMeshLoader {

	public static function parse(blob:Blob):OGEXMeshData {
		var input:StringInput = new StringInput(blob.toString());

		var mesh:OGEXMeshData = {
			metrics: [],
			nodes: [],
			geometries: []
		}
		
		var line:String;
		var split:Array<String>;
		while(input.position < input.length) {
			line = input.readLine();
			split = line.split(" ");
			switch(split[0]) {
				case "Metric":
					mesh.metrics.push(parseMetric(line));
				case "GeometryNode":
					mesh.nodes.push(parseNode(split[1], input));
				case "GeometryObject":
					mesh.geometries.push(parseGeometry(split[1], input));
			}
		}

		return mesh;
	}

	private static inline function getSubstring(line:String, start:String, end:String, index:Int = 0) {
		var startIndex:Int = line.indexOf(start, index) + start.length;
		var endIndex:Int = line.indexOf(end, startIndex);
		var value:String = line.substr(startIndex, endIndex - startIndex);
		return {startIndex: startIndex, endIndex: endIndex, value: value};
	}

	private static inline function parseMetric(line:String):Metric {
		var key:String = getSubstring(line, '"', '"').value;
		var typeSub = getSubstring(line, '{', ' ');
		var type:String = typeSub.value;
		var value:Dynamic = getSubstring(line, '{', '}', typeSub.endIndex).value;
		if(type == "float") {
			value = Std.parseFloat(value);
		}
		return {key: key, value: value};
	}

	private static inline function parseNode(key:String, input:StringInput):Node {
		var name:String = "";
		var geometryName:String = "";
		var transform:FastMatrix4 = FastMatrix4.identity();

		var line = input.readLine();
		var split:Array<String>;
		while(line != "}") {
			split = StringTools.replace(line, "\t", "").split(" ");
			switch(split[0]) {
				case "Name":
					name = getSubstring(line, '"', '"').value;
				case "ObjectRef":
					geometryName = getSubstring(line, "{", "}", line.indexOf("{")).value;
				case "Transform":
					input.readLine();
					input.readLine();
					input.readLine();
					var line = StringTools.replace(StringTools.replace(input.readLine(), "{", ""), "}", "");
					var floatSplit = line.split(",");
					transform._00 = Std.parseFloat(floatSplit[0]);
					transform._10 = Std.parseFloat(floatSplit[1]);
					transform._20 = Std.parseFloat(floatSplit[2]);
					transform._30 = Std.parseFloat(floatSplit[3]);
					var line = StringTools.replace(StringTools.replace(input.readLine(), "{", ""), "}", "");
					var floatSplit = line.split(",");
					transform._01 = Std.parseFloat(floatSplit[0]);
					transform._11 = Std.parseFloat(floatSplit[1]);
					transform._21 = Std.parseFloat(floatSplit[2]);
					transform._31 = Std.parseFloat(floatSplit[3]);
					var line = StringTools.replace(StringTools.replace(input.readLine(), "{", ""), "}", "");
					var floatSplit = line.split(",");
					transform._02 = Std.parseFloat(floatSplit[0]);
					transform._12 = Std.parseFloat(floatSplit[1]);
					transform._22 = Std.parseFloat(floatSplit[2]);
					transform._32 = Std.parseFloat(floatSplit[3]);
					var line = StringTools.replace(StringTools.replace(input.readLine(), "{", ""), "}", "");
					var floatSplit = line.split(",");
					transform._03 = Std.parseFloat(floatSplit[0]);
					transform._13 = Std.parseFloat(floatSplit[1]);
					transform._23 = Std.parseFloat(floatSplit[2]);
					transform._33 = Std.parseFloat(floatSplit[3]);
			}
			line = input.readLine();
		}
		
		return {
			key: key,
			name: name, 
			geometryName: geometryName, 
			transform: transform
		};
	}

	private static inline function parseGeometry(key:String, input:StringInput):Geometry {
		var vertexes:Float32Array = null;
		var normals:Float32Array = null;
		var uvs:Float32Array = null;
		var indices:Uint32Array = null;

		var triangleCount:Int = 0;
		var vertexCount:Int = 0;

		var line = input.readLine();
		var split:Array<String>;
		while(line != "}") {
			split = StringTools.replace(line, "\t", "").split(" ");
			switch(split[0]) {
				case "VertexArray":
					var attrib:String = getSubstring(split[3], '"', '"').value;
					switch(attrib) {
						case "position":
							vertexes = parseFloat3Array(input);
						case "normal":
							normals = parseFloat3Array(input);
						case "texcoord":
							uvs = parseFloat2Array(input);
					}
				case "IndexArray":
					input.readLine();
					line = input.readLine();
					triangleCount = Std.parseInt(line.substr(line.indexOf("//") + 2));
					input.readLine();
					#if (js || kha_android_java)
					indices = new Uint32Array(triangleCount * 3);
					#else
					indices = new Uint32Array();
					#end
					line = StringTools.replace(input.readLine(), "\t", "");
					var index:Int = 0;
					while(line != "}") {
						split = line.split("}, ");
						for(vector in split) {
							parseIndices(indices, index, vector);
							index += 3;
						}
						line = StringTools.replace(input.readLine(), "\t", "");
					}
			}
			line = input.readLine();
		}

		vertexCount = vertexes.length;
		trace(vertexes);
		trace(normals);
		trace(uvs);
		trace(indices);
		
		return {
			key: key,
			vertexes: vertexes,
			normals: normals,
			uvs: uvs,
			indices: indices,
			triangleCount: triangleCount,
			vertexCount: vertexCount
		};
	}

	private static inline function parseIndices(indices:Uint32Array, index:Int, vector:String) {
		var split:Array<String> = vector.split(",");
		indices.set(index + 0, Std.parseInt(split[0].substr(1)));
		indices.set(index + 1, Std.parseInt(split[1]));
		indices.set(index + 2, Std.parseInt(split[2]));
	}

	private static inline function parseFloat3Array(input:StringInput):Float32Array {
		input.readLine();
		var line = input.readLine();
		var count = Std.parseInt(line.substr(line.indexOf("//") + 2));
		input.readLine();
		#if (js || kha_android_java)
		var array = new Float32Array(count * 3);
		#else
		var array = new Float32Array();
		#end
		line = StringTools.replace(input.readLine(), "\t", "");
		var index:Int = 0;
		var split:Array<String>;
		while(line != "}") {
			split = line.split("}, ");
			for(vector in split) {
				parseFloat3(array, index, vector);
				index += 3;
			}
			line = StringTools.replace(input.readLine(), "\t", "");
		}
		return array;
	}

	private static inline function parseFloat3(array:Float32Array, index:Int, vector:String) {
		var split:Array<String> = vector.split(",");
		array.set(index + 0, Std.parseFloat(split[0].substr(1)));
		array.set(index + 1, Std.parseFloat(split[1]));
		array.set(index + 2, Std.parseFloat(split[2]));
	}

	private static inline function parseFloat2Array(input:StringInput):Float32Array {
		input.readLine();
		var line = input.readLine();
		var count = Std.parseInt(line.substr(line.indexOf("//") + 2));
		input.readLine();
		#if (js || kha_android_java)
		var array = new Float32Array(count * 2);
		#else
		var array = new Float32Array();
		#end
		line = StringTools.replace(input.readLine(), "\t", "");
		var index:Int = 0;
		var split:Array<String>;
		while(line != "}") {
			split = line.split("}, ");
			for(vector in split) {
				parseFloat2(array, index, vector);
				index += 2;
			}
			line = StringTools.replace(input.readLine(), "\t", "");
		}
		return array;
	}

	private static inline function parseFloat2(array:Float32Array, index:Int, vector:String) {
		var split:Array<String> = vector.split(",");
		array.set(index + 0, Std.parseFloat(split[0].substr(1)));
		array.set(index + 1, Std.parseFloat(split[1]));
	}

}