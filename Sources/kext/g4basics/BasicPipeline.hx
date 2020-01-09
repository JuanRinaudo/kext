package kext.g4basics;

import kha.Image;

import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.FragmentShader;
import kha.graphics4.CompareMode;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.BlendingFactor;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;

class BasicPipeline extends PipelineState {

	public var vertexStructure:VertexStructure;

	public var locationMVPMatrix:ConstantLocation;
	public var locationModelMatrix:ConstantLocation;
	public var locationProjectionMatrix:ConstantLocation;
	public var locationViewMatrix:ConstantLocation;
	public var locationProjectionViewMatrix:ConstantLocation;
	public var locationNormalMatrix:ConstantLocation;

	public var basicTexture:Bool = true;
	public var textureUnit:TextureUnit;

	public var camera:Camera3D;

	public function new(vertexShader:VertexShader, fragmentShader:FragmentShader, ?camera:Camera3D, ?vertexStructure:VertexStructure) {
		super();
		
		this.camera = (camera == null ? Application.mainCamera : camera);

		if(vertexStructure == null) {
			this.vertexStructure = new VertexStructure();
			addVertexData(G4Constants.VERTEX_DATA_POSITION, VertexData.Float3);
			addVertexData(G4Constants.VERTEX_DATA_NORMAL, VertexData.Float3);
			addVertexData(G4Constants.VERTEX_DATA_TEXUV, VertexData.Float2);
			addVertexData(G4Constants.VERTEX_DATA_COLOR, VertexData.Float3);
		}
		else {
			this.vertexStructure = vertexStructure;
		}

		this.vertexShader = vertexShader;
		this.fragmentShader = fragmentShader;

		blendSource = BlendingFactor.BlendOne;
		blendDestination = BlendingFactor.InverseSourceAlpha;
		alphaBlendSource = BlendingFactor.SourceAlpha;
		alphaBlendDestination = BlendingFactor.InverseSourceAlpha;

		depthWrite = true;
		depthMode = CompareMode.LessEqual;
	}

	public inline function getMVPMatrix(modelMatrix:FastMatrix4):FastMatrix4 {
		return camera.projectionViewMatrix.multmat(modelMatrix);
	}

	public inline function getNormalMatrix(modelMatrix:FastMatrix4):FastMatrix3 {
		return new FastMatrix3(modelMatrix._00, modelMatrix._10, modelMatrix._20,
			modelMatrix._01, modelMatrix._11, modelMatrix._21,
			modelMatrix._02, modelMatrix._12, modelMatrix._22).inverse().transpose();
	}

	public function addVertexData(name:String, dataType:VertexData) {
		vertexStructure.add(name, dataType);
	}

	override public function compile() {
		inputLayout = [vertexStructure];
		super.compile();

		locationMVPMatrix = getConstantLocation(G4Constants.MVP_MATRIX);
		locationModelMatrix = getConstantLocation(G4Constants.MODEL_MATRIX);
		locationViewMatrix = getConstantLocation(G4Constants.VIEW_MATRIX);
		locationProjectionMatrix = getConstantLocation(G4Constants.PROJECTION_MATRIX);
		locationProjectionViewMatrix = getConstantLocation(G4Constants.PROJECTION_VIEW_MATRIX);
		locationNormalMatrix = getConstantLocation(G4Constants.NORMAL_MATRIX);

		if(basicTexture) {
			textureUnit = getTextureUnit(G4Constants.TEXTURE);
		}
	}

	public inline function setDefaultTextureUnitParameters(backbuffer:Image, unit:TextureUnit) {
		backbuffer.g4.setTextureParameters(unit, TextureAddressing.Repeat, TextureAddressing.Repeat,
			TextureFilter.PointFilter, TextureFilter.PointFilter, MipMapFilter.NoMipFilter);
	}

}