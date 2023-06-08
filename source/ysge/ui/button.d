/// module containing the button UI element
module ysge.ui.button;

import std.string;
import ysge.project;

alias ButtonOnClick = void delegate(Project, Button);

/// button UI element
class Button : UIElement {
	private string       label; /// the text that displays on the button
	private SDL_Texture* labelTexture;
	ButtonOnClick        onClick; /// called when the button is clicked
	SDL_Rect             rect; /// the rectangle the button will be rendered in
	SDL_Color            fill; /// the background colour of the button
	SDL_Color            outline; /// the colour of the button outline
	SDL_Color            outlineHover; /// the colour of the button outline when the cursor is hovering on it
	SDL_Color            fillHover; /// the colour of the button fill when the cursor is hovering on it
	SDL_Color            labelColour; /// the colour of the label text

	/// sets the button's label
	void SetLabel(string newLabel) {
		if (newLabel != label) {
			labelTexture = null;
		}

		label = newLabel;
	}

	/// copies this UI element to a new class instance
	Button CreateCopy() {
		Button ret = new Button();
		
		ret.SetLabel(label);
		ret.onClick      = onClick;
		ret.rect         = rect;
		ret.fill         = fill;
		ret.outline      = outline;
		ret.outlineHover = outlineHover;
		ret.labelColour  = labelColour;

		return ret;
	}

	/// checks if a position is inside the button
	bool OnButton(Vec2!int pos) {
		return (
			(pos.x > rect.x) &&
			(pos.y > rect.y) &&
			(pos.x < rect.x + rect.w) &&
			(pos.y < rect.y + rect.h)
		);
	}

	override bool HandleEvent(Project project, SDL_Event e) {
		switch (e.type) {
			case SDL_MOUSEBUTTONDOWN: {
				if (e.button.button != SDL_BUTTON_LEFT) {
					return false;
				}

				auto mouse = project.mousePos;

				if (OnButton(mouse)) {
					onClick(project, this);
				}
				else {
					return false;
				}
				break;
			}
			default: return false;
		}

		return false;
	}

	override void Render(Project project) {
		auto fillColour    = OnButton(project.mousePos)? fillHover : fill;
		auto outlineColour = OnButton(project.mousePos)? outlineHover : outline;
	
		SDL_SetRenderDrawColor(
			project.renderer, fillColour.r, fillColour.g, fillColour.b,
			fillColour.a
		);
		SDL_RenderFillRect(project.renderer, &rect);
		SDL_SetRenderDrawColor(
			project.renderer, outlineColour.r, outlineColour.g, outlineColour.b,
			outlineColour.a
		);
		SDL_RenderDrawRect(project.renderer, &rect);

		if (label.strip() == "") {
			return;
		}

		if (labelTexture is null) {
			SDL_Surface* labelSurface = TTF_RenderText_Solid(
				project.font, toStringz(label), labelColour
			);

			if (labelSurface is null) {
				throw new ProjectException("Failed to render text");
			}

			labelTexture = SDL_CreateTextureFromSurface(
				project.renderer, labelSurface
			);

			if (labelTexture is null) {
				throw new ProjectException("Failed to create text texture");
			}
		}

		SDL_Rect textBox;
		SDL_QueryTexture(labelTexture, null, null, &textBox.w, &textBox.h);
		textBox.x  = rect.x;
		textBox.y  = rect.y;
		textBox.x += (rect.w / 2) - (textBox.w / 2);
		textBox.y += (rect.h / 2) - (textBox.h / 2);

		SDL_RenderCopy(project.renderer, labelTexture, null, &textBox);
	}
}
