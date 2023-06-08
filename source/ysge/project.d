/// main YSGE module containing everything you need to make a game
module ysge.project;

import std.file;
import std.path;
import std.string;

public import bindbc.sdl;
public import ysge.util;
public import ysge.scene;
public import ysge.types;
public import ysge.gameObject;
public import ysge.objects.simpleBox;
public import ysge.uiBase;

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
	TTF_Font*     font;
	Scene[]       scenes;
	Scene         currentScene;
	bool          usingLogicalRes; /// DON'T MODIFY!!!!
	Vec2!int      logicalRes; /// DON'T MODIFY!!!!
	Vec2!int      mousePos;
	ulong         frames; /// how many frames have passed since the game was started

	/// called once at the start
	abstract void Init();

	/// creates the window
	void InitWindow(string name, int w, int h, bool resizable) {
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

		int flags = 0;

		if (resizable) {
			flags |= SDL_WINDOW_RESIZABLE;
		}
	
		window = SDL_CreateWindow(
			toStringz(name), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
			w, h, flags
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

	/// initialises the text library
	void InitLibs() {
		// SDL_TTF
		SDLTTFSupport supportTTF;
	
		version (Windows) {
			supportTTF = loadSDLTTF(
				cast(char*) (dirName(thisExePath()) ~ "/sdl2_ttf.dll")
			);
		}
		else {
			supportTTF = loadSDLTTF();
		}
	
		if (supportTTF < SDLTTFSupport.v2_0_12) {
			throw new ProjectException("Failed to load SDL_TTF library");
		}

		if (TTF_Init() < 0) {
			throw new ProjectException("Failed to initialise SDL_TTF");
		}

		// SDL_Image
		auto supportIMG = loadSDLImage();

		if (supportIMG < SDLImageSupport.v2_0_0) {
			throw new ProjectException("Failed to load SDL_Image library");
		}

		int imgFlags = IMG_INIT_PNG;
		if (IMG_Init(imgFlags) != imgFlags) {
			throw new ProjectException("Failed to initialise SDL_Image");
		}
	}

	void LoadFontFile(string path, int pointSize) {
		font = TTF_OpenFont(toStringz(path), pointSize);

		if (font is null) {
			throw new ProjectException("Failed to load font");
		}
	}

	void LoadFontData(ubyte[] data) {
		auto rw = SDL_RWFromMem(data.ptr, cast(int) data.length);
		font = TTF_OpenFontRW(rw, 1, 16);

		if (font is null) {
			throw new ProjectException("Failed to load font");
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

	/// sets window size
	void SetWindowSize(uint w, uint h) {
		SDL_SetWindowSize(window, cast(int) w, cast(int) h);
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
	void SetScene(Scene scene) {
		currentScene = scene;
		currentScene.Setup();
		currentScene.Init(this);
	}

	/// sets the current scene to a scene from the project scene array
	void SetScene(size_t index) {
		currentScene = scenes[index];
		currentScene.Setup();
		currentScene.Init(this);
	}

	/// loads a texture from a file
	SDL_Texture* LoadTextureFromFile(string fileName) {
		auto surface = IMG_Load(cast(char*) fileName.toStringz());

		if (surface is null) {
			throw new ProjectException("Failed to load texture");
		}

		auto texture = SDL_CreateTextureFromSurface(renderer, surface);

		if (texture is null) {
			throw new ProjectException("Failed to load texture");
		}

		return texture;
	}

	/// loads a texture from raw file data
	SDL_Texture* LoadTextureFromData(ref ubyte[] data) {
		auto rw      = SDL_RWFromMem(data.ptr, cast(int) data.length);
		auto surface = IMG_Load_RW(rw, 1);
		
		if (surface is null) {
			throw new ProjectException("Failed to load texture");
		}

		auto texture = SDL_CreateTextureFromSurface(renderer, surface);

		if (texture is null) {
			throw new ProjectException("Failed to load texture");
		}

		return texture;
	}

	/// runs the game
	void Run() {
		running = true;
		Init();

		if (currentScene is null) {
			throw new ProjectException("Scene not set");
		}

		if (font is null) {
			throw new ProjectException("Font not loaded");
		}

		while (running) {
			++ frames;
		
			currentScene.UpdateObjects(this);
			currentScene.Update(this);
			currentScene.UpdateCamera(this);
			currentScene.Render(this);

			SDL_Event e;
			while (SDL_PollEvent(&e)) {
				switch (e.type) {
					case SDL_QUIT: {
						running = false;
						return;
					}
					case SDL_MOUSEMOTION: {
						mousePos = Vec2!int(e.motion.x, e.motion.y);
						break;
					}
					default: {
						if (currentScene.HandleUIEvent(this, e)) {
							continue;
						}
					
						currentScene.HandleEvent(this, e);
						break;
					}
				}
			}
		}
	}
}
