package kext.math;

import kha.math.Vector2;

import kext.g2basics.BasicSprite;

class BoundingRect {

	public var position:Vector2;
	public var offset:Vector2;
	public var size:Vector2;
	public var scale:Vector2;

	public inline function new(boxPosition:Vector2, boxSize:Vector2, boxOffset:Vector2 = null, boxScale:Vector2 = null) {
		position = boxPosition;
		size = boxSize;
		offset = boxOffset == null ? new Vector2(0, 0) : boxOffset;
		scale = boxScale == null ? new Vector2(1, 1) : boxScale;
	}
	
	public inline function setScaleFromCenter(vector:Vector2) {
	public inline function setScaleFromCenter(vector:Vector2 = null, offsetAdd:Vector2 = null) {
		size = new Vector2(size.x * vector.x, size.y * vector.y);
		if(offsetAdd != null) {
			offset = new Vector2(size.x * vector.x * 0.5 + offsetAdd.x, size.y * vector.y * 0.5 + offsetAdd.y);
		} else {
			offset = new Vector2(size.x * vector.x * 0.5, size.y * vector.y * 0.5);
		}
	}

	public inline function setOffset(vector:Vector2) {
		offset = vector;
	}

	public function checkVectorOverlap(vector:Vector2) {
		var tv1:Vector2 = position.sub(offset);
		var tv2:Vector2 = position.sub(offset);
		tv2.x += size.x * scale.x;
		tv2.y += size.y * scale.y;
		if(vector.x < tv1.x || vector.x > tv2.x) { return false; }
		if(vector.y < tv1.y || vector.y > tv2.y) { return false; }
		
		return true;
	}

	public function checkRectOverlap(rect:BoundingRect) {
		var tv1:Vector2 = position.sub(offset);
		var tv2:Vector2 = position.sub(offset);
		tv2.x += size.x * scale.x;
		tv2.y += size.y * scale.y;
		var recttv1:Vector2 = rect.position.sub(rect.offset);
		var recttv2:Vector2 = rect.position.sub(rect.offset);
		recttv2.x += rect.size.x * rect.scale.x;
		recttv2.y += rect.size.y * rect.scale.y;
		if(tv1.x > recttv2.x) return false;
		if(tv1.y > recttv2.y) return false;
		if(tv2.x < recttv1.x) return false;
		if(tv2.y < recttv1.y) return false;

		return true;
	}

	public static function fromSprite(sprite:BasicSprite):BoundingRect {
		var bounds = new BoundingRect(sprite.position, sprite.box, sprite.origin, sprite.scale);
		return bounds;
	}

}