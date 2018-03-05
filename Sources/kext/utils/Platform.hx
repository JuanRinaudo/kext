package kext.utils;

#if js
import js.Browser;
#end

class Platform {

	public var isMobile(default, null):Bool;
	public var isDesktop(default, null):Bool;

	public function new() {
		isMobile = checkMobile();
		isDesktop = !isMobile;
	}

	// public static function checkDesktop() {
	// 	#if js
	// 	var windows:Bool = Browser.navigator.userAgent.indexOf("Windows") > -1;
	// 	var linux:Bool = Browser.navigator.userAgent.indexOf("Linux") > -1;
	// 	var mac:Bool = Browser.navigator.userAgent.indexOf("Mac") > -1;
	// 	return windows || linux || mac;
	// 	#end
	// }

	public static function checkMobile():Bool {
		#if js
		return kha.SystemImpl.mobile;
		#end
	}

}