/// module containing the text UI element
module ysge.ui.text;

import std.string;
import ysge.project;

class Text : UIElement {
	private string       text;
	private SDL_Texture* texture;
	SDL_Color            colour;
	Vec2!int             pos;
	float                scale = 1.0;

	/// copies this UI element to a new class instance
	Text CreateCopy() {
		auto ret = new Text();

		ret.SetText(text);
		ret.colour = colour;
		ret.pos    = pos;
		ret.scale  = scale;

		return ret;
	}

	/// sets the text that is rendered
	void SetText(string newText) {
		if (text != newText) {
			texture = null;
		}

		text = newText;
	}

	/// returns the size in pixels of the text
	Vec2!int GetTextSize(Project project) {
		Vec2!int ret;
		
		CreateTexture(project);
		SDL_QueryTexture(texture, null, null, &ret.x, &ret.y);
		ret = Vec2!int(
			cast(int) (ret.CastTo!float().x * scale),
			cast(int) (ret.CastTo!float().x * scale)
		);
		return ret;
	}

	private void CreateTexture(Project project) {
		if (texture is null) {
			SDL_Surface* surface = TTF_RenderText_Solid(
				project.font, toStringz(text), colour
			);

			if (surface is null) {
				throw new ProjectException("Failed to render text");
			}

			texture = SDL_CreateTextureFromSurface(project.renderer, surface);

			if (texture is null) {
				throw new ProjectException("Failed to create text texture");
			}
		}
	}

	override bool HandleEvent(Project project, SDL_Event e) {
		return false;
	}

	override void Render(Project project) {
		CreateTexture(project);
	
		SDL_Rect textBox;
		textBox.x = pos.x;
		textBox.y = pos.y;

		SDL_QueryTexture(texture, null, null, &textBox.w, &textBox.h);

		textBox.w = cast(int) ((cast(float) textBox.w) * scale);
		textBox.h = cast(int) ((cast(float) textBox.h) * scale);

		SDL_RenderCopy(project.renderer, texture, null, &textBox);
	}
}
