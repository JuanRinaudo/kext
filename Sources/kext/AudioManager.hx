package kext;

import kha.Sound;
import kha.audio1.AudioChannel;
import kha.audio2.Audio1;

class AudioManager extends Basic
{	

	public var audios:Array<AudioChannel>;
	public var audioTimes:Array<Float>;
	public var audioTimesEnd:Array<Float>;

	public function new()
	{
		super();
		
		audios = [];
		audioTimes = [];
		audioTimesEnd = [];
	}
	
	override public function update(delta:Float) 
	{
		var audio:AudioChannel;
		var time:Float;
		var endTime:Float;
		for (i in 0...audios.length) {
			audio = audios[i];			
			
			if(audio != null) {
				audioTimes[i] += delta;
				time = audioTimes[i];
				endTime = audioTimesEnd[i];
				if (endTime > 0 && time > endTime) {
					audio.stop();
				}
				
				if (audio.finished) {
					endChannel(audio, i);
				}
			}
		}
	}

	public function endChannel(audio:AudioChannel, index:Int = -1) {
		if(index == -1) { index = audios.indexOf(audio); }
		audios.remove(audio);
		audioTimes.splice(index, 1);
		audioTimesEnd.splice(index, 1);
	}
	
	public function playSound(sound:Sound, volume:Float = 1, loop:Bool = false):AudioChannel {
		return playSoundSection(sound, -1, volume, loop);
	}
	
	public function playSoundSection(sound:Sound, end:Float, volume:Float = 1, loop:Bool = false):AudioChannel {
		var audio:AudioChannel = Audio1.play(sound, loop);
		if(audio != null) {
			audio.volume = volume;
			audios.push(audio);
			audioTimes.push(0);
			audioTimesEnd.push(end);
		}
		return audio;
	}
	
	public function pauseAll() {
		for (audio in audios) {
			audio.pause();
		}
	}
	
	public function resumeAll() {
		for (audio in audios) {
			audio.play();
		}		
	}
	
}