package kext.platform.android;

import kha.Scaler;
import kha.Scaler.TargetRectangle;
import kha.System;
import kha.SystemImpl;
import kha.System.SystemOptions;

import kext.platform.IPlatform;

class Platform implements IPlatform {

	public var targetRectangle:TargetRectangle;

	public var isMobile(default, null):Bool;
	public var isDesktop(default, null):Bool;

	private var sysOptions:SystemOptions;

	private var width:Int;
	private var height:Int;
	
	public function new(systemOptions:SystemOptions) {
		isMobile = checkMobile();
		isDesktop = !isMobile;

		sysOptions = systemOptions;

		resizeHandler();
	}

	public function update(delta:Float) {
		if(SystemImpl.windowWidth(0) != width || SystemImpl.windowHeight(0) != height) {
			resizeHandler();
		}
	}

	public function addResizeHandler() {
		
	}

	private function resizeHandler() {
		width = SystemImpl.windowWidth(0);
		height = SystemImpl.windowHeight(0);
		targetRectangle = Scaler.targetRect(sysOptions.width, sysOptions.height, width, height, System.screenRotation);	
	}

	private function changeResolution(width:Int, height:Int) {
		
	}

	public function addFullscreenHandler() {
		// kha.SystemImpl.isFullscreen
	}

	private static inline function checkDesktop() {
		return false;
	}

	private static inline function checkMobile():Bool {
		return true;
	}

}