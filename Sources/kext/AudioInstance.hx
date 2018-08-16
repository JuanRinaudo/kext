package kext;

import kha.Sound;
import kha.audio1.AudioChannel;
import kha.audio2.Audio1;

class AudioInstance extends Basic {

    public var channel:AudioChannel;
    public var originalVolume:Float;

    public function new(sound:Sound, loop:Bool, volume:Float) {
        super();

        channel = Audio1.play(sound, loop);
        channel.volume = volume;
        originalVolume = volume;
    }

}