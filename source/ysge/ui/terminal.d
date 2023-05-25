/// contains the terminal object class
module ysge.ui.terminal;

import std.stdio;
import std.string;
import std.process;
import std.algorithm;
import core.stdc.stdlib;
import bindbc.sdl;
import ysge.project;

/// colours for the default pallette
enum Colour {
	Black        = 0,
	Red          = 1,
	Green        = 2,
	Yellow       = 3,
	Blue         = 4,
	Purple       = 5,
	Cyan         = 6,
	White        = 7,
	Grey         = 8,
	BrightRed    = 9,
	BrightGreen  = 10,
	BrightYellow = 11,
	BrightBlue   = 12,
	BrightPurple = 13,
	BrightCyan   = 14,
	BrightWhite  = 15
}

/// attributes for each character in the text buffer
struct Attributes {
	ubyte fg = 7; /// foreground colour
	ubyte bg = 0; /// background colour
}

/// cell structure (1 text buffer character)
struct Cell {
	char       ch = ' ';
	Attributes attr;

	/// creates a cell from a character with default attributes
	static Cell FromChar(char ch) {
		Cell       ret;
		Attributes attr;
		
		ret.attr = attr;
		ret.ch   = ch;

		return ret;
	}
}

/// text screen object class
class Terminal : UIElement {
	Vec2!int          pos;
	Cell[][]          cells;
	Vec2!int          cellSize;
	SDL_Color[]       palette;
	SDL_Texture*[256] characters;

	/// initialises text screen with the default palette 
	/// and also creates the characters
	this(Project parent) {
		// default pallette
		palette = [
			// https://gogh-co.github.io/Gogh/
			// Pro colour scheme
			
			/* 0 */ HexToColour(0x000000),
			/* 1 */ HexToColour(0x990000),
			/* 2 */ HexToColour(0x00A600),
			/* 3 */ HexToColour(0x999900),
			/* 4 */ HexToColour(0x2009DB),
			/* 5 */ HexToColour(0xB200B2),
			/* 6 */ HexToColour(0x00A6B2),
			/* 7 */ HexToColour(0xBFBFBF),
			/* 8 */ HexToColour(0x666666),
			/* 9 */ HexToColour(0xE50000),
			/* A */ HexToColour(0x00D900),
			/* B */ HexToColour(0xE5E500),
			/* C */ HexToColour(0x0000FF),
			/* D */ HexToColour(0xE500E5),
			/* E */ HexToColour(0x00E5E5),
			/* F */ HexToColour(0xE5E5E5)
		];

		foreach (i, ref texture ; characters) {
			size_t[] dontRender = [0, 173];
			if (dontRender.canFind(i)) {
				texture = null;
				continue;
			}
		
			auto colour = SDL_Colour(255, 255, 255, 255);

			string str;
			str ~= cast(char) i;
		
			SDL_Surface* textSurface = TTF_RenderText_Solid(
				parent.font, toStringz(str), colour
			);
			
			if (textSurface is null) {
				stderr.writefln(
					"Failed to render text: %s", fromStringz(TTF_GetError())
				);
				exit(1);
			}
			
			texture = SDL_CreateTextureFromSurface(parent.renderer, textSurface);
			if (texture is null) {
				stderr.writefln(
					"Failed to create texture: %s", fromStringz(TTF_GetError())
				);
				exit(1);
			}
		}
	}

	/// returns the size of the text buffer
	Vec2!size_t GetSize() {
		return Vec2!size_t(cells[0].length, cells.length);
	}

	/// sets the size of the text buffer
	void SetSize(Vec2!size_t size) {
		auto newCells = new Cell[][](size.y, size.x);

		foreach (i, ref line ; cells) {
			foreach (j, ref cell ; line) {
				newCells[i][j] = cell;
			}
		}

		cells = newCells;
	}

	/// sets a character in the text buffer
	void SetCharacter(
		Vec2!size_t pos, char ch, ubyte fg = Colour.White, ubyte bg = Colour.Black
	) {
		try {	
			cells[pos.y][pos.x] = Cell(ch, Attributes(fg, bg));
		}
		catch (Throwable) {
			return;
		}
	}

	/// adds characters starting from pos in the text buffer
	void WriteString(
		Vec2!size_t pos, string str, ubyte fg = Colour.White, ubyte bg = Colour.Black
	) {
		foreach (i, ref ch ; str) {
			SetCharacter(Vec2!size_t(pos.x + i, pos.y), ch, fg, bg);
		}
	}

	/// writes a string centered horizontally
	void WriteStringCentered(
		size_t yPos, string str, ubyte fg = Colour.White, ubyte bg = Colour.Black
	) {
		Vec2!size_t pos;
		pos.y = yPos;
		pos.x = (GetSize().x / 2) - (str.length / 2);

		WriteString(pos, str, fg, bg);
	}

