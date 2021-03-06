package kext.platform.html5;

import kext.Application.ApplicationOptions;
import js.Browser;
import js.html.Document;
import js.html.Window;
import js.html.Element;

import kha.Scaler;
import kha.Scaler.TargetRectangle;
import kha.System;
import kha.System.SystemOptions;

import kext.platform.IPlatform;

class Platform implements IPlatform {

	public var targetRectangle:TargetRectangle;

	public var screenWidth(get, null):Int;
	public var screenHeight(get, null):Int;

	public var isMobile(default, null):Bool;
	public var isDesktop(default, null):Bool;

	private var sysOptions:SystemOptions;
	private var options:ApplicationOptions;
	
	private var document:Document;
	private var window:Window;
	private var canvas:Element;

	public function new(systemOptions:SystemOptions, applicationOptions:ApplicationOptions) {
		isMobile = checkMobile();
		isDesktop = !isMobile;

		sysOptions = systemOptions;
		options = applicationOptions;

		document = Browser.document;
		window = Browser.window;
		canvas = document.getElementById("khanvas");
	}

	public function update(delta:Float) {
		
	}

	public function addResizeHandler() {
		window.onresize = resizeHandler;
		resizeHandler();
	}

	private function resizeHandler() {
		var width:Int = window.innerWidth;
		var height:Int = window.innerHeight;
		changeResolution(width, height);
	}

	public function changeResolution(width:Int, height:Int) {
		var document = js.Browser.document;
		var game = document.getElementById("game");
		game.style.width = width + "px";
		game.style.height = height + "px";
		targetRectangle = Scaler.targetRect(options.bufferWidth, options.bufferHeight, width, height, System.screenRotation);
	}

	public function addFullscreenHandler() {
		if(isMobile) {
			untyped __js__("
				var element = document.getElementById('khanvas');
				element.addEventListener('touchend', function() { //Fullscreen
					if(element.requestFullscreen) {
						element.requestFullscreen();
					} else if(element.webkitRequestFullScreen) {
						element.webkitRequestFullScreen();
					} else if(element.mozRequestFullScreen) {
						element.mozRequestFullScreen();
					} else if(element.msRequestFullscreen) {
						element.msRequestFullscreen();
					}
					kext_Application.onFullscreen.dispatch({fullscreen: true});
				});");
		}
	}

	public function setBlurFocusHandler(pause:Void -> Void, resume:Void -> Void) {
		Browser.window.onblur = pause;
		Browser.window.onfocus = resume;
		canvas.onblur = pause;
		canvas.onfocus = resume;
	}

	private static inline function checkDesktop() {
		return !checkMobile();
	}

	private static inline function checkMobile():Bool {
		return kha.SystemImpl.mobile;
	}

	public function get_screenWidth():Int {
		return window.innerWidth;
	}

	public function get_screenHeight():Int {
		return window.innerHeight;
	}

}