extends Control

@export var speed: float = 4.5
@export var color: Color = Color(0.95, 0.95, 0.95, 1.0)
@export var track_color: Color = Color(1, 1, 1, 0.12)
@export var line_width: float = 2.5
@export var arc_degrees: float = 280.0

var _angle: float = 0.0
var _spinning: bool = false


func _ready() -> void:
  mouse_filter = MOUSE_FILTER_IGNORE
  set_spinning(false)


func set_spinning(on: bool) -> void:
  _spinning = on
  modulate.a = 1.0 if on else 0.0
  set_process(on)
  queue_redraw()


func _process(delta: float) -> void:
  _angle = fposmod(_angle + delta * speed, TAU)
  queue_redraw()


func _draw() -> void:
  if not _spinning:
    return
  var center: Vector2 = size / 2
  var radius: float = min(size.x, size.y) / 2 - line_width
  if radius <= 0:
    return
  draw_arc(center, radius, 0.0, TAU, 48, track_color, line_width, true)
  var sweep: float = deg_to_rad(arc_degrees)
  draw_arc(center, radius, _angle, _angle + sweep, 48, color, line_width, true)
