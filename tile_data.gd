@tool
extends Node2D

func _iso_points(pos: Vector2) -> PackedVector2Array:
    var w := 64.0
    var h := 32.0

    var pts := [
        pos + Vector2(-w/2, 0),      # left
        pos + Vector2(0, -h/2),      # top
        pos + Vector2(w/2, 0),       # right
        pos + Vector2(0, h/2)        # bottom
    ]
    return pts

func draw_iso_tile(pos: Vector2) -> void:
    var pts = _iso_points(pos)
    draw_polygon(pts, [Color(0.698, 0.0, 0.698, 1.0)])

func _draw() -> void:
    draw_iso_tile(Vector2.ZERO)
