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
	bones:Array<BoneNode>
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
	values:Array<FastMatrix4>
}

typedef GeometryNode = { > OGEXNode,
	geometryName:String,
	transform:FastMatrix4
}

typedef Skeleton = {
	bones:Array<String>,
	transforms:Array<FastMatrix4>
}

typedef Skin = {
	transform:FastMatrix4,
	skeleton:Skeleton,
	boneCountVertex:Uint32Array,
	boneIndexes:Uint32Array,
	boneWeights:Float32Array
}

typedef Geometry = {
	key:String,
	vertexes:Float32Array,
	normals:Float32Array,
	colors:Float32Array,
	uvs:Float32Array,
	indices:Uint32Array,
	skin:Skin,
	triangleCount:UInt,
	vertexCount:UInt
}

class OGEXMeshData {
	public var metrics:Map<String, Metric> = new Map();
	public var nodes:Map<String, Node> = new Map();
	public var boneNodes:Map<String, BoneNode> = new Map();
	public var geometryNodes:Map<String, GeometryNode> = new Map();
	public var geometries:Map<String, Geometry> = new Map();
	public var skins:Map<String, Skin> = new Map();

	public function new() {

	}

	public inline function getMetric(name:String):Metric {
		return metrics.get(name);
	}

	public inline function getNode(name:String):Node {
		return nodes.get(name);
	}

	public inline function getBoneNode(name:String):BoneNode {
		return boneNodes.get(name);
	}

	public inline function getGeometryNode(name:String):GeometryNode {
		return geometryNodes.get(name);
	}

	public inline function getGeometry(name:String):Geometry {
		return geometries.get(name);
	}

	public inline function getSkin(name:String):Skin {
		return skins.get(name);
	}
}

class OGEXMeshLoader {

	private static var data:OGEXMeshData;

	public static function parse(blob:Blob):OGEXMeshData {
		var input:StringInput = new StringInput(blob.toString());

		data = new OGEXMeshData();
		
		var line:String;
		var split:Array<String>;
		var key:String;
		while(input.position < input.length) {
			line = input.readLine();
			split = line.split(" ");
			switch(getType(split[0])) {
				case "Metric":
					var metric:Metric = parseMetric(line);
				case "Node":
					var node:Node = parseNode(split[1], input);
				case "GeometryNode":
					var geometryNode:GeometryNode = parseGeometryNode(getKey(split[1]), input);
				case "GeometryObject":
					var geometry:Geometry = parseGeometry(getKey(split[1]), input);
				default:
					// trace(input.position);
					// trace(split);
			}
		}

		return data;
	}

