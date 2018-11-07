package kext.platform.krom;

import kext.Application.ApplicationOptions;
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
	
	public function new(systemOptions:SystemOptions, applicationOptions:ApplicationOptions) {
		isMobile = checkMobile();
		isDesktop = !isMobile;

		sysOptions = systemOptions;
		options = applicationOptions;

		var width:Int = Math.floor(Application.width);
		var height:Int = Math.floor(Application.height);
		targetRectangle = Scaler.targetRect(systemOptions.width, systemOptions.height, width, height, System.screenRotation);
	}

	public function update(delta:Float) {
		
	}

	public function addResizeHandler() {
		
	}

	private function resizeHandler() {
		
	}

	public function changeResolution(width:Int, height:Int) {
		
	}

	public function addFullscreenHandler() {
		// kha.SystemImpl.isFullscreen
	}

	public function setBlurFocusHandler(pause:Void -> Void, resume:Void -> Void) {
		
	}

	private static inline function checkDesktop() {
		return true;
	}

	private static inline function checkMobile():Bool {
		return false;
	}

	public function get_screenWidth():Int {
		return System.windowWidth(0);
	}

	public function get_screenHeight():Int {
		return System.windowHeight(0);
	}

}