package kext.loaders;

import kha.Blob;
import kha.math.FastVector4;
import kha.math.FastMatrix4;

import haxe.io.StringInput;

import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;

typedef Metric = {
	key:String,
	value:Dynamic
}

typedef OGEXNode = {
	key:String,
	name:String
}

typedef Node = { > OGEXNode,
	transform:FastMatrix4,
	boneNodes:Array<BoneNode>
}

typedef BoneNode = { > OGEXNode,
	transform:FastMatrix4,
	boneNodes:Array<BoneNode>,
	animation:Animation
}

typedef Animation = {
	track:Track
}

typedef Track = {
	target:String,
	times:Array<Float>,
	values:Array<Dynamic>
}

typedef GeometryNode = { > OGEXNode,
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

class OGEXMeshData {
	public var metrics:Map<String, Metric> = new Map();
	public var nodes:Map<String, Node> = new Map();
	public var geometryNodes:Map<String, GeometryNode> = new Map();
	public var geometries:Map<String, Geometry> = new Map();

	public function new() {

	}

	public inline function getMetric(name:String):Metric {
		return metrics.get(name);
	}

	public inline function getNodes(name:String):Node {
		return nodes.get(name);
	}

	public inline function getGeometryNode(name:String):GeometryNode {
		return geometryNodes.get(name);
	}

	public inline function getGeometry(name:String):Geometry {
		return geometries.get(name);
	}
}

class OGEXMeshLoader {

	public static function parse(blob:Blob):OGEXMeshData {
		var input:StringInput = new StringInput(blob.toString());

		var mesh:OGEXMeshData = new OGEXMeshData();
		
		var line:String;
		var split:Array<String>;
		var key:String;
		while(input.position < input.length) {
			line = input.readLine();
			split = line.split(" ");
			switch(getType(split[0])) {
				case "Metric":
					var metric:Metric = parseMetric(line);
					mesh.metrics.set(metric.key, metric);
				case "Node":
					var node:Node = parseNode(getKey(split[1]), input);
					mesh.nodes.set(node.key, node);
				case "GeometryNode":
					var geometryNode:GeometryNode = parseGeometryNode(getKey(split[1]), input);
					mesh.geometryNodes.set(geometryNode.name, geometryNode);
				case "GeometryObject":
					var geometry:Geometry = parseGeometry(getKey(split[1]), input);
					mesh.geometries.set(geometry.key, geometry);
				default:
					// trace(split);
			}
		}

		return mesh;
	}

	private static inline function getKey(line:String) {
		var key:String = StringTools.replace(line, "\t", " ");
		key = key.substr(0, key.indexOf(" "));
		return key;
	}

	private static inline function getType(line:String) {
		return StringTools.trim(line);
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
		var metricValue:Dynamic = getSubstring(line, '{', '}', typeSub.endIndex).value;
		if(type == "float") {
			metricValue = Std.parseFloat(metricValue);
		} else {
			metricValue = getSubstring(metricValue, '"', '"').value;
		}

		return {key: key, value: metricValue};
	}

	private static inline function parseNode(key:String, input:StringInput):Node {
		var name:String = "";
		var transform:FastMatrix4 = null;
		var bones:Array<BoneNode> = [];

		var line:String = input.readLine();
		var split:Array<String>;
		while(checkNodeEnd(line)) {
			split = StringTools.replace(line, "\t", "").split(" ");
			switch(split[0]) {
				case "Name":
					name = getSubstring(line, '"', '"').value;
				case "Transform":
					transform = parseTransform(input);
				case "BoneNode":
					var bone:BoneNode = parseBone(split[1], input);
					bones.push(bone);
			}
			line = input.readLine();
		}

		return {
			key: key,
			name: name,
			transform: transform,
			boneNodes: bones
		}
	}

	private static inline function checkNodeEnd(line:String):Bool {
		return StringTools.trim(line) != "}";
	}

	private static inline function parseBone(key:String, input:StringInput):BoneNode {
		var name:String = "";
		var transform:FastMatrix4 = null;
		var bones:Array<BoneNode> = [];
		var animation:Animation = null;

		var line:String = input.readLine();
		var split:Array<String>;
		while(checkNodeEnd(line)) {
			split = StringTools.replace(line, "\t", "").split(" ");
			switch(split[0]) {
				case "Name":
					name = getSubstring(line, '"', '"').value;
				case "Transform":
					transform = parseTransform(input);
				case "BoneNode":
					var bone:BoneNode = parseBone(split[1], input);
					bones.push(bone);
				case "Animation":
					animation = parseAnimation(input);
			}
			line = input.readLine();
		}

		return {
			key: key,
			name: name,
			transform: transform,
			boneNodes: bones,
			animation: animation
		}
	}

	private static inline function parseAnimation(input:StringInput):Animation {
		var target:String = "";
		var times:Array<Float> = [];
		var values:Array<Dynamic> = [];
		
		var line = input.readLine();
		var split:Array<String>;
		while(checkNodeEnd(line)) {
			split = StringTools.replace(line, "\t", "").split(" ");
			switch(split[0]) {
				case "Track":
					target = getSubstring(line, "target = ", ")").value;
				case "Time":
					input.readLine();
					var timesStrings:Array<String> = getSubstring(input.readLine(), "float {", "}").value.split(",");
					for(time in timesStrings) {
						times.push(Std.parseFloat(time));
					}
					input.readLine();
				case "Value":
					if(target == "%transform") {
						input.readLine();
						input.readLine(); // Key
						input.readLine();
						input.readLine(); // Type ex: float[16]
						input.readLine();
						var valueLine = input.readLine();
						while(checkNodeEnd(valueLine)) {
							values.push(parseValueFloat16(valueLine));
							valueLine = input.readLine();
						}
						input.readLine();
						input.readLine();
					}
			}
			line = input.readLine();
		}
		
		return {
			track: {
				target: target,
				times: times,
				values: values,
			}
		}
	}

	private static inline function parseValueFloat16(line:String):FastMatrix4 {
		var valuesString:Array<String> = getSubstring(line, "{", "}").value.split(",");
		return new FastMatrix4(
			Std.parseFloat(valuesString[0]), Std.parseFloat(valuesString[1]), Std.parseFloat(valuesString[2]), Std.parseFloat(valuesString[3]),
			Std.parseFloat(valuesString[4]), Std.parseFloat(valuesString[5]), Std.parseFloat(valuesString[6]), Std.parseFloat(valuesString[7]),
			Std.parseFloat(valuesString[8]), Std.parseFloat(valuesString[9]), Std.parseFloat(valuesString[10]), Std.parseFloat(valuesString[11]),
			Std.parseFloat(valuesString[12]), Std.parseFloat(valuesString[13]), Std.parseFloat(valuesString[14]), Std.parseFloat(valuesString[15])
		);
	}

	private static inline function parseGeometryNode(key:String, input:StringInput):GeometryNode {
		var name:String = "";
		var geometryName:String = "";
		var transform:FastMatrix4 = null;

		var line = input.readLine();
		var split:Array<String>;
		while(checkNodeEnd(line)) {
			split = StringTools.replace(line, "\t", "").split(" ");
			switch(split[0]) {
				case "Name":
					name = getSubstring(line, '"', '"').value;
				case "ObjectRef":
					geometryName = getSubstring(line, "{", "}", line.indexOf("{") + 1).value;
				case "Transform":
					transform = parseTransform(input);
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

	private static inline function parseTransform(input:StringInput):FastMatrix4 {
		var transform:FastMatrix4 = FastMatrix4.identity();
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
		input.readLine();
		input.readLine();
		return transform;
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
		while(checkNodeEnd(line)) {
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
					while(checkNodeEnd(line)) {
						split = line.split("}, ");
						for(vector in split) {
							parseIndices(indices, index, vector);
							index += 3;
						}
						line = StringTools.replace(input.readLine(), "\t", "");
					}
					input.readLine();
			}
			line = input.readLine();
		}

		vertexCount = vertexes.length;
		
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
		while(checkNodeEnd(line)) {
			split = line.split("}, ");
			for(vector in split) {
				parseFloat3(array, index, vector);
				index += 3;
			}
			line = StringTools.replace(input.readLine(), "\t", "");
		}
		input.readLine();
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
		while(checkNodeEnd(line)) {
			split = line.split("}, ");
			for(vector in split) {
				parseFloat2(array, index, vector);
				index += 2;
			}
			line = StringTools.replace(input.readLine(), "\t", "");
		}
		input.readLine();
		return array;
	}

	private static inline function parseFloat2(array:Float32Array, index:Int, vector:String) {
		var split:Array<String> = vector.split(",");
		array.set(index + 0, Std.parseFloat(split[0].substr(1)));
		array.set(index + 1, Std.parseFloat(split[1]));
	}

}