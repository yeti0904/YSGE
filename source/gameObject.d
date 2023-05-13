module ysge.gameObject;

import std.stdio;
import ysge.project;

enum RenderType {
	Colour,
	Texture
}

union RenderValue {
	SDL_Color    colour;
	SDL_Texture* texture;

	this(SDL_Color pcolour) {
		colour = pcolour;
	}

	this(SDL_Texture* ptexture) {
		texture = ptexture;
	}
}

struct Physics {
	Vec2!int velocity;
	bool     drag;
	bool     gravityOn;
	Vec2!int gravity;
}

class GameObject {
	SDL_Rect    box;
	bool        physicsOn;
	Physics     physics;
	RenderType  renderType;
	RenderValue render;

	/// initialises with a box and a colour image
	this(SDL_Rect pbox, SDL_Color colour) {
		box        = pbox;
		renderType = RenderType.Colour;
		render     = RenderValue(colour);
	}

	/// initialises with a box and a texture
	this(SDL_Rect pbox, SDL_Texture* texture) {
		box        = pbox;
		renderType = RenderType.Texture;
		render     = RenderValue(texture);
	}

	/// makes the object render as a coloured box
	void SetRenderColour(SDL_Color colour) {
		renderType = RenderType.Colour;
		render     = RenderValue(colour);
	}

	/// makes the object render as a texture
	void SetRenderTexture(SDL_Texture* texture) {
		renderType = RenderType.Texture;
		render     = RenderValue(texture);
	}

	/// checks if it collides with another object
	/// returns false for GameObject
	bool CollidesWith(GameObject other) {
		return false;
	}

	/// updates the object (physics etc)
	void Update(Project parent) {
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

	/// move the box right while checking collision
	/// returns whether it did move
	bool MoveRight(Scene scene, int pixels) {
		int old  = box.x;
		box.x   += pixels;

		foreach (ref object ; scene.objects) {
			if (object is this) {
				continue;
			}

			if (object.CollidesWith(this)) {
				box.x = old;
				return false;
			}
		}

		return true;
	}

	/// move the box left while checking collision
	bool MoveLeft(Scene scene, int pixels) {
		int old  = box.x;
		box.x   -= pixels;

		foreach (ref object ; scene.objects) {
			if (object is this) {
				continue;
			}

			if (object.CollidesWith(this)) {
				box.x = old;
				return false;
			}
		}

		return true;
	}

	/// move the box up while checking collision
	bool MoveUp(Scene scene, int pixels) {
		int old  = box.y;
		box.y   -= pixels;

		foreach (ref object ; scene.objects) {
			if (object is this) {
				continue;
			}

			if (object.CollidesWith(this)) {
				box.y = old;
				return false;
			}
		}

		return true;
	}

	/// move the box down while checking collision
	bool MoveDown(Scene scene, int pixels) {
		int old  = box.y;
		box.y   += pixels;

		foreach (ref object ; scene.objects) {
			if (object is this) {
				continue;
			}

			if (object.CollidesWith(this)) {
				box.y = old;
				return false;
			}
		}

		return true;
	}
	
	/// renders the object
	/// should not be called by user
	void Render(Project parent) {
		SDL_Rect screenBox  = box;
		screenBox.x        -= parent.currentScene.camera.x;
		screenBox.y        -= parent.currentScene.camera.y;

		switch (renderType) {
			case RenderType.Colour: {
				SDL_SetRenderDrawColor(
					parent.renderer,
					render.colour.r,
					render.colour.g,
					render.colour.b,
					render.colour.a
				);
				SDL_RenderFillRect(parent.renderer, &screenBox);
				break;
			}
			case RenderType.Texture: {
				SDL_RenderCopy(
					parent.renderer, render.texture, null, &screenBox
				);
				break;
			}
			default: assert(0);
		}
	}
}
