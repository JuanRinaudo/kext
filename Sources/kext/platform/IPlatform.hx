package kext.platform;

import kha.Scaler.TargetRectangle;

interface IPlatform {
	public var targetRectangle:TargetRectangle;

	public var isMobile(default, null):Bool;
	public var isDesktop(default, null):Bool;
}