package kext.platform.krom;

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
	
	public function new(systemOptions:SystemOptions) {
		isMobile = checkMobile();
		isDesktop = !isMobile;

		sysOptions = systemOptions;

		var width:Int = Math.floor(Application.width);
		var height:Int = Math.floor(Application.height);
		targetRectangle = Scaler.targetRect(systemOptions.width, systemOptions.height, width, height, System.screenRotation);
	}

	public function addResizeHandler() {
		
	}

	private function resizeHandler() {
		
	}

	private function changeResolution(width:Int, height:Int) {
		
	}

	public function addFullscreenHandler() {
		// kha.SystemImpl.isFullscreen
	}

	private static inline function checkDesktop() {
		return true;
	}

	private static inline function checkMobile():Bool {
		return false;
	}

}