/// YSGE utility library
module ysge.util;

import bindbc.sdl;

/// creates a colour structure from a hex value
SDL_Color HexToColour(int hexValue) {
	return SDL_Color(
		(hexValue >> 16) & 0xFF,
		(hexValue >> 8) & 0xFF,
		hexValue & 0xFF,
		255
	);
}
