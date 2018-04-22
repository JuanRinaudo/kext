package kext.platform;

import kha.Scaler.TargetRectangle;

interface IPlatform {
	public var targetRectangle:TargetRectangle;

	public var isMobile(default, null):Bool;
	public var isDesktop(default, null):Bool;

	public function addResizeHandler():Void;
	public function addFullscreenHandler():Void;
	public function setBlurFocusHandler(pause:Void -> Void, resume:Void -> Void):Void;
}