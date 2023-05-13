/// main YSGE module containing everything you need to make a game
module ysge.project;

import std.file;
import std.path;
import std.string;

public import bindbc.sdl;
public import ysge.scene;
public import ysge.types;
public import ysge.gameObject;
public import ysge.objects.simpleBox;

/// used when something goes wrong in the project
class ProjectException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

/// main project class used for the game as a whole
class Project {
	bool          running; /// while true, update functions are called
	SDL_Window*   window;
	SDL_Renderer* renderer;
	Scene[]       scenes;
	Scene         currentScene;
	bool          usingLogicalRes; /// DON'T MODIFY!!!!
	Vec2!int      logicalRes; /// DON'T MODIFY!!!!

	/// called once at the start
	abstract void Init();

	/// creates the window
	void InitWindow(string name, int w, int h) {
		SDLSupport support;

		version (Windows) {
			support = loadSDL(cast(char*) (dirName(thisExePath()) ~ "/sdl2.dll"));
		}
		else {
			support = loadSDL();
		}
		
		if (support != sdlSupport) {
			throw new ProjectException("Failed to load SDL");
		}
	
		window = SDL_CreateWindow(
			toStringz(name), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
			w, h, SDL_WINDOW_RESIZABLE
		);

		if (window is null) {
			throw new ProjectException("Failed to create window");
		}

		renderer = SDL_CreateRenderer(
			window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC
		);

		if (renderer is null) {
			throw new ProjectException("Failed to create renderer");
		}
	}

	/// gets the resolution of the window
	Vec2!int GetResolution() {
		if (usingLogicalRes) {
			return logicalRes;
		}
		else {
			Vec2!int ret;

			SDL_GetWindowSize(window, &ret.x, &ret.y);

			return ret;
		}
	}

	/// sets the logical resolution of the window
	void SetResolution(uint w, uint h) {
		SDL_RenderSetLogicalSize(renderer, w, h);
		usingLogicalRes = true;
		logicalRes      = Vec2!int(w, h);
	}

	/// gets the directory the game executable is in
	string GetGameDirectory() {
		return dirName(thisExePath());
	}

	/// checks if a key is pressed
	bool KeyPressed(SDL_Scancode key) {
		auto keys = SDL_GetKeyboardState(null);

		return keys[key]? true : false;
	}

	/// adds a scene to the project scene array
	void AddScene(Scene scene) {
		scenes ~= scene;
	}

	/// sets the current scene to a scene from the project scene array
	void SetScene(size_t index) {
		currentScene = scenes[index];
		currentScene.Init(this);
	}

	/// runs the game
	void Run() {
		running = true;
		Init();

		if (currentScene is null) {
			throw new ProjectException("Scene not set");
		}

		while (running) {
			currentScene.UpdateObjects(this);
			currentScene.Update(this);
			currentScene.UpdateCamera(this);
			currentScene.Render(this);

			SDL_Event e;
			while (SDL_PollEvent(&e)) {
				if (e.type == SDL_QUIT) {
					running = false;
					return;
				}
			
				currentScene.HandleEvent(this, e);
			}
		}
	}
}
