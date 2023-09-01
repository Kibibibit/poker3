extends GPUParticles2D

const ANIM_SPEED: float = 500.0

@onready
var timer: Timer = $Timer
var box_visible = true
var box_size: Vector2 = Vector2(CardNode.WIDTH, CardNode.HEIGHT)*0.5


func _ready():
	timer.timeout.connect(_destroy)


func _process(delta: float):
	if (box_visible):
		box_size = box_size.move_toward(Vector2(0,0), delta*ANIM_SPEED)
		if (box_size.is_zero_approx()):
			box_visible = false
			emitting=true
			timer.start(lifetime*2)
		queue_redraw()

func _draw():
	if (box_visible):
		var rect: Rect2 = Rect2(-box_size, box_size*2)
		draw_rect(rect, Color.WHITE)
		draw_rect(rect, Color.RED,false,4.0)

func _destroy():
	queue_free()
	get_parent().remove_child.call_deferred(self)

func _exit_tree():
	timer.timeout.disconnect(_destroy)
