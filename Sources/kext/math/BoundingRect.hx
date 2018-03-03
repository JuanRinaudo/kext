package kext.math;

import kha.math.Vector2;

import kext.g2basics.BasicSprite;

class BoundingRect {

	public var position:Vector2;
	public var offset:Vector2;
	public var size:Vector2;
	private var originalSize:Vector2;

	public inline function new(boxPosition:Vector2, boxSize:Vector2, boxOffset:Vector2 = null) {
		position = boxPosition;
		size = boxSize;
		originalSize = boxSize.mult(1);
		offset = boxOffset == null ? new Vector2(0, 0) : boxOffset;
	}

	public inline function setSize(vector:Vector2) {
		size = new Vector2(vector.x, vector.y);
	}

	public inline function setScale(vector:Vector2) {
		size = new Vector2(originalSize.x * vector.x, originalSize.y * vector.y);
	}

	public inline function setOffset(vector:Vector2) {
		offset = vector;
	}

	public inline function checkVectorOverlap(vector:Vector2) {
		var tv1:Vector2 = position.sub(offset);
		var tv2:Vector2 = position.sub(offset).add(size);
		if(vector.x < tv1.x || vector.x > tv2.x) { return false; }
		if(vector.y < tv1.y || vector.y > tv2.y) { return false; }
		
		return true;
	}

	public function checkRectOverlap(rect:BoundingRect) {
		var tv1:Vector2 = position.sub(offset);
		var tv2:Vector2 = position.sub(offset).add(size);
		var recttv1:Vector2 = rect.position.sub(rect.offset);
		var recttv2:Vector2 = rect.position.sub(rect.offset).add(rect.size);
		if(tv1.x > recttv2.x) return false;
		if(tv1.y > recttv2.y) return false;
		if(tv2.x < recttv1.x) return false;
		if(tv2.y < recttv1.y) return false;

		return true;
	}

	public static function fromSprite(sprite:BasicSprite, scale:Vector2 = null, offset:Vector2 = null):BoundingRect {
		var bounds = new BoundingRect(sprite.position, sprite.box, offset == null ? sprite.origin : offset);
		bounds.setScale(scale == null ? new Vector2(Math.abs(sprite.scale.x), Math.abs(sprite.scale.y)) : scale);

		return bounds;
	}

}