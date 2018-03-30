package kext.debug;

import kext.g4basics.BasicMesh;
import kext.g4basics.BasicPipeline;
import kext.loaders.OBJMeshLoader;
import kext.math.BoundingCube;
import kext.math.BoundingRect;

import kha.Assets;
import kha.Color;
import kha.Image;
import kha.Shaders;
import kha.math.Vector3;
import kha.math.FastMatrix4;
import kha.input.KeyCode;

class Debug extends Basic {

	public static var debugOn:Bool = false;
	
	private static var pipeline:BasicPipeline;
	private static var cube:BasicMesh;
	private static var cubeBound:BasicMesh;

	public static var boundsColor:Color = Color.Green;

	public function new() {
		super();

		pipeline = new BasicPipeline(Shaders.colored_vert, Shaders.colored_frag);
		pipeline.compile();

		Application.onLoadComplete.add(loadCompleteHandler);
	}

	override public function update(delta:Float) {
		if(Application.keyboard.keyDown(KeyCode.Shift) && Application.keyboard.keyPressed(KeyCode.D)) {
			debugOn = !debugOn;
		}
	}

	override public function render(backbuffer:Image) {

	}

	private function loadCompleteHandler() {
		if(Reflect.hasField(Assets.blobs, "cube_obj")) {
			var cubeBlob = Reflect.getProperty(Assets.blobs, "cube_obj");
			cube = BasicMesh.getOBJMesh(cubeBlob, pipeline.vertexStructure, Color.fromFloats(1, 1, 1, 1));
			cubeBound = BasicMesh.getOBJMesh(cubeBlob, pipeline.vertexStructure, Color.fromFloats(0, 0.7, 0, 0.25));
		}
	}

	public static function drawDebugBoundingCube(backbuffer:Image, fromPipeline:BasicPipeline, boundingCube:BoundingCube) {
		if(debugOn && cube != null) {
			var size:Vector3 = boundingCube.getCubeSize().mult(0.5);
			pipeline.camera = fromPipeline.camera;

			cube.setPosition(boundingCube.position.add(boundingCube.v1));
			cube.setSize(size.mult(0.1));
			cube.drawMesh(backbuffer, pipeline);
			cube.setPosition(boundingCube.position.add(boundingCube.v2));
			cube.setSize(size.mult(0.1));
			cube.drawMesh(backbuffer, pipeline);

			cube.setPosition(boundingCube.position);
			cube.setSize(size.mult(0.1));
			cube.drawMesh(backbuffer, pipeline);
			
			cubeBound.setPosition(boundingCube.getCubeCenter());
			cubeBound.setSize(size);
			cubeBound.drawMesh(backbuffer, pipeline);

			backbuffer.g4.setPipeline(fromPipeline);
		}
	}

	public static function drawDebugCube(backbuffer:Image, projectionViewMatrix:FastMatrix4, position:Vector3, size:Float) { //TODO Refactor this and SimpleLighting.hx to use new function 
		if(debugOn && cube != null) {
			backbuffer.g4.setPipeline(pipeline);

			backbuffer.g4.setVertexBuffer(cube.vertexBuffer);
			backbuffer.g4.setIndexBuffer(cube.indexBuffer);

			var modelMatrix:FastMatrix4 = FastMatrix4.identity()
				.multmat(FastMatrix4.translation(position.x, position.y, position.z))
				.multmat(FastMatrix4.scale(size, size, size));
			var mvpMatrix:FastMatrix4 = projectionViewMatrix.multmat(modelMatrix);
			backbuffer.g4.setMatrix(pipeline.locationMVPMatrix, mvpMatrix);
			backbuffer.g4.drawIndexedVertices();
		}
	}

	public static function drawBounds(backbuffer:Image, bounds:BoundingRect, color:Color = null) {
		if(debugOn) {
			backbuffer.g2.color = color != null ? color : boundsColor;
			backbuffer.g2.transformation._00 = 1;
			backbuffer.g2.transformation._11 = 1;
			backbuffer.g2.transformation._20 = bounds.position.x - bounds.offset.x;
			backbuffer.g2.transformation._21 = bounds.position.y - bounds.offset.y;
			if(bounds.checkVectorOverlap(kext.Application.mouse.mousePosition)) {
				backbuffer.g2.color = Color.Red;
			}
			backbuffer.g2.drawRect(0, 0, bounds.size.x * bounds.scale.x, bounds.size.y * bounds.scale.y);
		}
	}

}