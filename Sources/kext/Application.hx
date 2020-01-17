package kext;

import kha.graphics2.ImageScaleQuality;
import kha.Assets;
import kha.Color;
import kha.Font;
import kha.Framebuffer;
import kha.Image;
import kha.System;
import kha.Scheduler;
import kha.System.SystemOptions;
import kha.Scaler;
import kha.Shaders;
import kha.Window;
import kha.WindowOptions;

import kha.math.Vector2;
import kha.math.FastMatrix3;

import kext.ExtAssets;

import kext.g4basics.Camera3D;
import kext.g4basics.BasicPipeline;

import kext.input.GamepadInput;
import kext.input.KeyboardInput;
import kext.input.MouseInput;
import kext.input.TouchInput;

import kext.events.ApplicationStartEvent;
import kext.events.ApplicationEndEvent;
import kext.events.LoadCompleteEvent;
import kext.events.ResizeEvent;
import kext.events.FullscreenEvent;

import kext.utils.Counter;

import kha.graphics4.PipelineState;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.FragmentShader;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;

import kext.debug.Debug;

#if (js && !kha_krom && !kha_debug_html5)
import kext.platform.html5.Platform;
#elseif kha_krom
import kext.platform.krom.Platform;
#elseif kha_debug_html5
import kext.platform.debughtml5.Platform;
#elseif kha_android
import kext.platform.android.Platform;
#end

#if (js && !kha_krom)
import kext.platform.html5.PlatformServices;
#elseif kha_krom
import kext.platform.krom.PlatformServices;
#elseif kha_android
// import kext.platform.android.PlatformServices;
#end

using kext.UniformType;

//TODOLIST:
// * Implement multiwindow and framebuffer rendering correctly

typedef ApplicationOptions = {
	?updateStart:Float,
	?updatePeriod:Float,
	initState:Class<AppState>,
	?stateArguments:Array<Dynamic>,
	defaultFontName:String,
	?defaultFontSize:Int,
	?bufferWidth:Int,
	?bufferHeight:Int,
	?platformServices:Bool,
	?extAssetManifests:Array<String>,
	?imgScaleQuality:ImageScaleQuality
}

typedef PostProcessingUniform = {
	type:UniformType,
	?location:ConstantLocation,
	?textureUnit:TextureUnit,
	value:Dynamic
}

class Application {

	private var windowOptions:WindowOptions;
	private var systemOptions:SystemOptions;
	private var options:ApplicationOptions;

	private var currentState:AppState;

	private var loaderProgress:Float;
	private var loaderUpdateID:Int;

	public static var instance:Application;

	public static var width:Float = 0;
	public static var height:Float = 0;

	public static var ratio(get, null):Float;

	public static var gamepad:GamepadInput;
	public static var keyboard:KeyboardInput;
	public static var mouse:MouseInput;
	public static var touch:TouchInput;

	public static var audio:AudioManager;

	public static var backbuffer:Image;
	public static var postbackbuffer:Image;

	public static var platform:Platform;
	// public static var services:PlatformServices;

	public static var mainCamera:Camera3D;

	public static var onApplicationStart:Signal<ApplicationStartEvent> = new Signal();
	public static var onApplicationEnd:Signal<ApplicationEndEvent> = new Signal();
	public static var onLoadComplete:Signal<LoadCompleteEvent> = new Signal();
	public static var onResize:Signal<ResizeEvent> = new Signal();
	public static var onFullscreen:Signal<FullscreenEvent> = new Signal();

	public static var time:Float = 0;
	public static var deltaTime(default, null):Float = 0;
	public static var paused:Bool = false;

	private static var nextID:UInt = 0;

	private static var postProcessingPipelines:Map<FragmentShader, BasicPipeline>;
	private static var postProcessingUniforms:Map<FragmentShader, Map<String, PostProcessingUniform>>;

	private static var updateCounters:Array<Counter> = [];

	public static var defaultFont(default, null):Font;
	public static var defaultFontSize:Int;

#if debug
	private var debug:Debug;
#end
	public function new(systemOptions:SystemOptions, applicationOptions:ApplicationOptions) {
		this.systemOptions = defaultSystemOptions(systemOptions);
		windowOptions = defaultWindowOptions(systemOptions.window);
		options = defaultApplicationOptions(applicationOptions);
		width = options.bufferWidth;
		height = options.bufferHeight;
		
		deltaTime = options.updatePeriod;

		System.start(systemOptions, onStart);

		if(Application.instance == null) {
			Application.instance = this;
		} else {
			//TODO
		}
	}

