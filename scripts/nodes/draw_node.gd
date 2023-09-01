extends Node2D
class_name DrawNode

var a_points: Array[int] = []
var b_points: Array[int] = []

func _ready():
	Signals.add_line.connect(_add_line)
	Signals.clear_lines.connect(_clear_lines)

func _add_line(a: int, b: int) -> void:
	a_points.append(a)
	b_points.append(b)
	
	queue_redraw()

func _clear_lines() -> void:
	a_points.clear()
	b_points.clear()
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	for i in a_points.size():
		var a_point = instance_from_id(a_points[i]).position
		var b_point = instance_from_id(b_points[i]).position
		var offset: Vector2 =  Vector2(CardNode.WIDTH, CardNode.HEIGHT)*0.5
		draw_line(a_point+offset, b_point+offset, Color.RED, 4)

func _exit_tree():
	Signals.add_line.disconnect(_add_line)
	Signals.clear_lines.disconnect(_clear_lines)
