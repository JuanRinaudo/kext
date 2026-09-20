package kext.extensions;

import kha.math.Vector3;
import kha.Color;

class ColorExt {
    
    public static function lerp(a:Color, b:Color, t:Float):Color {
        var R = (b.R - a.R) * t + a.R;
        var G = (b.G - a.G) * t + a.G;
        var B = (b.B - a.B) * t + a.B;
        var A = (b.A - a.A) * t + a.A;
        return Color.fromFloats(R, G, B, A);
    }

    public static function rgb2hsv(rgb:Vector3):Vector3
    {
        var hsv:Vector3 = new Vector3();
        var min:Float, max:Float, delta:Float;
        min = Math.min(rgb.x, Math.min(rgb.y, rgb.z));
        max = Math.max(rgb.x, Math.max(rgb.y, rgb.z));

        hsv.z = max;				// v
        delta = max - min;
        if(max != 0) {
            hsv.y = delta / max;		// s
        }
        else {
            // r = g = b = 0		// s = 0, v is undefined
            hsv.y = 0;
            hsv.x = -1;
            return hsv;
        }

        if(rgb.x == max) {
            hsv.x = (rgb.y - rgb.z) / delta;		// between yellow & magenta
        }
        else if(rgb.y == max) {
            hsv.x = 2 + (rgb.z - rgb.x) / delta;	// between cyan & yellow
        }
        else {
            hsv.x = 4 + (rgb.x - rgb.y) / delta;	// between magenta & cyan
        }

        hsv.x *= 60;				// degrees
        if(hsv.x < 0) {
            hsv.x += 360;
        }

        return hsv;
    }

    public static function hsv2rgb(hsv:Vector3):Vector3
    {
        var rgb:Vector3 = new Vector3();
        var i:Int;
        var f:Float, p:Float, q:Float, t:Float;

        if(hsv.y == 0) {
            // achromatic (grey)
            rgb.x = rgb.y = rgb.z = hsv.z;
            return rgb;
        }

        hsv.x *= 360;
        hsv.x /= 60;			// sector 0 to 5
        i = Math.floor(hsv.x);
        f = hsv.x - i;			// factorial part of h
        p = hsv.z * (1 - hsv.y);
        q = hsv.z * (1 - hsv.y * f);
        t = hsv.z * (1 - hsv.y * (1 - f));
        
        switch(i) {
            case 0:
                rgb.x = hsv.z;
                rgb.y = t;
                rgb.z = p;
            case 1:
                rgb.x = q;
                rgb.y = hsv.z;
                rgb.z = p;
            case 2:
                rgb.x = p;
                rgb.y = hsv.z;
                rgb.z = t;
            case 3:
                rgb.x = p;
                rgb.y = q;
                rgb.z = hsv.z;
            case 4:
                rgb.x = t;
                rgb.y = p;
                rgb.z = hsv.z;
            default: // case 5:
                rgb.x = hsv.z;
                rgb.y = p;
                rgb.z = q;
        }

        return rgb;
    }

}