	private function defaultWindowOptions(windowOptions:WindowOptions):WindowOptions {
		return windowOptions;
	}

	private function defaultSystemOptions(systemOptions:SystemOptions):SystemOptions {
		return systemOptions;
	}

	private function defaultApplicationOptions(applicationOptions:ApplicationOptions):ApplicationOptions {
		if(applicationOptions.updateStart == null) { applicationOptions.updateStart = 0; }
		if(applicationOptions.updatePeriod == null) { applicationOptions.updatePeriod = 1 / 60; }
		if(applicationOptions.stateArguments == null) { applicationOptions.stateArguments = []; }
		if(applicationOptions.defaultFontName == null) { applicationOptions.defaultFontName = "KenPixel"; }
		if(applicationOptions.defaultFontSize == null) { applicationOptions.defaultFontSize = 18; }
		if(applicationOptions.bufferWidth == null) { applicationOptions.bufferWidth = systemOptions.width; }
		if(applicationOptions.bufferHeight == null) { applicationOptions.bufferHeight = systemOptions.height; }
		if(applicationOptions.platformServices == null) { applicationOptions.platformServices = false; }
		if(applicationOptions.extAssetManifests == null) { applicationOptions.extAssetManifests = []; }
		if(applicationOptions.imgScaleQuality == null) { applicationOptions.imgScaleQuality = ImageScaleQuality.Low; }
		return applicationOptions;
	}

	private function onStart(window:Window) {
#if debug
		debug = new Debug();
#end
		gamepad = new GamepadInput();
		keyboard = new KeyboardInput();
		mouse = new MouseInput();
		touch = new TouchInput();

		audio = new AudioManager();

		platform = new Platform(systemOptions, options);
		platform.addResizeHandler();
		platform.addFullscreenHandler();
		platform.setBlurFocusHandler(pause, resume);

		// if(options.platformServices) {
		// 	services = new PlatformServices();
		// }

		createBuffers(options.bufferWidth, options.bufferHeight);

		postProcessingPipelines = new Map();
		postProcessingUniforms = new Map();
		setPostProcessingShader(Shaders.painter_image_frag);

		loaderUpdateID = Scheduler.addTimeTask(loaderUpdatePass, options.updateStart, options.updatePeriod);
		System.notifyOnFrames(loaderRenderPass);

		Assets.loadEverything(loadCompleteHandler);

		onApplicationStart.dispatch();
	}

	public function resizeBuffers(width:Int, height:Int) {
		options.bufferWidth = width;
		options.bufferHeight = height;
		platform.changeResolution(platform.screenWidth, platform.screenHeight);
		createBuffers(width, height);
	}

	private function createBuffers(width:Int, height:Int) {
		backbuffer = Image.createRenderTarget(width, height, TextureFormat.RGBA32, DepthStencilFormat.DepthOnly);
		postbackbuffer = Image.createRenderTarget(width, height, TextureFormat.RGBA32, DepthStencilFormat.DepthOnly);
	}

	private function loadCompleteHandler() {
		defaultFont = Reflect.getProperty(Assets.fonts, options.defaultFontName);
		defaultFontSize = options.defaultFontSize;
		
		for(manifest in options.extAssetManifests) {
			ExtAssets.parseAssets(Assets.blobs.get(manifest + "_json"));
		}

		onLoadComplete.dispatch();
		parsingCompleteHandler();
	}

	private function parsingCompleteHandler() {
		// if(options.platformServices) {
		// 	services.init(serviceInitCompleted);
		// } else {
			serviceInitCompleted({});
		// }
	}

	private function serviceInitCompleted(response:Dynamic) {
		System.removeFramesListener(loaderRenderPass);
		System.notifyOnFrames(renderPass);

		Scheduler.removeTimeTask(loaderUpdateID);
		Scheduler.addTimeTask(updatePass, options.updateStart, options.updatePeriod);
		
		currentState = Type.createInstance(options.initState, options.stateArguments);
	}

