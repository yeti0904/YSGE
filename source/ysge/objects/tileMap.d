/// contains the tile map object class
module ysge.objects.tileMap;

import std.math;
import ysge.project;

struct Tile {
	int id;

	this(int pid) {
		id = pid;
	}
}

/// tile type definition
struct TileDef {
	RenderType  renderType; /// whether it renders as a colour or texture
	RenderValue render; /// what it uses to render
	RenderProps renderProps;
	bool        hasCollision; /// whether it can collide with other boxes
}

/// tile map object with fast AABB collision
class TileMap : GameObject {
	Tile*[][]    tiles;
	Vec2!int     tileSize;
	TileDef[int] tileDefs;
	Vec2!int     pos;
	bool         doCollision = true; /// whether collision should be checked at all

	/// initialises the tile map
	this(Vec2!ulong size) {
		tiles = new Tile*[][](size.y, size.x);

		foreach (ref line ; tiles) {
			foreach (ref tile ; line) {
				tile = new Tile(0);
			}
		}
	}

	/// loads tiles from a 2d array of tile ids
	void FromIDs(int[][] ids) {
		foreach (i, ref line ; ids) {
			foreach (j, ref tile ; line) {
				tiles[i][j] = new Tile(tile);
			}
		}
	}

	/// returns the map size
	Vec2!ulong GetSize() {
		if (tiles.length == 0) {
			return Vec2!ulong(0, 0);
		}

		return Vec2!ulong(
			tiles[0].length,
			tiles.length
		);
	}

	/// sets the map size (resets all tiles)
	void SetSize(Vec2!ulong size) {
		tiles = new Tile*[][](size.y, size.x);

		foreach (ref line ; tiles) {
			foreach (ref tile ; line) {
				tile = new Tile(0);
			}
		}
	}

	/**
	* updates the tile map
	* should not be called by user
	*/
	override void Update(Project parent) {
		
	}

	/**
	* checks collision with fast AABB
	* should not be called by user
	*/
	override bool CollidesWith(SimpleBox other) {
		if (!doCollision) {
			return false;
		}
	
		Vec2!int posOnMap  = Vec2!int(other.box.x, other.box.y);
		posOnMap.x        -= pos.x;
		posOnMap.y        -= pos.y;

		Vec2!int start = Vec2!int(
			cast(int) floor(posOnMap.CastTo!float().x / tileSize.x),
			cast(int) floor(posOnMap.CastTo!float().y / tileSize.y)
		);
		Vec2!int end = Vec2!int(
			cast(int) ceil(posOnMap.CastTo!float().x / tileSize.x),
			cast(int) ceil(posOnMap.CastTo!float().y / tileSize.y)
		);

		Vec2!int otherSize = Vec2!int(other.box.w, other.box.h);

		end.x += cast(int) ceil(otherSize.CastTo!float().x / tileSize.x);
		end.y += cast(int) ceil(otherSize.CastTo!float().y / tileSize.y);

		for (int y = start.y; y <= end.y; ++ y) {
			for (int x = start.x; x <= end.x; ++ x) {
				if (
					(y < 0) ||
					(x < 0) ||
					(y >= tiles.length) ||
					(x >= tiles[0].length)
				) {
					continue;
				}

				auto tile = tiles[y][x];
				auto def  = tileDefs[tile.id];

				if (!def.hasCollision) {
					continue;
				}

				SDL_Rect box;
				box.x = x * tileSize.x;
				box.y = y * tileSize.y;
				box.w = tileSize.x;
				box.h = tileSize.y;
 
				if (
					(box.x < other.box.x + other.box.w) &&
					(box.x + box.w > other.box.x) &&
					(box.y < other.box.y + other.box.h) &&
					(box.y + box.h > other.box.y)
				) {
					return true;
				}
			}
		}

		return false;
	}

	/**
	* renders the object
	* should not be called by user
	*/
	override void Render(Project parent) {
		Vec2!int start = Vec2!int(
			pos.x - parent.currentScene.camera.x,
			pos.y - parent.currentScene.camera.y
		);

		for (int y = 0; y < tiles.length; ++ y) {
			for (int x = 0; x < tiles[0].length; ++ x) {
				Vec2!int tilePos = Vec2!int(
					start.x + (x * tileSize.x),
					start.y + (y * tileSize.y)
				);
				Vec2!int tileEnd = Vec2!int(
					tilePos.x + tileSize.x,
					tilePos.y + tileSize.y
				);

				auto res = parent.GetResolution();

				if (
					(tileEnd.x < 0) ||
					(tileEnd.y < 0)
				) {
					continue;
				}

				if (
					(tilePos.x > res.x) ||
					(tilePos.y > res.y)
				) {
					break;
				}

				auto tile = tiles[y][x];
				auto def  = tileDefs[tile.id];
				auto rect = SDL_Rect(
					tilePos.x, tilePos.y, tileSize.x, tileSize.y
				);

				switch (def.renderType) {
					case RenderType.Colour: {
						if (def.render.colour.a == 0) {
							break;
						}
						
						SDL_SetRenderDrawColor(
							parent.renderer,
							def.render.colour.r,
							def.render.colour.g,
							def.render.colour.b,
							def.render.colour.a
						);
						SDL_RenderFillRect(parent.renderer, &rect);
						break;
					}
					case RenderType.Texture: {
						SDL_Rect* src;

						if (def.renderProps.doCrop) {
							src  = new SDL_Rect();
							*src = def.renderProps.crop;
						}
					
						SDL_RenderCopy(
							parent.renderer, def.render.texture.texture, src,
							&rect
						);
						break;
					}
					default: assert(0);
				}
			}
		}
	}
}
