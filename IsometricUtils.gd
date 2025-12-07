extends Node
class_name IsometricUtils


const TileWidth = 64;
const TileHeight = 32;


static func MapTileToScreenCoordinates(mapX: int, mapY: int) -> Vector2:
	var halfTileWidth: int = TileWidth / 2
	var halfTileHeight: int = TileHeight / 2
	var coordinates:Vector2 = Vector2((mapX * -halfTileWidth) + (mapY * halfTileWidth), (mapX + mapY) * halfTileHeight)
	return coordinates
