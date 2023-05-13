/// contains the simple box object class
module ysge.objects.simpleBox;

import ysge.project;

/// box object with AABB collision
class SimpleBox : GameObject {
	this(SDL_Rect box, SDL_Color colour) {
		super(box, colour);
	}

	this(SDL_Rect box, SDL_Texture* texture) {
		super(box, texture);
	}

	/// uses AABB to check if it collides with another box
	override bool CollidesWith(GameObject other) {
		return (
			(box.x < other.box.x + other.box.w) &&
			(box.x + box.w > other.box.x) &&
			(box.y < other.box.y + other.box.h) &&
			(box.y + box.h > other.box.y)
		);
	}
}
