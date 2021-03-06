package kext;

import kha.Image;
import kha.Framebuffer;

class Basic {

	public var ID:UInt = 0;
	public var name(default, set):String;

	public function new() {
		ID = Application.getNextID();
		name = "Basic";
	}

	public function update(delta:Float) {
		#if debug
		#end
	}

	public function render(backbuffer:Image) {
		#if debug
		#end
	}

	public function renderFramebuffer(framebuffer:Framebuffer) {
		#if debug
		#end
	}

	public function set_name(value:String):String {
		return name = value + ' ($ID)';
	}
	
}