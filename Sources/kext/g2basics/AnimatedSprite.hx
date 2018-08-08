package kext.g2basics;

import kha.Image;

import kext.ExtAssets;
import kext.loaders.AnimationLoader.AnimationData;

class AnimatedSprite extends BasicSprite {

	private var lastFrame:Int;
	private var currentFrame:Int;
	private var currentAnimation:AnimationData;

	private var animationTime:Float;
	private var animationRunning:Bool;

	public function new(x:Float, y:Float, animation:AnimationData = null, startingFrame:Int = 0) {
		super(x, y, null);

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
				setFrame(currentAnimation.frames[currentFrame]);
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
			setFrame(animation.frames[currentFrame]);
		}
		animationRunning = start;
	}

	public static function fromAnimationName(x:Float, y:Float, animationName:String, startingFrame:Int = 0):AnimatedSprite {
		return new AnimatedSprite(x, y, ExtAssets.animations.get(animationName), startingFrame);
	}

}