package kext.platform.debughtml5;

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

	public var isMobile(default, null):Bool;
	public var isDesktop(default, null):Bool;

	private var sysOptions:SystemOptions;
	
	private var document:Document;
	private var window:Window;
	private var canvas:Element;

	public function new(systemOptions:SystemOptions) {
		isMobile = checkMobile();
		isDesktop = !isMobile;

		sysOptions = systemOptions;

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

	private function changeResolution(width:Int, height:Int) {
		targetRectangle = Scaler.targetRect(sysOptions.width, sysOptions.height, width, height, System.screenRotation);
	}

	public function addFullscreenHandler() {
		
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

}