	private function loaderUpdatePass() {
		time += options.updatePeriod;
	}

	private function loaderRenderPass(framebuffers:Array<Framebuffer>) {
		var framebuffer:Framebuffer = framebuffers[0];

		backbuffer.g2.begin(true);
		
		backbuffer.g2.fillRect(0, height * 0.4, width * Assets.progress, height * 0.2);
		
		var barWidth:Float = width * (Math.cos(time) + 1) * 0.25;
		backbuffer.g2.fillRect(width * 0.5 - barWidth, height * 0.6, barWidth * 2, height * 0.1);
		backbuffer.g2.end();

		framebuffer.g2.imageScaleQuality = options.imgScaleQuality;
		framebuffer.g2.begin(true);
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	private function renderPass(framebuffers:Array<Framebuffer>) {
		var framebuffer:Framebuffer = framebuffers[0];

		if(currentState != null) {
			currentState.render(backbuffer);
		}
		
		var buffer1:Image = postbackbuffer;
		var buffer2:Image = backbuffer;
	
		for(pipeline in postProcessingPipelines) {
			buffer1.g2.pipeline = pipeline;
			buffer1.g2.begin(false);
			setUniformParameters(pipeline, buffer1);
			Scaler.scale(buffer2, buffer1, System.screenRotation);
			buffer1.g2.end();
			if(buffer1 == backbuffer) { buffer1 = postbackbuffer; buffer2 = backbuffer; }
			else { buffer1 = backbuffer; buffer2 = postbackbuffer; }
		}
		backbuffer.g2.pipeline = null;
		if(buffer2 == postbackbuffer) { //If last buffer used is post back buffer draw to normal buffer
			backbuffer.g2.begin(false);
			Scaler.scale(postbackbuffer, backbuffer, System.screenRotation);
			backbuffer.g2.end();
		}
#if debug
		debug.render(backbuffer);
#end
		if (paused) {
			backbuffer.g2.begin(false);

			backbuffer.g2.pushTransformation(FastMatrix3.identity());
			backbuffer.g2.color = Color.fromFloats(0, 0, 0, 0.5);
			backbuffer.g2.fillRect(0, 0, width, height);
			
			backbuffer.g2.color = Color.fromFloats(1, 1, 1, 0.5);
			backbuffer.g2.fillTriangle(	width * 0.33, height * 0.33,
										width * 0.33, height * 0.66,
										width * 0.66, height * 0.5);
			backbuffer.g2.end();
		}

		framebuffer.g2.imageScaleQuality = ImageScaleQuality.Low;
		framebuffer.g2.begin(true);
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();

		if(currentState != null) {
			currentState.renderFramebuffer(framebuffer);
		}
	}

	private inline function setUniformParameters(pipeline:PipelineState, buffer:Image) {
		var uniforms:Map<String, PostProcessingUniform> = postProcessingUniforms.get(pipeline.fragmentShader);
		//buffer.g4.setVector2(pipeline.getConstantLocation("RENDER_SIZE"), new FastVector2(systemOptions.width, systemOptions.height)); //TODO: FIX RENDER SIZE WARNING
		for(uniform in uniforms) {
			switch(uniform.type) {
				case BOOL:
					buffer.g4.setBool(uniform.location, uniform.value);
				case FLOAT:
					buffer.g4.setFloat(uniform.location, uniform.value);
				// case FLOAT2:
				// 	buffer.g4.setFloat(uniform.location, uniform.value); //TODO		
				// case FLOAT3:
				// 	buffer.g4.setFloat(uniform.location, uniform.value); //TODO
				// case FLOAT4:
				// 	buffer.g4.setFloat(uniform.location, uniform.value); //TODO
				case INT:
					buffer.g4.setInt(uniform.location, uniform.value);
				case MATRIX3:
					buffer.g4.setMatrix3(uniform.location, uniform.value);
				case MATRIX:
					buffer.g4.setMatrix(uniform.location, uniform.value);
				case VECTOR2:
					buffer.g4.setVector2(uniform.location, uniform.value);
				case VECTOR3:
					buffer.g4.setVector3(uniform.location, uniform.value);
				case VECTOR4:
					buffer.g4.setVector4(uniform.location, uniform.value);
				case CUBEMAP:
					buffer.g4.setCubeMap(uniform.textureUnit, uniform.value);
				case TEXTURE:
					buffer.g4.setTexture(uniform.textureUnit, uniform.value);
				case IMAGETEXTURE:
					buffer.g4.setImageTexture(uniform.textureUnit, uniform.value);
				case VIDEOTEXTURE:
					buffer.g4.setVideoTexture(uniform.textureUnit, uniform.value);
			}
		}
	}

	private function updatePass() {
		for(counter in updateCounters) {
			counter.tick();
		}

		if(currentState != null && !paused) {
			time += options.updatePeriod;
			currentState.update(options.updatePeriod);
		}
#if debug
		debug.update(options.updatePeriod);
#end
		platform.update(options.updatePeriod);

		gamepad.update(options.updatePeriod);
		keyboard.update(options.updatePeriod);
		mouse.update(options.updatePeriod);
		touch.update(options.updatePeriod);

		audio.update(options.updatePeriod);
	}

	public static function getNextID():UInt {
		return nextID++;
	}

	public static function setPostProcessingShader(shader:FragmentShader) {
		#if !kha_krom //TODO: Check why this breaks on krom
		var pipeline:BasicPipeline = new BasicPipeline(Shaders.painter_image_vert, shader);
		pipeline.compile();
		postProcessingPipelines.set(shader, pipeline);
		postProcessingUniforms.set(shader, new Map());
		#end
	}

	public static function removePostProcessingShader(shader:FragmentShader) {
		postProcessingPipelines.remove(shader);
		postProcessingUniforms.remove(shader);
	}

	public static inline function setPostProcesingConstantLocation(shader:FragmentShader, type:UniformType, name:String, value:Dynamic) {
		var pipeline:BasicPipeline = postProcessingPipelines.get(shader);
		if(pipeline == null) { trace('No pipeline found for the current post processing uniform: $name'); return; }
		
		var uniforms:Map<String, PostProcessingUniform> = postProcessingUniforms.get(shader);
		uniforms.set(name, {type: type, location: pipeline.getConstantLocation(name), value: value});
	}
	
	public static inline function setPostProcesingTextureUnit(shader:FragmentShader, type:UniformType, name:String, value:Dynamic) {
		var pipeline:BasicPipeline = postProcessingPipelines.get(shader);
		if(pipeline == null) { trace('No pipeline found for the current post processing uniform: $name'); return; }
		var uniforms:Map<String, PostProcessingUniform> = postProcessingUniforms.get(shader);
		uniforms.set(name, {type: type, textureUnit: pipeline.getTextureUnit(name), value: value});
	}

	public static function screenToGamePosition(vector:Vector2):Vector2 {
		return new Vector2((vector.x - platform.targetRectangle.x) / (platform.targetRectangle.scaleFactor),
			(vector.y - platform.targetRectangle.y) / (platform.targetRectangle.scaleFactor));
	} 

	public static function addCounterUpdate(counter:Counter) {
		updateCounters.push(counter);
	}

	public static function removeCounterUpdate(counter:Counter) {
		updateCounters.remove(counter);
	}

	public static function changeState(state:Class<AppState>, arguments:Array<Dynamic> = null) {
		if(arguments == null) { arguments = []; }
		var app:Application = Application.instance;
		app.currentState.destroy();
		app.currentState = Type.createInstance(state, arguments);
	}

	public static function reset() {
		var app:Application = Application.instance;
		app.currentState.destroy();
		app.currentState = Type.createInstance(app.options.initState, app.options.stateArguments);
	}
	
	public static function resetState() {
		var app:Application = Application.instance;
		var state = Type.getClass(app.currentState);
		app.currentState.destroy();
		app.currentState = Type.createInstance(state, []);
	}
	
	public static function pause():Void {
		if(audio != null) {
			audio.pauseAll();
		}
		
		if(gamepad != null) { gamepad.clearInput(); }
		if(keyboard != null) { keyboard.clearInput(); }
		if(mouse != null) { mouse.clearInput(); }
		if(touch != null) { touch.clearInput(); }
		
		paused = true;
	}
	
	public static function resume():Void {
		if(audio != null) {
			audio.resumeAll();
		}
		
		paused = false;
	}

	private static function get_ratio():Float {
		return width / height;
	}

}