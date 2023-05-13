/// contains types used by the engine
module ysge.types;

import std.math;
import std.format;

/// vec2 type with x and y values
struct Vec2(T) {
	T x, y;

	/// initialises with an x and y value
	this(T px, T py) {
		x = px;
		y = py;
	}

	/// calculates the angle from this vec2 to another vec2
	double AngleTo(Vec2!T to) {
		return atan2(cast(float) (to.y - y), cast(float) (to.x - x));
	}

	/// casts the vec2 to a vec2 with int values
	Vec2!int ToIntVec() {
		return Vec2!int(cast(int) x, cast(int) y);
	}

	/// casts the vec2 to a vec2 with float values
	Vec2!float ToFloatVec() {
		return Vec2!float(cast(float) x, cast(float) y);
	}

	/// returns the distance from this vec2 to another vec2
	T DistanceTo(Vec2!T other) {
		Vec2!T distance;
		distance.x = abs(other.x - x);
		distance.y = abs(other.y - y);
		return cast(T) sqrt(
			cast(float) ((distance.x * distance.x) + (distance.y * distance.y))
		);
	}

	/// casts the vec2 to the given type
	Vec2!T2 CastTo(T2)() {
		return Vec2!T2(
			cast(T2) x,
			cast(T2) y
		);
	}

	/// checks if 2 vec2s have equal values
	bool Equals(Vec2!T right) {
		return (
			(x == right.x) &&
			(y == right.y)
		);
	}

	/// converts the vec2 to a string
	string toString() {
		return format("(%s, %s)", x, y);
	}
}
