package kext.g4basics;

import haxe.xml.Fast;
import kext.platform.IPlatformServices.PlatformConfig;
import kha.Color;
import kha.Image;
import kha.Blob;

import kha.arrays.Float32Array;

import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.FastMatrix4;

import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexStructure;
import kha.graphics4.Usage;

import kext.loaders.STLMeshLoader;
import kext.loaders.STLMeshLoader.STLMeshData;
import kext.loaders.OBJMeshLoader;
import kext.loaders.OBJMeshLoader.OBJMeshData;
import kext.loaders.OGEXMeshLoader;
import kext.loaders.OGEXMeshLoader.OGEXMeshData;

class BasicMesh extends Basic {

	public var vertexBuffer:VertexBuffer;
	public var indexBuffer:IndexBuffer;

	public var triangleCount:UInt = 0;
	public var indexCount:UInt = 0;
	public var vertexCount:UInt = 0;

	public var pipeline:BasicPipeline;
	public var vertexStructure:VertexStructure;

	public var modelMatrix(get, null):FastMatrix4;

	public var transform:Transform3D;

	public var texture:Image;

	private var setPipeline:Bool = true;

	public function new(vertexCount:Int, indexCount:Int, pipeline:BasicPipeline, vertexUsage:Usage = null, indexUsage:Usage = null) {
		super();

		if(vertexUsage == null) { vertexUsage = Usage.DynamicUsage; }
		if(indexUsage == null) { indexUsage = Usage.DynamicUsage; }
		
		this.pipeline = pipeline;
		vertexStructure = pipeline.vertexStructure;

		vertexBuffer = new VertexBuffer(vertexCount, vertexStructure, vertexUsage);
		indexBuffer = new IndexBuffer(indexCount, indexUsage);

		transform = new Transform3D();
	}

	public inline function setBufferMesh(backbuffer:Image) {
		backbuffer.g4.setVertexBuffer(vertexBuffer);
		backbuffer.g4.setIndexBuffer(indexBuffer);
	}
	
	override public inline function render(backbuffer:Image) {
		modelMatrix = transform.getMatrix();

		if(setPipeline) { backbuffer.g4.setPipeline(pipeline); }
		setBufferMesh(backbuffer);
		backbuffer.g4.setMatrix(pipeline.locationMVPMatrix, pipeline.getMVPMatrix(modelMatrix));
		backbuffer.g4.setMatrix(pipeline.locationViewMatrix, pipeline.camera.viewMatrix);
		backbuffer.g4.setMatrix(pipeline.locationModelMatrix, modelMatrix);
		backbuffer.g4.setMatrix(pipeline.locationProjectionMatrix, pipeline.camera.projectionMatrix);
		backbuffer.g4.setMatrix3(pipeline.locationNormalMatrix, pipeline.getNormalMatrix(modelMatrix));
		if(texture != null) {
			backbuffer.g4.setTexture(pipeline.textureUnit, texture);
		}
		backbuffer.g4.drawIndexedVertices();
	}

	public inline function addTriangle(v1:Vector3, v2:Vector3, v3:Vector3, n1:Vector3, n2:Vector3, n3:Vector3,
		uv1:Vector2, uv2:Vector2, uv3:Vector2, color1:Color, color2:Color = null, color3:Color = null) {
		if(color2 == null) { color2 = color1; }
		if(color3 == null) { color3 = color1; }

		var structSize = Math.floor(vertexStructure.byteSize() / 4);
		var baseIndex:Int = vertexCount * structSize;
		var vertexes:Float32Array = vertexBuffer.lock();
		setVertex(vertexes, baseIndex, v1, n1, uv1, color1);
		setVertex(vertexes, baseIndex + structSize, v2, n2, uv2, color2);
		setVertex(vertexes, baseIndex + structSize * 2, v3, n3, uv3, color3);
		vertexBuffer.unlock();

		var baseIndex:Int = indexCount;
		var indexes = indexBuffer.lock();
		indexes.set(baseIndex + 0, baseIndex + 0);
		indexes.set(baseIndex + 1, baseIndex + 1);
		indexes.set(baseIndex + 2, baseIndex + 2);
		indexBuffer.unlock();

		triangleCount += 1;
		indexCount += 3;
		vertexCount += 3;
	}

