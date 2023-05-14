/// contains the Scene class
module ysge.scene;

import ysge.project;

/// individual scene containing objects
class Scene {
	GameObject[] objects;
	UIElement[]  ui;
	SDL_Color    bg;
	Vec2!int     camera;
	bool         cameraFollowsObject;
	GameObject   cameraFollow;

	/// called when this scene is set as the project's current scene
	abstract void Init(Project parent);
	/// run every frame
	abstract void Update(Project parent);
	/// run when an event is created
	abstract void HandleEvent(Project parent, SDL_Event e);

	/// makes the camera follow an object
	void CameraFollowObject(GameObject obj) {
		cameraFollowsObject = true;
		cameraFollow        = obj;
	}

	/// makes the camera follow an object by index
	void CameraFollowObject(size_t index) {
		cameraFollowsObject = true;
		cameraFollow        = objects[index];
	}

	/// stops the camera from following an object
	void StopFollowingObject() {
		cameraFollowsObject = false;
		cameraFollow        = null;
	}

	/// adds a game object to the scene's object array
	void AddObject(GameObject object) {
		objects ~= object;
	}

	/// adds a UI element to the scene
	void AddUI(UIElement element) {
		ui ~= element;
	}

	/**
	* makes the camera follow an object if enabled
	* should not be called by the user
	*/
	void UpdateCamera(Project parent) {
		if (cameraFollowsObject) {
			auto     screenRes = parent.GetResolution();
			Vec2!int pos       = Vec2!int(cameraFollow.box.x, cameraFollow.box.y);
			Vec2!int size      = Vec2!int(cameraFollow.box.x, cameraFollow.box.y);

			camera.x = pos.x - (screenRes.x / 2);
			camera.y = pos.y - (screenRes.y / 2);
		}
	}

	/**
	* calls the update function of all objects in the scene
	* should not be called by the user
	*/
	void UpdateObjects(Project parent) {
		foreach (ref object ; objects) {
			object.Update(parent);
		}
	}

	/**
	* sends event to UI elements
	* should not be called by the user
	*/
	bool HandleUIEvent(Project parent, SDL_Event e) {
		foreach (ref element ; ui) {
			if (element.HandleEvent(parent, e)) {
				return true;
			}
		}
		return false;
	}

	/// render the scene, should not be called by the user
	void Render(Project parent) {
		SDL_SetRenderDrawColor(parent.renderer, bg.r, bg.g, bg.b, bg.a);
		SDL_RenderClear(parent.renderer);

		foreach (ref object ; objects) {
			object.Render(parent);
		}
		
		foreach (ref element ; ui) {
			element.Render(parent);
		}

		SDL_RenderPresent(parent.renderer);
	}
}
