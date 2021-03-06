package kext.g2basics;

import kha.Color;
import kha.Image;
import kha.math.Vector2;

import kext.g2basics.Transform2D;

import kext.ExtAssets;
import kext.loaders.AnimationLoader.AnimationData;

class AnimatedSprite extends Basic {

	public var sprite:BasicSprite;

	public var lastFrame:Int;
	public var currentFrame:Int;
	public var currentAnimation:AnimationData;

	public var originOffset:Vector2;

	public var animationTime:Float;
	public var animationRunning:Bool;

	public var color(get, set):Color;
	public var transform(get, null):Transform2D;

	public function new(x:Float, y:Float, animation:AnimationData = null, startingFrame:Int = 0) {
		super();

		sprite = new BasicSprite(x, y, null);

		originOffset = new Vector2(0, 0);

		setAnimation(animation, startingFrame);

		animationTime = 0;
	}

	override public function update(delta:Float) {
		super.update(delta);

		if(animationRunning && currentAnimation != null) {
			animationTime += delta;
			while(animationTime > currentAnimation.frameDelta) {
				currentFrame++;
				animationTime -= currentAnimation.frameDelta;
			}
			if(currentAnimation.loop) { currentFrame = currentFrame % currentAnimation.length; }
			
			if(currentFrame >= currentAnimation.length) { stop(); }
			else if(currentFrame != lastFrame) {
				sprite.setFrame(currentAnimation.frames[currentFrame]);
				lastFrame = currentFrame;
			}
		}
	}

	public inline function play(startingFrame:Int = 0) {
		currentFrame = startingFrame;
		animationRunning = true;
	}

	public inline function stop() {
		animationRunning = false;
	}

	public function setAnimation(animation:AnimationData, startingFrame:Int = 0, start:Bool = true) {
		lastFrame = startingFrame;
		currentFrame = startingFrame;
		currentAnimation = animation;
		if(animation != null) {
			sprite.setFrame(animation.frames[currentFrame]);
		}
		animationRunning = start;
	}

	override public function render(backbuffer:Image) {
		sprite.render(backbuffer);
	}

	public inline function get_transform():Transform2D {
		return sprite.transform;
	}

	public inline function get_color():Color {
		return sprite.color;
	}

	public inline function set_color(color:Color):Color {
		return sprite.color = color;
	}

	public static function fromAnimationName(x:Float, y:Float, animationName:String, startingFrame:Int = 0):AnimatedSprite {
		return new AnimatedSprite(x, y, ExtAssets.animations.get(animationName), startingFrame);
	}

	public inline function get_transform():Transform2D {
		return sprite.transform;
	}
	public inline function set_transform(value:Transform2D):Transform2D {
		return sprite.transform = value;
	}

}