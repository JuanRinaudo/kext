package kext.g4basics;

import kha.Color;
import kha.Image;
import kha.Blob;

import kha.arrays.Float32Array;

import kha.math.FastMatrix4;

import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexStructure;
import kha.graphics4.Usage;

import kext.loaders.OGEXMeshLoader;

typedef MeshJoint = {
	id:Int,
	name:String,
	transform:FastMatrix4,
	parentJoint:MeshJoint,
	childJoints:Array<MeshJoint>
}

typedef MeshSkeleton = {
	rootJoint:MeshJoint
}

class SkeletalMesh {

	public var vertexBuffer:VertexBuffer;
	public var indexBuffer:IndexBuffer;

	public var triangleCount:UInt = 0;
	public var indexCount:UInt = 0;
	public var vertexCount:UInt = 0;
	public var vertexStructure:VertexStructure;

	public var modelMatrix(get, null):FastMatrix4;

	public var transform:Transform3D;

	public var boneIndex:Map<String, Int>;
	public var boneTransform:Map<String, FastMatrix4>;

	public var texture:Image;

	public var animationBuffer:Float32Array;
	public var mainNode:Node;

	public var fps:Float = 30;

	public function new(vertexCount:Int, indexCount:Int, structure:VertexStructure, vertexUsage:Usage = null, indexUsage:Usage = null) {
		if(vertexUsage == null) { vertexUsage = Usage.StaticUsage; }
		if(indexUsage == null) { indexUsage = Usage.StaticUsage; }
		vertexBuffer = new VertexBuffer(vertexCount, structure, vertexUsage);
		indexBuffer = new IndexBuffer(indexCount, indexUsage);

		vertexStructure = structure;

		animationBuffer = new Float32Array(G4Constants.MAX_BONES * 16);
		for(i in 0...animationBuffer.length) {
			animationBuffer.set(i, 0);
		}

		transform = new Transform3D();
	}

	public function drawMesh(backbuffer:Image, pipeline:BasicPipeline, setPipeline:Bool = true) {
		modelMatrix = transform.getMatrix();

		if(setPipeline) { backbuffer.g4.setPipeline(pipeline); }
		backbuffer.g4.setVertexBuffer(vertexBuffer);
		backbuffer.g4.setIndexBuffer(indexBuffer);
		backbuffer.g4.setMatrix(pipeline.locationMVPMatrix, pipeline.getMVPMatrix(modelMatrix));
		backbuffer.g4.setMatrix(pipeline.locationModelMatrix, modelMatrix);
		backbuffer.g4.setMatrix3(pipeline.locationNormalMatrix, pipeline.getNormalMatrix(modelMatrix));
		if(texture != null) {
			backbuffer.g4.setTexture(pipeline.textureUnit, texture);
		}
		calculateSkeletonBones(mainNode);
		backbuffer.g4.setFloats(pipeline.getConstantLocation(G4Constants.JOINT_TRANSFORMS), animationBuffer);
		backbuffer.g4.drawIndexedVertices();
	}

	public static function fromOGEXData(geometry:Geometry, skin:Skin, structure:VertexStructure, vertexUsage:Usage = null, indexUsage:Usage = null) {
		var mesh:SkeletalMesh = new SkeletalMesh(geometry.vertexCount, geometry.triangleCount * 3, structure, vertexUsage, indexUsage);

		var vertexes = mesh.vertexBuffer.lock();
		var vertexStep:Int = Math.floor(structure.byteSize() / 4);
		var baseIndex:Int = 0;
		var boneIndexOffset:Int = 0;
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

			var boneCount:Int = skin.boneCountVertex[i];
			vertexes.set(baseIndex + G4Constants.JOINT_INDEX_OFFSET + 0, boneCount > 0 ? skin.boneIndexes[boneIndexOffset + 0] : 0);
			vertexes.set(baseIndex + G4Constants.JOINT_INDEX_OFFSET + 1, boneCount > 1 ? skin.boneIndexes[boneIndexOffset + 1] : 0);
			vertexes.set(baseIndex + G4Constants.JOINT_INDEX_OFFSET + 2, boneCount > 2 ? skin.boneIndexes[boneIndexOffset + 2] : 0);
			vertexes.set(baseIndex + G4Constants.JOINT_INDEX_OFFSET + 3, boneCount > 3 ? skin.boneIndexes[boneIndexOffset + 3] : 0);
			
			vertexes.set(baseIndex + G4Constants.JOINT_WEIGHT_OFFSET + 0, boneCount > 0 ? skin.boneWeights[boneIndexOffset + 0] : 0);
			vertexes.set(baseIndex + G4Constants.JOINT_WEIGHT_OFFSET + 1, boneCount > 1 ? skin.boneWeights[boneIndexOffset + 1] : 0);
			vertexes.set(baseIndex + G4Constants.JOINT_WEIGHT_OFFSET + 2, boneCount > 2 ? skin.boneWeights[boneIndexOffset + 2] : 0);
			vertexes.set(baseIndex + G4Constants.JOINT_WEIGHT_OFFSET + 3, boneCount > 3 ? skin.boneWeights[boneIndexOffset + 3] : 0);
			boneIndexOffset += boneCount;
		}
		mesh.vertexBuffer.unlock();
		
