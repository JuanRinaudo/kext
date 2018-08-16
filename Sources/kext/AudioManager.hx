package kext;

import kha.Sound;

class AudioManager extends Basic
{
	public var masterVolume(default, set):Float = 1;

	public var instances:Array<AudioInstance>;
	public var audioTimes:Array<Float>;
	public var audioTimesEnd:Array<Float>;

	public function new()
	{
		super();
		
		instances = [];
		audioTimes = [];
		audioTimesEnd = [];
	}
	
	override public function update(delta:Float) 
	{
		var instance:AudioInstance;
		var time:Float;
		var endTime:Float;
		for (i in 0...instances.length) {
			instance = instances[i];			
			
			if(instance != null) {
				audioTimes[i] += delta;
				time = audioTimes[i];
				endTime = audioTimesEnd[i];
				if (endTime > 0 && time > endTime) {
					instance.channel.stop();
				}
				
				if (instance.channel.finished) {
					endChannel(instance, i);
				}
			}
		}
	}

	public function endChannel(instance:AudioInstance, index:Int = -1) {
		if(index == -1) { index = instances.indexOf(instance); }
		instances.remove(instance);
		audioTimes.splice(index, 1);
		audioTimesEnd.splice(index, 1);
	}
	
	public function playSound(sound:Sound, volume:Float = 1, loop:Bool = false):AudioInstance {
		return playSoundSection(sound, -1, volume, loop);
	}
	
	public function playSoundSection(sound:Sound, end:Float, volume:Float = 1, loop:Bool = false):AudioInstance {
		var instance:AudioInstance = new AudioInstance(sound, loop, volume);
		if(instance.channel != null) {
			instance.channel.volume = volume * masterVolume;
			instances.push(instance);
			audioTimes.push(0);
			audioTimesEnd.push(end);
		}
		return instance;
	}
	
	public function pauseAll() {
		for (instance in instances) {
			instance.channel.pause();
		}
	}
	
	public function resumeAll() {
		for (instance in instances) {
			instance.channel.play();
		}
	}
	
	public function set_masterVolume(value:Float):Float {
		for (instance in instances) {
			instance.channel.volume = value * instance.originalVolume;
		}
		return masterVolume = value;
	}
	
}