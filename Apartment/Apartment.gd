@tool
extends Node2D


const ROOM_WALL_HEIGHT: int = 70
var _rooms: Dictionary[String, Room] = {}
var _furnitureTexture: Texture2D

func _ready() -> void:
    var file: FileAccess = FileAccess.open("res://Assets/Map.json", FileAccess.READ)
    var content: String = file.get_as_text()
    file.close()


    var regex = RegEx.new()
    regex.compile(".*//.*")
    var cleanContent: String = regex.sub(content, "", true)

    var json: Dictionary = JSON.parse_string(cleanContent)
    for roomName in json["Rooms"].keys():
        if roomName == "Furniture":
            continue
        var roomData: Dictionary = json["Rooms"][roomName]
        var newRoom: Room = ParseRoom(roomName, roomData)
        for connectionData in roomData["Connections"]:
            newRoom.Connections.append(ParseConnection(connectionData))
        if roomData.has("Tiles"):
            for tileData in roomData["Tiles"]:
                newRoom.Tiles.append(ParseTile(tileData))


    var furniture_spritesheet:Image = load("res://Assets/Furniture.png")

    for furniture in json["Furniture"].keys():
        var obj = json["Furniture"][furniture]
        var sprite_sheet_x = obj.X
        var sprite_sheet_y = obj.Y
        var sprite_width = obj.Width
        var sprite_height = obj.Height

        # we now extract the sprite from the spritesheet
        var rect = Rect2(sprite_sheet_x, sprite_sheet_y, sprite_width, sprite_height)
        var img = furniture_spritesheet.get_region(rect)


        var sprite = Sprite2D.new()
        add_child(sprite)

        var render_at_x = obj.RenderOffsetX
        var render_at_y = obj.RenderOffsetY
        var render_z_index = obj.ZIndex

        sprite.texture = ImageTexture.create_from_image(img)

        sprite.centered = false
        sprite.global_position = Vector2(render_at_x, render_at_y)
        sprite.z_index = render_z_index


func ParseRoom(roomName: String, roomData: Dictionary) -> Room:
    var newRoom: Room = Room.new()
    newRoom.X = int(roomData["X"])
    newRoom.Y = int(roomData["Y"])
    newRoom.Width = int(roomData["Width"])
    newRoom.Length = int(roomData["Length"])

    newRoom.Sprite = LoadSprite(roomData["Sprite"])
    #newRoom.Sprite.visible = false
    newRoom.Sprite.position = IsometricUtils.MapTileToScreenCoordinates(newRoom.X, newRoom.Y)
    newRoom.Sprite.position.x -= (newRoom.Width - 1) * (IsometricUtils.TileWidth / 2)
    newRoom.Sprite.position.y -= ROOM_WALL_HEIGHT

    #var roomOrigin: Sprite2D = Sprite2D.new()
    #roomOrigin.texture = load("res://Assets/Tile.png")
    #roomOrigin.centered = false
    #roomOrigin.position = IsometricUtils.MapTileToScreenCoordinates(newRoom.X, newRoom.Y)
    #add_child(roomOrigin)


    _rooms[roomName] = newRoom
    newRoom.Connections = []
    return newRoom


func ParseConnection(connectionData: Dictionary) -> Connection:
    var newConnection: Connection = Connection.new()
    newConnection.X = int(connectionData["X"])
    newConnection.Y = int(connectionData["Y"])
    newConnection.Sprite = LoadSprite(connectionData["Sprite"])
    newConnection.Sprite.position = IsometricUtils.MapTileToScreenCoordinates(newConnection.X, newConnection.Y)
    newConnection.Sprite.visible = false
    newConnection.Sprite.z_index = 1
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
    if tileData.has("FurnitureX"):
        tileData.Sprite = LoadSprite(tileData["Sprite"])
        tileData.Sprite.position = IsometricUtils.MapTileToScreenCoordinates(newTile.X, newTile.Y)
        #tileData.Sprite.visible = false
    return newTile


func LoadSprite(path: String) -> Sprite2D:
    var sprite: Sprite2D = Sprite2D.new()
    sprite.texture = load("res://Assets/" + path)
    sprite.centered = false
    add_child(sprite)
    return sprite