		var indexes = mesh.indexBuffer.lock();
		for(i in 0...geometry.triangleCount * 3) {
			indexes.set(i, Math.floor(geometry.indices.get(i)));
		}
		mesh.indexBuffer.unlock();

		mesh.vertexCount = geometry.vertexCount;
		mesh.indexCount = geometry.triangleCount * 3;
		mesh.triangleCount = geometry.triangleCount;

		return mesh;
	}

    public static function getOGEXAnimatedMesh(blob:Blob, structure:VertexStructure, color:Color = null, id:Int = 0):SkeletalMesh {
		var ogexMeshData = OGEXMeshLoader.parse(blob);
		var meshes:Array<SkeletalMesh> = [];
		var mesh:SkeletalMesh = null;
		for(node in ogexMeshData.geometryNodes) {
			var skin:Skin = ogexMeshData.getSkin(node.geometryName);
			var geometry:Geometry = ogexMeshData.getGeometry(node.geometryName);
			mesh = fromOGEXData(geometry, skin, structure);
            mesh.transform.fromMatrix(node.transform);
			if(color != null) {
				BasicMesh.setAllVertexesColor(mesh.vertexBuffer, structure, color);
			}
			mesh.mainNode = ogexMeshData.getNode("$node1");
			mesh.boneIndex = new Map<String, Int>();
			var i = 0;
			for(boneName in skin.skeleton.bones) {
				mesh.boneIndex.set(boneName, i);
				i += 16;
			}
			mesh.boneTransform = new Map<String, FastMatrix4>();
			i = 0;
			for(boneName in skin.skeleton.bones) {
				mesh.boneTransform.set(boneName, skin.skeleton.transforms[i]);
				i++;
			}
        }

		return mesh;
	}

	public function calculateSkeletonBones(node:Node) {
		for(child in node.bones) {
			calculateTransformsFloatArray(child, FastMatrix4.identity());
		}
	}

	public function calculateTransformsFloatArray(currentNode:BoneNode, parentTransform:FastMatrix4) {
		var finalTransform:FastMatrix4;
		var passTransform:FastMatrix4;
		var bindTransform:FastMatrix4 = boneTransform.get(currentNode.key);
		var animationIndex = boneIndex.get(currentNode.key);
		if(currentNode.animation != null) {
			var int:Int = Math.floor((kext.Application.time * fps) % currentNode.animation.track.values.length);
			finalTransform = currentNode.animation.track.values[int];
		} else {
			finalTransform = bindTransform;
		}
		passTransform = parentTransform.multmat(finalTransform);
		finalTransform = passTransform.multmat(bindTransform.inverse());
		animationBuffer.set(animationIndex + 0, finalTransform._00);
		animationBuffer.set(animationIndex + 1, finalTransform._01);
		animationBuffer.set(animationIndex + 2, finalTransform._02);
		animationBuffer.set(animationIndex + 3, finalTransform._03);
		animationBuffer.set(animationIndex + 4, finalTransform._10);
		animationBuffer.set(animationIndex + 5, finalTransform._11);
		animationBuffer.set(animationIndex + 6, finalTransform._12);
		animationBuffer.set(animationIndex + 7, finalTransform._13);
		animationBuffer.set(animationIndex + 8, finalTransform._20);
		animationBuffer.set(animationIndex + 9, finalTransform._21);
		animationBuffer.set(animationIndex + 10, finalTransform._22);
		animationBuffer.set(animationIndex + 11, finalTransform._23);
		animationBuffer.set(animationIndex + 12, finalTransform._30);
		animationBuffer.set(animationIndex + 13, finalTransform._31);
		animationBuffer.set(animationIndex + 14, finalTransform._32);
		animationBuffer.set(animationIndex + 15, finalTransform._33);
		for(child in currentNode.boneNodes) {
			calculateTransformsFloatArray(child, passTransform);
		}
	}

	public function get_modelMatrix():FastMatrix4 {
		return transform.getMatrix();
	}

}