	/// writes multiple lines in the text buffer
	void WriteStringLines(
		Vec2!size_t pos, string[] strings,
		ubyte fg = Colour.White, ubyte bg = Colour.Black
	) {
		Vec2!size_t ipos = pos;

		for (size_t i = 0; i < strings.length; ++ i, ++ ipos.y) {
			WriteString(ipos, strings[i], fg, bg);
		}
	}

	/// writes multiple horizontally centered lines
	void WriteStringLinesCentered(
		size_t yPos, string[] strings, ubyte fg = Colour.White,
		ubyte bg = Colour.Black,
	) {
		size_t iy = yPos;

		for (size_t i = 0; i < strings.length; ++ i, ++ iy) {
			WriteStringCentered(iy, strings[i], fg, bg);
		}
	}

	/// draws a horizontal line in the text buffer
	void HorizontalLine(
		Vec2!size_t start, size_t length, char ch,
		ubyte fg = Colour.White, ubyte bg = Colour.Black
	) {
		for (size_t x = start.x; x < start.x + length; ++ x) {
			SetCharacter(Vec2!size_t(x, start.y), ch, fg, bg);
		}
	}

	/// draws a vertical line in the text buffer
	void VerticalLine(
		Vec2!size_t start, size_t length, char ch,
		ubyte fg = Colour.White, ubyte bg = Colour.Black
	) {
		for (size_t y = start.y; y < start.y + length; ++ y) {
			SetCharacter(Vec2!size_t(start.x, y), ch, fg, bg);
		}
	}

	/// sets a cell in the text buffer to the given cell
	void SetCell(Vec2!size_t pos, Cell cell) {
		try {
			cells[pos.y][pos.x] = cell;
		}
		catch (Throwable) {
			
		}
	}

	/// fills the text buffer with the given character
	void Clear(char ch, ubyte fg = Colour.White, ubyte bg = Colour.Black) {
		foreach (y, ref line ; cells) {
			foreach (x, ref cell ; line) {
				cell.ch      = ch;
				cell.attr.fg = fg;
				cell.attr.bg = bg;
			}
		}
	}

	/// fills a rectangle
	void FillRect(
		SDL_Rect rect, char ch, ubyte fg = Colour.White, ubyte bg = Colour.Black
	) {
		for (size_t i = rect.y; i < rect.y + rect.h; ++ i) {
			for (size_t j = rect.x; j < rect.x + rect.w; ++ j) {
				cells[i][j] = Cell(ch, Attributes(fg, bg));
			}
		}
	}

	/// draws the outline of a rectangle
	void DrawBox(
		SDL_Rect rect, ubyte fg = Colour.White, ubyte bg = Colour.Black
	) {
		for (size_t i = rect.y + 1; i < rect.y + rect.h - 1; ++ i) {
			Cell cell = Cell(0xB3, Attributes(fg, bg));
			
			cells[i][rect.x]              = cell;
			cells[i][rect.x + rect.w - 1] = cell;
		}

		for (size_t i = rect.x + 1; i < rect.x + rect.w - 1; ++ i) {
			Cell cell = Cell(0xC4, Attributes(fg, bg));

			cells[rect.y][i]              = cell;
			cells[rect.y + rect.h - 1][i] = cell;
		}

		cells[rect.y][rect.x]              = Cell(0xDA, Attributes(fg, bg));
		cells[rect.y + rect.h - 1][rect.x] = Cell(0xC0, Attributes(fg, bg));
		cells[rect.y][rect.x + rect.w - 1] = Cell(0xBF, Attributes(fg, bg));
		
		cells[rect.y + rect.h - 1][rect.x + rect.w - 1] = Cell(
			0xD9, Attributes(fg, bg)
		);
	}

	override bool HandleEvent(Project parent, SDL_Event e) {
		return false;
	}

	override void Render(Project parent) {
		foreach (i, ref line ; cells) {
			foreach (j, ch ; line) {
				auto rect = SDL_Rect(
					(cast(int) j * cellSize.x) + pos.x,
					(cast(int) i * cellSize.y) + pos.y,
					cellSize.x,
					cellSize.y
				);

				SDL_Color fg = palette[ch.attr.fg];
				SDL_Color bg = palette[ch.attr.bg];

				SDL_SetRenderDrawColor(parent.renderer, bg.r, bg.g, bg.b, 255);
				SDL_RenderFillRect(parent.renderer, &rect);

				if (ch.ch != ' ') {
					/*text.DrawCharacter(
						video.renderer, ch.ch, Vec2!int(rect.x, rect.y), fg
					);*/

					if (characters[ch.ch] is null) {
						continue;
					}

					SDL_SetTextureColorMod(characters[ch.ch], fg.r, fg.g, fg.b);

					SDL_RenderCopy(
						parent.renderer, characters[ch.ch], null, &rect
					);
				}
			}
		}
	}
}