	public inline function addVertexes(vectors:Array<Vector3>, normals:Array<Vector3>, uvs:Array<Vector2>, colors:Array<Color>) {
		if(vectors.length != normals.length || normals.length != uvs.length || uvs.length != colors.length) {
			trace("addVertexes: Arrays dont have the same length " + vectors.length + " | " + normals.length + " | " + uvs.length + " | " + colors.length);
		}

		var structSize = Math.floor(vertexStructure.byteSize() / 4);
		var baseIndex:Int = vertexCount * structSize;
		var vertexes:Float32Array = vertexBuffer.lock();
		for(i in 0...vectors.length) {
			setVertex(vertexes, baseIndex, vectors[i], normals[i], uvs[i], colors[i]);
			baseIndex += structSize;
		}
		vertexBuffer.unlock();
		vertexCount += vectors.length;
	}

	public inline function addIndexes(indexes:Array<Int>) {
		var baseIndex = indexCount;
		var indexes = indexBuffer.lock();
		for(index in indexes) {
			indexes.set(baseIndex, index);
			baseIndex++;
		}
		indexBuffer.unlock();
		indexCount += indexes.length;
		triangleCount = Math.floor(indexCount / 3);
	}

	private inline function setVertex(vertexes:Float32Array, baseIndex:Int, vector:Vector3, normal:Vector3, uv:Vector2, color:Color) {
		vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 0, vector.x);
		vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 1, vector.y);
		vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 2, vector.z);
		vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 0, normal.x);
		vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 1, normal.y);
		vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 2, normal.z);
		vertexes.set(baseIndex + G4Constants.UV_OFFSET + 0, uv.x);
		vertexes.set(baseIndex + G4Constants.UV_OFFSET + 1, uv.y);
		vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 0, color.R);
		vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 1, color.G);
		vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 2, color.B);
	}
	
	public static inline function getSTLMesh(blob:Blob, pipeline:BasicPipeline, color:Color = null):BasicMesh {
		var objMeshData = STLMeshLoader.parse(blob);
		var mesh:BasicMesh = fromSTLData(objMeshData, pipeline);
		if(color != null) {
			setAllVertexesColor(mesh.vertexBuffer, pipeline.vertexStructure, color);
		}
		return mesh;
	}

	public static function fromSTLData(data:STLMeshData, pipeline:BasicPipeline, vertexUsage:Usage = null, indexUsage:Usage = null):BasicMesh {
		var mesh:BasicMesh = new BasicMesh(data.vertexCount, data.triangleCount * 3, pipeline, vertexUsage, indexUsage);
		
		var vertexes = mesh.vertexBuffer.lock();
		var vertexStep:Int = Math.floor(pipeline.vertexStructure.byteSize() / 4);
		var baseIndex:Int = 0;
		var normalIndex:Int = 0;
		for(i in 0...data.vertexCount) {
			baseIndex = i * vertexStep;
			
			vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 0, data.vertexes[i * 3 + 0]);
			vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 1, data.vertexes[i * 3 + 1]);
			vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 2, data.vertexes[i * 3 + 2]);
			
			normalIndex = Math.floor(i / 3);
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 0, data.normals[normalIndex * 3 + 0]);
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 1, data.normals[normalIndex * 3 + 1]);
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 2, data.normals[normalIndex * 3 + 2]);
		}
		mesh.vertexBuffer.unlock();
		
		var indexes = mesh.indexBuffer.lock();
		for(i in 0...data.triangleCount * 3) {
			indexes.set(i, i);
		}
		mesh.indexBuffer.unlock();
		
		mesh.vertexCount = data.vertexCount;
		mesh.indexCount = data.triangleCount * 3;
		mesh.triangleCount = data.triangleCount;

		return mesh;
	}

	public static inline function getOBJMesh(blob:Blob, pipeline:BasicPipeline, color:Color = null):BasicMesh {
		var objMeshData = OBJMeshLoader.parse(blob);
		var mesh:BasicMesh = fromOBJData(objMeshData, pipeline);
		if(color != null) {
			setAllVertexesColor(mesh.vertexBuffer, pipeline.vertexStructure, color);
		}
		return mesh;
	}

	public static function fromOBJData(data:OBJMeshData, pipeline:BasicPipeline, vertexUsage:Usage = null, indexUsage:Usage = null) {
		var mesh:BasicMesh = new BasicMesh(data.vertexCount, data.triangleCount * 3, pipeline, vertexUsage, indexUsage);

		var vertexes = mesh.vertexBuffer.lock();
		var vertexStep:Int = Math.floor(pipeline.vertexStructure.byteSize() / 4);
		var baseIndex:Int = 0;
		var normalIndex:Int = 0;
		for(i in 0...data.vertexCount) {
			baseIndex = i * vertexStep;
			
			vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 0, data.vertexes[i * 3 + 0]);
			vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 1, data.vertexes[i * 3 + 1]);
			vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 2, data.vertexes[i * 3 + 2]);
			
			vertexes.set(baseIndex + G4Constants.UV_OFFSET + 0, data.uvs[i * 2 + 0]);
			vertexes.set(baseIndex + G4Constants.UV_OFFSET + 1, data.uvs[i * 2 + 1]);
			
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 0, data.normals[i * 3 + 0]);
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 1, data.normals[i * 3 + 1]);
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 2, data.normals[i * 3 + 2]);
		}
		mesh.vertexBuffer.unlock();
		
		var indexes = mesh.indexBuffer.lock();
		for(i in 0...data.triangleCount * 3) {
			indexes.set(i, i);
		}
		mesh.indexBuffer.unlock();

		mesh.vertexCount = data.vertexCount;
		mesh.indexCount = data.triangleCount * 3;
		mesh.triangleCount = data.triangleCount;

		return mesh;
	}

	public static function fromOGEXGeometry(geometry:Geometry, pipeline:BasicPipeline, vertexUsage:Usage = null, indexUsage:Usage = null) {
		var geometry = geometry;
		
		var mesh:BasicMesh = new BasicMesh(geometry.vertexCount, geometry.triangleCount * 3, pipeline, vertexUsage, indexUsage);

		var vertexes = mesh.vertexBuffer.lock();
		var vertexStep:Int = Math.floor(pipeline.vertexStructure.byteSize() / 4);
		var baseIndex:Int = 0;
		for(i in 0...geometry.vertexCount) {
			baseIndex = i * vertexStep;
			
			vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 0, geometry.vertexes[i * 3 + 0]);
			vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 1, geometry.vertexes[i * 3 + 1]);
			vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 2, geometry.vertexes[i * 3 + 2]);
			
			vertexes.set(baseIndex + G4Constants.UV_OFFSET + 0, geometry.uvs != null ? geometry.uvs[i * 2 + 0] : 0);
			vertexes.set(baseIndex + G4Constants.UV_OFFSET + 1, geometry.uvs != null ? 1 - geometry.uvs[i * 2 + 1] : 0);
			
			vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 0, geometry.colors != null ? geometry.colors[i * 3 + 0] : 0);
			vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 1, geometry.colors != null ? geometry.colors[i * 3 + 1] : 0);
			vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 2, geometry.colors != null ? geometry.colors[i * 3 + 2] : 0);
			
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 0, geometry.normals[i * 3 + 0]);
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 1, geometry.normals[i * 3 + 1]);
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 2, geometry.normals[i * 3 + 2]);
		}
		mesh.vertexBuffer.unlock();
		
		var indexes = mesh.indexBuffer.lock();
		for(i in 0...geometry.triangleCount * 3) {
			indexes.set(i, Math.floor(geometry.indices[i]));
		}
		mesh.indexBuffer.unlock();

		mesh.vertexCount = geometry.vertexCount;
		mesh.indexCount = geometry.triangleCount * 3;
		mesh.triangleCount = geometry.triangleCount;

		return mesh;
	}

	public static function getOGEXMeshes(blob:Blob, pipeline:BasicPipeline, color:Color = null):Array<BasicMesh> {
		var ogexMeshData = OGEXMeshLoader.parse(blob);
		var meshes:Array<BasicMesh> = [];
		var mesh:BasicMesh = null;
		for(node in ogexMeshData.geometryNodes) {
			mesh = fromOGEXGeometry(ogexMeshData.getGeometry(node.geometryName), pipeline);
            mesh.transform.fromMatrix(node.transform);
			if(color != null) {
				setAllVertexesColor(mesh.vertexBuffer, pipeline.vertexStructure, color);
			}
			meshes.push(mesh);
		}
		return meshes;
	}

	public static inline function getOGEXMesh(blob:Blob, pipeline:BasicPipeline, color:Color = null, id:Int = 0):BasicMesh {
		return getOGEXMeshes(blob, pipeline, color)[id];
	}

	public static function setAllVertexesColor(vertexBuffer:VertexBuffer, structure:VertexStructure, color:Color) {
		var vertexes = vertexBuffer.lock();
		if(vertexes.length == 0) {
			trace("Cant color vertexes, no vertexes found");
			return;
		} 
		var vertexStep:Int = Math.floor(structure.byteSize() / 4);
		var baseIndex:Int = 0;
		for(i in 0...vertexes.length) {
			baseIndex = i * vertexStep;

			vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 0, color.R);
			vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 1, color.G);
			vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 2, color.B);
		}
		vertexBuffer.unlock();
	}

	private static inline function addCreateVertex(vertexes:Float32Array, baseIndex:Int, x:Float, y:Float, z:Float, uvx:Float, uvy:Float) {
		vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 0, x);
		vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 1, y);
		vertexes.set(baseIndex + G4Constants.VERTEX_OFFSET + 2, z);
		
		vertexes.set(baseIndex + G4Constants.UV_OFFSET + 0, uvx);
		vertexes.set(baseIndex + G4Constants.UV_OFFSET + 1, uvy);
	}

	//TODO: Fix to it can make quads in any rotation
	public static function createQuadMesh(vector1:Vector3, vector2:Vector3, pipeline:BasicPipeline, color:Color = Color.White):BasicMesh {
		var mesh:BasicMesh = new BasicMesh(4, 6, pipeline);
		var midZ:Float = (vector1.z + vector2.z) / 2;
		var vector3:Vector3 = new Vector3(vector2.x, vector1.y, midZ);
		var vector4:Vector3 = new Vector3(vector1.x, vector2.y, midZ);
		var normal:Vector3 = new Vector3(0, 0, 1);
		
		var vertexes = mesh.vertexBuffer.lock();
		var vertexStep:Int = Math.floor(pipeline.vertexStructure.byteSize() / 4);
		
		addCreateVertex(vertexes, vertexStep * 0, vector1.x, vector1.y, vector1.z, 0, 0);
		addCreateVertex(vertexes, vertexStep * 1, vector2.x, vector1.y, vector1.z, 1, 0);
		addCreateVertex(vertexes, vertexStep * 2, vector1.x, vector2.y, vector1.z, 0, 1);
		addCreateVertex(vertexes, vertexStep * 3, vector2.x, vector2.y, vector1.z, 1, 1);
		
		var baseIndex:Int = 0;
		for(i in 0...4) {
			baseIndex = i * vertexStep;

			vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 0, color.R);
			vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 1, color.G);
			vertexes.set(baseIndex + G4Constants.COLOR_OFFSET + 2, color.B);
			
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 0, 1);
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 1, 0);
			vertexes.set(baseIndex + G4Constants.NORMAL_OFFSET + 2, 0);
		}
		mesh.vertexBuffer.unlock();
		
		var indexes = mesh.indexBuffer.lock();
		indexes.set(0, 0);
		indexes.set(1, 1);
		indexes.set(2, 2);
		indexes.set(3, 2);
		indexes.set(4, 1);
		indexes.set(5, 3);
		mesh.indexBuffer.unlock();

		mesh.vertexCount = 4;
		mesh.indexCount = 6;
		mesh.triangleCount = 2;

		// mesh.addTriangle(vector1, vector3, vector4,
		// 	normal, normal, normal, new Vector2(0, 0), new Vector2(1, 0), new Vector2(0, 1),
		// 	color);
		// mesh.addTriangle(vector4, vector2, vector3,
		// 	normal, normal, normal, new Vector2(1, 1), new Vector2(0, 1), new Vector2(1, 0),
		// 	color);
		return mesh;
	}

	public function get_modelMatrix():FastMatrix4 {
		return transform.getMatrix();
	}

}