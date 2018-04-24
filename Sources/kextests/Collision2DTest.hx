package kextests;

import kha.Image;
import kha.Color;
import kha.math.Vector2;

import kext.Application;
import kext.AppState;
import kext.Basic;
import kext.ExtAssets;
import kext.math.BoundingRect;
import kext.g2basics.Text;
import kext.g2basics.Transform2D;
import kext.g2basics.BasicSprite;
import kext.g2basics.AnimatedSprite;

using kext.g2basics.Alignment;

class TestRectangle extends Basic {
	public var transform:Transform2D;
	public var bounds:BoundingRect;
	public var color:Color;

	public var dragabble:Bool;
	public var dragging:Bool;

	public function new(x:Float, y:Float, width:Float, height:Float) {
		super();

		var size = new Vector2(width, height);
		transform = Transform2D.fromFloats(x, y, 1, 1);
		bounds = new BoundingRect(transform, size);
		color = Color.Red;

		dragabble = false;
		dragging = false;
	}

	override public function update(delta:Float) {
		if(Application.mouse.buttonPressed(0) && bounds.checkVectorOverlap(Application.mouse.position)) { dragging = true; }
		if(Application.mouse.buttonReleased(0)) { dragging = false; }

		if(dragging) {
			transform.x = Application.mouse.x;
			transform.y = Application.mouse.y;
		}
	}

	override public function render(backbuffer:Image) {
		backbuffer.g2.color = color;
		backbuffer.g2.transformation = transform.getMatrix();
		backbuffer.g2.fillRect(0, 0, bounds.size.x, bounds.size.y);
	}
}

class Collision2DTest extends AppState {

	private var rectSize:Vector2;
	
	private var mouseRect:TestRectangle;

	private var rectangles:Array<TestRectangle>;

	private var collisionRect:TestRectangle;
	private var collisionRect2:TestRectangle;

	private var collisionRectCentered:TestRectangle;
	private var collisionRectCentered2:TestRectangle;

	private var collisionBounds:Array<BoundingRect>;

	private var sprite:BasicSprite;
	private var animated:AnimatedSprite;

	private static inline var SCREEN_WIDTH:Int = 640;
	private static inline var SCREEN_HEIGHT:Int = 640;

	public function new() {
		super();

		mouseRect = new TestRectangle(20, 40, 100, 50);

		rectangles = [];
		collisionBounds = [];
		collisionRect = createRectangle(200, 60, 100, 150, true, true);
		collisionRect2 = createRectangle(500, 60, 50, 50, true, true);

		collisionRectCentered = createRectangle(500, 500, 80, 80, true, true);
		collisionRectCentered.transform.originX = 40;
		collisionRectCentered.transform.originY = 40;
		
		collisionRectCentered2 = createRectangle(300, 500, 100, 100, true, true);
		collisionRectCentered2.transform.originX = 50;
		collisionRectCentered2.transform.originY = 50;

		sprite = BasicSprite.fromFrame(200, 400, ExtAssets.frames.PigBoost0);
		animated = new AnimatedSprite(400, 400, ExtAssets.animations.PigNormal);
	}

	private function createRectangle(x:Float, y:Float, width:Float, height:Float,
	  dragabble:Bool = false, collidable:Bool = false):TestRectangle {
		var rectangle:TestRectangle = new TestRectangle(x, y, width, height);
		rectangle.dragabble = dragabble;
		if(collidable) {
			collisionBounds.push(rectangle.bounds);
		}
		rectangles.push(rectangle);
		return rectangle;
	}

	override public function update(delta:Float) {
		for(rect in rectangles) {
			rect.update(delta);
		}

		sprite.update(delta);
		animated.update(delta);
	}

	override public function render(backbuffer:Image) {
		beginAndClear2D(backbuffer, Color.Black);

		Text.renderText(backbuffer, "Mouse Over Cube", 70, 20);
		mouseRect.color = mouseRect.bounds.checkVectorOverlap(Application.mouse.position) ? Color.Green : Color.Red;
		mouseRect.render(backbuffer);

		Text.renderText(backbuffer, "Cube cube collision", 480, 20, 0, 0, null, 0, MIDDLE);
		for(rect in rectangles) {
			rect.color = collidableRectColor(rect);
			rect.render(backbuffer);
		}

		sprite.render(backbuffer);
		animated.render(backbuffer);

		end2D(backbuffer);
	}

	public function collidableRectColor(rectangle:TestRectangle) {
		for(bounds in collisionBounds) {
			if(rectangle.bounds != bounds && rectangle.bounds.checkRectOverlap(bounds)) {
				return Color.Green;
			}
		}
		return Color.Red;
	}

	public static function createTestApplication() {
		var systemOptions:Dynamic = {
			width: SCREEN_WIDTH, height: SCREEN_HEIGHT,
			title: "Collision2DTest"
		};
		var applicationOptions:Dynamic = {
			initState: Collision2DTest,
			defaultFontName: "KenPixel"
		};
		new Application(systemOptions, applicationOptions);
	}

}