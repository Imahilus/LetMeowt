extends Node2D


const ROOM_WALL_HEIGHT: int = 70
var Rooms: Dictionary[String, Room] = {}
var _furnitureTexture: Texture2D
var FurniturePieces: Dictionary[String, Furniture] = {}

var Rube: Cat

func _ready() -> void:
	var file: FileAccess = FileAccess.open("res://Assets/Map.json", FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()

	var regex = RegEx.new()
	regex.compile(".*//.*")
	var cleanContent: String = regex.sub(content, "", true)
	
	var json: Dictionary = JSON.parse_string(cleanContent)
	
	position.x += 600
	position.y += 100
	
	_furnitureTexture = load("res://Assets/Furniture.png")
	for furnitureName in json["Furniture"].keys():
		var furnitureData: Dictionary = json["Furniture"][furnitureName]
		var newFurniture: Furniture = ParseFurniture(furnitureName, furnitureData)
	
	for roomName in json["Rooms"].keys():
		var roomData: Dictionary = json["Rooms"][roomName]
		var newRoom: Room = ParseRoom(roomName, roomData)
		for connectionData in roomData["Connections"]:
			newRoom.Connections.append(ParseConnection(connectionData))
		if roomData.has("Tiles"):
			for tileData in roomData["Tiles"]:
				newRoom.Tiles.append(ParseTile(tileData))


func ParseFurniture(furnitureName: String, furnitureData: Dictionary) -> Furniture:
	var newFurniture: Furniture = Furniture.new()
	newFurniture.X = int(furnitureData["X"])
	newFurniture.Y = int(furnitureData["Y"])
	newFurniture.Width = int(furnitureData["Width"])
	newFurniture.Height = int(furnitureData["Height"])
	newFurniture.RenderOffsetX = int(furnitureData["RenderOffsetX"])
	newFurniture.RenderOffsetY = int(furnitureData["RenderOffsetY"])
	newFurniture.ZIndex = int(furnitureData["ZIndex"])
	FurniturePieces[furnitureName] = newFurniture
	return newFurniture


func ParseRoom(roomName: String, roomData: Dictionary) -> Room:
	var newRoom: Room = Room.new()
	newRoom.X = int(roomData["X"])
	newRoom.Y = int(roomData["Y"])
	newRoom.Width = int(roomData["Width"])
	newRoom.Length = int(roomData["Length"])
	newRoom.Sprite = LoadTexture(roomData["Sprite"])

	Rooms[roomName] = newRoom
	newRoom.Connections = []
	return newRoom


func ParseConnection(connectionData: Dictionary) -> Connection:
	var newConnection: Connection = Connection.new()
	newConnection.X = int(connectionData["X"])
	newConnection.Y = int(connectionData["Y"])
	newConnection.Sprite = LoadTexture(connectionData["Sprite"])
	newConnection.Room = connectionData["Room"]
	return newConnection


func ParseTile(tileData: Dictionary) -> Tile:
	var newTile: Tile = Tile.new()
	newTile.X = int(tileData["X"])
	newTile.Y = int(tileData["Y"])
	if tileData.has("Height"):
		newTile.Height = int(tileData["Height"])
	if tileData.has("Collision"):
		newTile.Collision = tileData["Collision"] == 1
	if tileData.has("Jeremy"):
		newTile.JeremyInteractable = true
	if tileData.has("Cat"):
		newTile.CatInteractable = true
	if tileData.has("Sprite"):
		newTile.Sprite = tileData["Sprite"]
	return newTile


func LoadTexture(path: String) -> Texture2D:
	print("Loading texture: res://Assets/" + path)
	return load("res://Assets/" + path)


func _process(_deltaInMs: float) -> void:
	queue_redraw()


func _draw() -> void:
	for x in range(17):
		for y in range(12):
			for room: Room in Rooms.values():
				if(room.X == x && room.Y == y):
					var roomScreenCoordinates: Vector2 = IsometricUtils.MapTileToScreenCoordinates(x, y)
					roomScreenCoordinates.x -= (room.Width - 1) * (IsometricUtils.TileWidth / 2)
					roomScreenCoordinates.y -= ROOM_WALL_HEIGHT
					draw_texture(room.Sprite, roomScreenCoordinates)
				RenderTiles(x, y, room, 0)
				RenderTiles(x, y, room, 0)


func RenderTiles(x: int, y: int, room: Room, forZIndex: int) -> void:
	var screenCoordinates: Vector2 = IsometricUtils.MapTileToScreenCoordinates(x, y)
	for tile: Tile in room.Tiles:
		if(tile.X == x && tile.Y == y):
			if(tile.Sprite != ""):
				var furniturePiece: Furniture = FurniturePieces[tile.Sprite]
				if(furniturePiece.ZIndex == forZIndex):
					var sourceRect: Rect2 = Rect2(furniturePiece.X, furniturePiece.Y, furniturePiece.Width, furniturePiece.Height)
					var destinationRect: Rect2 = Rect2(screenCoordinates.x - furniturePiece.RenderOffsetX, screenCoordinates.y - furniturePiece.RenderOffsetY, furniturePiece.Width, furniturePiece.Height)
					draw_texture_rect_region(_furnitureTexture, destinationRect, sourceRect)


func RenderEntities(x: int, y: int) -> void:
	pass
