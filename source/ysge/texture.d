/// module containing the Texture class
module ysge.texture;

import ysge.project;

/// Texture class that automatically frees itself
class Texture {
	SDL_Texture* texture;

	this(SDL_Texture* ptexture) {
		texture = ptexture;
	}

	this() {
		texture = null;
	}

	~this() {
		if (texture) {
			SDL_DestroyTexture(texture);
		}
	}
}
