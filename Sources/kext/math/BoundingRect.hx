package kext.math;

import kha.math.Vector2;

import kext.g2basics.Transform2D;
import kext.g2basics.BasicSprite;

class BoundingRect {

	public var transform:Transform2D;
	public var size:Vector2;
	public var offset:Vector2;

	public inline function new(transform:Transform2D, size:Vector2 = null) {
		this.transform = transform;
		this.size = size;
		offset = null;
	}

	public function checkVectorOverlap(vector:Vector2) {
		var offset:Vector2 = this.offset != null ? this.offset : transform.origin;
		var tv1:Vector2 = transform.position.sub(offset);
		var tv2:Vector2 = transform.position.sub(offset);
		tv2.x += size.x * transform.scaleX;
		tv2.y += size.y * transform.scaleY;
		if(vector.x < tv1.x || vector.x > tv2.x) { return false; }
		if(vector.y < tv1.y || vector.y > tv2.y) { return false; }
		
		return true;
	}

	public function checkRectOverlap(rect:BoundingRect) {
		var offset:Vector2 = this.offset != null ? this.offset : transform.origin;
		var tv1:Vector2 = transform.position.sub(offset);
		var tv2:Vector2 = transform.position.sub(offset);
		tv2.x += size.x * transform.scaleX;
		tv2.y += size.y * transform.scaleY;
		offset = rect.offset != null ? rect.offset : rect.transform.origin;
		var recttv1:Vector2 = rect.transform.position.sub(offset);
		var recttv2:Vector2 = rect.transform.position.sub(offset);
		recttv2.x += rect.size.x * rect.transform.scaleX;
		recttv2.y += rect.size.y * rect.transform.scaleY;
		if(tv1.x > recttv2.x) return false;
		if(tv1.y > recttv2.y) return false;
		if(tv2.x < recttv1.x) return false;
		if(tv2.y < recttv1.y) return false;

		return true;
	}

	public static function fromSprite(sprite:BasicSprite):BoundingRect {
		var bounds = new BoundingRect(sprite.transform, sprite.box);
		return bounds;
	}

	public static function fromVectors(position:Vector2, scale:Vector2, size:Vector2, origin:Vector2):BoundingRect {
		var bounds = new BoundingRect(new Transform2D(position, scale, 0, origin), size);
		return bounds;
	}

}