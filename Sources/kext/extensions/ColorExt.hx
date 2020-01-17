package kext.extensions;

import kha.Color;

class ColorExt {
    
    public static function lerp(a:Color, b:Color, t:Float):Color {
        var R = (b.R - a.R) * t + a.R;
        var G = (b.G - a.G) * t + a.G;
        var B = (b.B - a.B) * t + a.B;
        var A = (b.A - a.A) * t + a.A;
        return Color.fromFloats(R, G, B, A);
    }

}