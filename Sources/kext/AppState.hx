package kext;

import kha.Assets;
import kha.Image;
import kha.Color;
import kha.math.FastMatrix3;

import kext.g4basics.BasicMesh;

import zui.Zui;

class AppState extends Basic {

	private var ui:Zui;
	private var uiToggle:Bool = true;

	public function new() {
		super();

		createZUI();
	}

	private inline function beginAndClear2D(backbuffer:Image, clearColor:Color = null) {
		backbuffer.g2.begin(clearColor != null, clearColor);
	}

	private inline function clearTransformation2D(backbuffer:Image) {
		backbuffer.g2.transformation = FastMatrix3.identity();
	}

	private inline function beginAndClear(backbuffer:Image, clearColor:Color = null) {
		backbuffer.g4.begin();
		backbuffer.g4.clear(clearColor != null ? clearColor : Color.Black, Math.POSITIVE_INFINITY);
	}

	private function createZUI() {
		ui = new Zui({font: Assets.fonts.KenPixel});
	}

	public function destroy() {
		
	}

}