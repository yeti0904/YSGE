/// contains the base UI element class
module ysge.uiBase;

import ysge.project;

class UIElement {
	/// handles an event
	/// returns true if an event was processed
	/// if false, pass the event to another function
	/// should not be called by the user
	/// doesn't do anything in the base class
	bool HandleEvent(Project project, SDL_Event e) {
		return false;
	}

	/// renders the UI element
	/// should not be called by the user
	/// doesn't do anything in the base class
	void Render(Project project) {
		
	}
}
