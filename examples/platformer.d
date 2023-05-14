import std.math;
import std.stdio;
import ysge.project;

SimpleBox player;
Text      title;

class GameScene : Scene {
	override void Init(Project parent) {
		AddObject( // player
			new SimpleBox(
				SDL_Rect(10, 10, 50, 50), SDL_Color(255, 255, 255)
			)
		);
		player = cast(SimpleBox) objects[$ - 1];

		player.physicsOn         = true;
		player.physics.gravityOn = true;
		player.physics.gravity   = Vec2!int(0, 1);

		CameraFollowObject(player);
		
		AddObject(
			new SimpleBox(
				SDL_Rect(0, 400, 300, 20), SDL_Color(0, 255, 0)
			)
		);
		AddObject(
			new SimpleBox(
				SDL_Rect(350, 350, 300, 20), SDL_Color(0, 255, 0)
			)
		);

		// make ui
		Button respawn = new Button();

		void RespawnOnClick(Project project, Button button) {
			player.box = SDL_Rect(10, 10, 50, 50);
		}

		respawn.SetLabel("Respawn");
		respawn.labelColour = SDL_Color(0, 0, 0, 255);
		respawn.rect        = SDL_Rect(0, 0, 100, 50);
		respawn.outline     = SDL_Color(255, 255, 255, 255);
		respawn.fill        = SDL_Color(0, 255, 0, 255);
		respawn.onClick     = &RespawnOnClick;
		AddUI(respawn);

		title = new Text();
		title.SetText("Example platformer game");
		title.pos    = Vec2!int(120, 50);
		title.colour = SDL_Color(255, 255, 255, 255);
		AddUI(title);
	}
	
	override void Update(Project parent) {
		title.pos.y += cast(int) (sin(cast(float) parent.frames / 5) * 10);

		if (parent.KeyPressed(SDL_SCANCODE_A)) {
			player.MoveLeft(this, 5);
		}
		if (parent.KeyPressed(SDL_SCANCODE_D)) {
			player.MoveRight(this, 5);
		}

		if (
			parent.KeyPressed(SDL_SCANCODE_SPACE) &&
			!player.MoveDown(this, 1)
		) {
			player.physics.velocity.y = -15;
		}
	}

	override void HandleEvent(Project parent, SDL_Event e) {
		
	}
}

enum Scenes {
	GameScene = 0
}

class Game : Project {
	override void Init() {
		InitWindow("Game", 640, 480);
		SetResolution(640, 480);

		InitText();
		LoadFontFile("font.ttf", 16);

		AddScene(new GameScene());

		SetScene(Scenes.GameScene);
	}
}

void main() {
	auto game = new Game();

	game.Run();
}
