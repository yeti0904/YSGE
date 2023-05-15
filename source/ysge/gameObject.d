/// contains the base class for game objects
module ysge.gameObject;

import std.stdio;
import ysge.project;

/// whether the object will render with a colour or a texture
enum RenderType {
	Colour,
	Texture
}

/// a texture or a colour that will be used for rendering this object
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

/// base class for objects in a scene
class GameObject {
	abstract void Update(Project parent);
	abstract bool CollidesWith(SimpleBox other);
	abstract void Render(Project parent);
}
