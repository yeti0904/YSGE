/// contains the simple box object class
module ysge.objects.simpleBox;

import ysge.project;

/// contains physics info
struct Physics {
	Vec2!int velocity;
	bool     drag;
	bool     gravityOn;
	Vec2!int gravity;
}

/// box object with AABB collision
class SimpleBox : GameObject {
	SDL_Rect   box;
	bool       physicsOn;
	Physics    physics;
	RenderInfo render;

	/// initialises with a box and a colour image
	this(SDL_Rect pbox, SDL_Color colour) {
		box          = pbox;
		render.type  = RenderType.Colour;
		render.value = RenderValue(colour);
	}

	/// initialises with a box and a texture
	this(SDL_Rect pbox, Texture texture) {
		box          = pbox;
		render.type  = RenderType.Texture;
		render.value = RenderValue(texture);
	}

	/// makes the object render as a coloured box
	void SetRenderColour(SDL_Color colour) {
		render.type  = RenderType.Colour;
		render.value = RenderValue(colour);
	}

	/// makes the object render as a texture
	void SetRenderTexture(Texture texture) {
		render.type  = RenderType.Texture;
		render.value = RenderValue(texture);
	}

	/// updates the object (physics etc)
	override void Update(Project parent) {
		if (physicsOn) {
			int old;

			old    = box.x;
			box.x += physics.velocity.x;
			foreach (ref object ; parent.currentScene.objects) {
				if (object is this) {
					continue;
				}
				
				if (object.CollidesWith(this)) {
					box.x              = old;
					physics.velocity.x = 0;
					break;
				}
			}

			old    = box.y;
			box.y += physics.velocity.y;
			foreach (ref object ; parent.currentScene.objects) {
				if (object is this) {
					continue;
				}
				
				if (object.CollidesWith(this)) {
					box.y              = old;
					physics.velocity.y = 0;
					break;
				}
			}

			if (physics.drag) {
				if (physics.velocity.x > 0) {
					-- physics.velocity.x;
				}
				if (physics.velocity.y > 0) {
					-- physics.velocity.y;
				}
				if (physics.velocity.x < 0) {
					++ physics.velocity.x;
				}
				if (physics.velocity.y < 0) {
					++ physics.velocity.y;
				}
			}

			if (physics.gravityOn) {
				physics.velocity.x += physics.gravity.x;
				physics.velocity.y += physics.gravity.y;
			}
		}
		return;
	}

	/**
	* move the box right while checking collision
	* returns whether it did move
	*/
	bool MoveRight(Scene scene, int pixels) {
		for (int i = 0; i < pixels; ++ i) {
			int old = box.x;
			++ box.x;

			foreach (ref object ; scene.objects) {
				if (object is this) {
					continue;
				}

				if (object.CollidesWith(this)) {
					box.x = old;
					return false;
				}
			}
		}

		return true;
	}

	/**
	* move the box left while checking collision
	* returns whether it did move
	*/
	bool MoveLeft(Scene scene, int pixels) {
		for (int i = 0; i < pixels; ++ i) {
			int old = box.x;
			+--box.x;

			foreach (ref object ; scene.objects) {
				if (object is this) {
					continue;
				}

				if (object.CollidesWith(this)) {
					box.x = old;
					return false;
				}
			}
		}

		return true;
	}

	/**
	* move the box up while checking collision
	* returns whether it did move
	*/
	bool MoveUp(Scene scene, int pixels) {
		for (int i = 0; i < pixels; ++ i) {
			int old = box.y;
			-- box.y;

			foreach (ref object ; scene.objects) {
				if (object is this) {
					continue;
				}

				if (object.CollidesWith(this)) {
					box.y = old;
					return false;
				}
			}
		}

		return true;
	}

	/**
	* move the box down while checking collision
	* returns whether it did move
	*/
	bool MoveDown(Scene scene, int pixels) {
		for (int i = 0; i < pixels; ++ i) {
			int old = box.y;
			++ box.y;

			foreach (ref object ; scene.objects) {
				if (object is this) {
					continue;
				}

				if (object.CollidesWith(this)) {
					box.y = old;
					return false;
				}
			}
		}

		return true;
	}
	
	/// uses AABB to check if it collides with another box
	override bool CollidesWith(SimpleBox other) {
		return (
			(box.x < other.box.x + other.box.w) &&
			(box.x + box.w > other.box.x) &&
			(box.y < other.box.y + other.box.h) &&
			(box.y + box.h > other.box.y)
		);
	}

	/**
	* renders the object
	* should not be called by user
	*/
	override void Render(Project parent) {
		SDL_Rect screenBox  = box;
		screenBox.x        -= parent.currentScene.camera.x;
		screenBox.y        -= parent.currentScene.camera.y;

		switch (render.type) {
			case RenderType.Colour: {
				SDL_SetRenderDrawColor(
					parent.renderer,
					render.value.colour.r,
					render.value.colour.g,
					render.value.colour.b,
					render.value.colour.a
				);
				SDL_RenderFillRect(parent.renderer, &screenBox);
				break;
			}
			case RenderType.Texture: {
				SDL_Rect* src;

				if (render.props.doCrop) {
					src  = new SDL_Rect();
					*src = render.props.crop;
				}
			
				SDL_RenderCopy(
					parent.renderer, render.value.texture.texture, src,
					&screenBox
				);
				break;
			}
			default: assert(0);
		}
	}
}
