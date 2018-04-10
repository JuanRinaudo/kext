package kext.g2basics;

import kext.utils.Counter;
import kext.loaders.AnimationLoader.AnimationData;

class AnimatedSprite extends BasicSprite {

	private var lastFrame:Int;
	private var currentFrame:Int;
	private var currentAnimation:AnimationData;

	private var animationTime:Float;
	private var running:Bool;

	public function new(x:Float, y:Float, animation:AnimationData = null, startingFrame:Int = 0) {
		super(x, y, null);

		setAnimation(animation, startingFrame);

		animationTime = 0;
	}

	override public function update(delta:Float) {
		super.update(delta);

		if(running && currentAnimation != null) {
			animationTime += delta;
			currentFrame = Math.floor(animationTime / currentAnimation.frameDelta);
			if(currentAnimation.loop) { currentFrame = currentFrame % currentAnimation.length; }
			else if(currentFrame == currentAnimation.length - 1) { stop(); }
			if(currentFrame != lastFrame) {
				setFrame(currentAnimation.frames[currentFrame]);
				lastFrame = currentFrame;
			}
		}
	}

	public inline function play() {
		running = true;
	}

	public inline function stop() {
		running = false;
	}

	public function setAnimation(animation:AnimationData, startingFrame:Int = 0) {
		lastFrame = startingFrame;
		currentFrame = startingFrame;
		currentAnimation = animation;
		if(animation != null) {
			setFrame(animation.frames[currentFrame]);
		}
	}

}