	private static inline function getKey(line:String) {
		var key:String = StringTools.replace(line, "\t", " ");
		var endIndex = key.indexOf(" ") != -1 ? key.indexOf(" ") : line.length;
		key = key.substr(0, endIndex);
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

		var metric:Metric = {
			key: key,
			value: metricValue
		};
		data.metrics.set(metric.key, metric);
		return metric;
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
				case "GeometryObject":
					var geometry:Geometry = parseGeometry(getKey(split[1]), input);
				case "GeometryNode":
					var geometryNode:GeometryNode = parseGeometryNode(getKey(split[1]), input);
			}
			line = input.readLine();
		}

		var node:Node = {
			key: key,
			name: name,
			transform: transform,
			bones: bones
		};
		data.nodes.set(node.key, node);
		return node; 
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
				case "Animation":
					animation = parseAnimation(input);
				case "BoneNode":
					var bone:BoneNode = parseBone(split[1], input);
					bones.push(bone);
			}
			line = input.readLine();
		}

		var boneNode:BoneNode = {
			key: key,
			name: name,
			transform: transform,
			boneNodes: bones,
			animation: animation
		}
		data.boneNodes.set(boneNode.key, boneNode);
		return boneNode;
	}

	private static inline function parseAnimation(input:StringInput):Animation {
		var target:String = "";
		var times:Array<Float> = [];
		var values:Array<FastMatrix4> = [];
		
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
			Std.parseFloat(valuesString[0]), Std.parseFloat(valuesString[4]), Std.parseFloat(valuesString[8]), Std.parseFloat(valuesString[12]),
			Std.parseFloat(valuesString[1]), Std.parseFloat(valuesString[5]), Std.parseFloat(valuesString[9]), Std.parseFloat(valuesString[13]),
			Std.parseFloat(valuesString[2]), Std.parseFloat(valuesString[6]), Std.parseFloat(valuesString[10]), Std.parseFloat(valuesString[14]),
			Std.parseFloat(valuesString[3]), Std.parseFloat(valuesString[7]), Std.parseFloat(valuesString[11]), Std.parseFloat(valuesString[15])
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
		
		var geometryNode:GeometryNode = {
			key: key,
			name: name, 
			geometryName: geometryName, 
			transform: transform
		};
		data.geometryNodes.set(geometryNode.name, geometryNode);
		return geometryNode;
	}

	private static inline function parseTransform(input:StringInput):FastMatrix4 {
		var transform:FastMatrix4 = FastMatrix4.identity();
		input.readLine();
		input.readLine();
		input.readLine();
		var line = StringTools.replace(StringTools.replace(input.readLine(), "{", ""), "}", "");
		var floatSplit = line.split(",");
		transform._00 = Std.parseFloat(floatSplit[0]);
		transform._01 = Std.parseFloat(floatSplit[1]);
		transform._02 = Std.parseFloat(floatSplit[2]);
		transform._03 = Std.parseFloat(floatSplit[3]);
		var line = StringTools.replace(StringTools.replace(input.readLine(), "{", ""), "}", "");
		var floatSplit = line.split(",");
		transform._10 = Std.parseFloat(floatSplit[0]);
		transform._11 = Std.parseFloat(floatSplit[1]);
		transform._12 = Std.parseFloat(floatSplit[2]);
		transform._13 = Std.parseFloat(floatSplit[3]);
		var line = StringTools.replace(StringTools.replace(input.readLine(), "{", ""), "}", "");
		var floatSplit = line.split(",");
		transform._20 = Std.parseFloat(floatSplit[0]);
		transform._21 = Std.parseFloat(floatSplit[1]);
		transform._22 = Std.parseFloat(floatSplit[2]);
		transform._23 = Std.parseFloat(floatSplit[3]);
		var line = StringTools.replace(StringTools.replace(input.readLine(), "{", ""), "}", "");
		var floatSplit = line.split(",");
		transform._30 = Std.parseFloat(floatSplit[0]);
		transform._31 = Std.parseFloat(floatSplit[1]);
		transform._32 = Std.parseFloat(floatSplit[2]);
		transform._33 = Std.parseFloat(floatSplit[3]);
		input.readLine();
		input.readLine();
		return transform;
	}

	private static inline function parseGeometry(key:String, input:StringInput):Geometry {
		var vertexes:Float32Array = null;
		var normals:Float32Array = null;
		var colors:Float32Array = null;
		var uvs:Float32Array = null;
		var indices:Uint32Array = null;
		var skin:Skin = null;
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
						case "color":
							colors = parseFloat3Array(input);
						case "texcoord":
							uvs = parseFloat2Array(input);
					}
				case "IndexArray":
					input.readLine();
					line = input.readLine();
					triangleCount = Std.parseInt(line.substr(line.indexOf("//") + 2));
					input.readLine();
					indices = newUint32Array(triangleCount * 3);
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
				case "Skin":
					skin = parseSkin(key, input);
			}
			line = input.readLine();
		}

		vertexCount = vertexes.length;
		
		var geometry:Geometry = {
			key: key,
			vertexes: vertexes,
			normals: normals,
			colors: colors,
			uvs: uvs,
			indices: indices,
			skin: skin,
			triangleCount: triangleCount,
			vertexCount: vertexCount
		};
		data.geometries.set(geometry.key, geometry);
		return geometry;
	}

	private static inline function parseSkin(key:String, input:StringInput):Skin {
		var transform:FastMatrix4 = FastMatrix4.identity();
		var skeleton:Skeleton = null;

		var boneCountVertex:Uint32Array = null;
		var boneIndexes:Uint32Array = null;
		var boneWeights:Float32Array = null;
		
		var line:String = StringTools.replace(input.readLine(), "\t", "");
		var split:Array<String>;
		while(checkNodeEnd(line)) {
			split = StringTools.replace(line, "\t", "").split(" ");
			switch(split[0]) {
				case "Skeleton":
					skeleton = parseSkeleton(input);
				case "BoneCountArray":
					boneCountVertex = parseIntArray(input);
				case "BoneIndexArray":
					boneIndexes = parseIntArray(input);
				case "BoneWeightArray":
					boneWeights = parseFloatArray(input);
				case "Transform":
					transform = parseTransform(input);
			}
			line = input.readLine();
		}

		var skin:Skin = {
			transform: transform,
			skeleton: skeleton,
			boneCountVertex: boneCountVertex,
			boneIndexes: boneIndexes,
			boneWeights: boneWeights
		};
		data.skins.set(key, skin);
		return skin;
	}

	private static inline function parseSkeleton(input:StringInput):Skeleton {
		var bones:Array<String> = [];
		var transforms:Array<FastMatrix4> = [];
		
		var line:String = StringTools.replace(input.readLine(), "\t", "");
		var split:Array<String>;
		while(checkNodeEnd(line)) {
			split = StringTools.replace(line, "\t", "").split(" ");
			switch(split[0]) {
				case "BoneRefArray":
					input.readLine();
					input.readLine();
					input.readLine();
					bones = StringTools.replace(StringTools.replace(input.readLine(), "\t", ""), " ", "").split(",");
					input.readLine();
					input.readLine();
				case "Transform":
					transforms = parseTransformArray(input);
			}
			line = input.readLine();
		}
		
		return {
			bones: bones,
			transforms: transforms
		};
	}

	private static inline function parseIntArray(input:StringInput):Uint32Array {
		input.readLine();
		var line:String = input.readLine();
		var count = Std.parseInt(line.substr(line.indexOf("//") + 2));
		input.readLine();

		var array:Uint32Array = newUint32Array(count);
		var line:String = input.readLine();
		var i:Int = 0;
		while(line.indexOf("}") == -1) {
			var values:Array<String> = StringTools.replace(line, "\t", "").split(",");
			for(int in values) {
				if(int != "") {
					array.set(i, Std.parseInt(int));
					i++;
				}
			}
			line = input.readLine();
		}
		input.readLine();

		return array;
	}

	private static inline function parseFloatArray(input:StringInput):Float32Array {
		input.readLine();
		var line:String = input.readLine();
		var count = Std.parseInt(line.substr(line.indexOf("//") + 2));
		input.readLine();
		
		var array:Float32Array = newFloat32Array(count);
		var line:String = input.readLine();
		var i:Int = 0;
		while(line.indexOf("}") == -1) {
			var values:Array<String> = StringTools.replace(line, "\t", "").split(",");
			for(float in values) {
				if(float != "") {
					array.set(i, Std.parseFloat(float));
					i++;
				}
			}
			line = input.readLine();
		}
		input.readLine();

		return array;
	}

	private static inline function parseTransformArray(input:StringInput):Array<FastMatrix4> {
		input.readLine();
		var transforms:Array<FastMatrix4> = [];
		var line:String = input.readLine();
		var count = Std.parseInt(line.substr(line.indexOf("//") + 2));
		input.readLine();
		for(i in 0...count) {
			var line = StringTools.replace(StringTools.replace(input.readLine(), "{", ""), "}", "");
			var floatSplit = line.split(",");
			var transform = new FastMatrix4(
				Std.parseFloat(floatSplit[0]), Std.parseFloat(floatSplit[4]), Std.parseFloat(floatSplit[8]), Std.parseFloat(floatSplit[12]),
				Std.parseFloat(floatSplit[1]), Std.parseFloat(floatSplit[5]), Std.parseFloat(floatSplit[9]), Std.parseFloat(floatSplit[13]),
				Std.parseFloat(floatSplit[2]), Std.parseFloat(floatSplit[6]), Std.parseFloat(floatSplit[10]), Std.parseFloat(floatSplit[14]),
				Std.parseFloat(floatSplit[3]), Std.parseFloat(floatSplit[7]), Std.parseFloat(floatSplit[11]), Std.parseFloat(floatSplit[15])
			);
			transforms.push(transform);
		}
		input.readLine();
		input.readLine();

		return transforms;
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
		var array:Float32Array = newFloat32Array(count * 3);
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
		var array:Float32Array = newFloat32Array(count * 2);
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

	private static inline function newFloat32Array(size:Int):Float32Array {
		#if (js || kha_android_java)
		return new Float32Array(size);
		#else
		return new Float32Array();
		#end
	}

	private static inline function newUint32Array(size:Int):Uint32Array {
		#if (js || kha_android_java)
		return new Uint32Array(size);
		#else
		return new Uint32Array();
		#end
	}

}