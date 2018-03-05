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

	public static function checkMobile() {
		#if js
		var android:Bool = Browser.navigator.userAgent.indexOf("Android") > -1;
		var iphone:Bool = Browser.navigator.userAgent.indexOf("iPhone") > -1;
		var ipad:Bool = Browser.navigator.userAgent.indexOf("iPad") > -1;
		var ipod:Bool = Browser.navigator.userAgent.indexOf("iPod") > -1;
		return android || iphone || ipad || ipod;
		#end
	}

}