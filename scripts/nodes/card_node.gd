extends Sprite2D
class_name CardNode

const RWIDTH: int = 140
const RHEIGHT: int = 190
const SCALE: float = 0.5

const WIDTH: int = floori(RWIDTH*SCALE)
const HEIGHT: int = floori(RHEIGHT*SCALE)

const GRAVITY: float = 9.8
const MOVE_SPEED: float = 10.0



const VALUE_ORDER: Array[int] = [
	3, # Ace
	12, # 2
	11, # 3
	10, # 4
	9, # 5
	8, # 6
	7, # 7
	6, # 8
	5, # 9
	4, # 10
	2, # Jack
	0, # Queen
	1, # King
]

const REIGON_MAP: Dictionary = {
	Card.DIAMONDS: Vector2(2, 7),
	Card.HEARTS: Vector2(1, 4),
	Card.SPADES: Vector2(0, 0),
	Card.CLUBS: Vector2(4,0)
}

var area: Area2D
var collision_shape: CollisionShape2D

var card: Card
var velocity: Vector2 = Vector2(0,0)

var animating_position: bool = false
var target_position: Vector2 = Vector2(0,0)

var grid_position: Vector2i


var highlighted: bool = false


func _init(p_card: Card):
	card = p_card
	
func _ready() -> void:
	texture = Assets.cards
	centered = false
	region_enabled = true
	region_rect = _get_region()
	area = Area2D.new()
	collision_shape = CollisionShape2D.new()
	
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size =  Vector2(RWIDTH, RHEIGHT)
	collision_shape.position = Vector2((RWIDTH as float)/2, (RHEIGHT as float)/2)
	
	collision_shape.shape = shape
	add_child(area)
	area.add_child(collision_shape)
	
	area.mouse_entered.connect(_mouse_entered)
	area.mouse_exited.connect(_mouse_exited)
	
	
func _process(delta):
	if (animating_position):
		if (target_position.y > position.y):
			velocity.y += delta*GRAVITY
		else:
			velocity.y = MOVE_SPEED*delta
		
		velocity.x = MOVE_SPEED*delta
		
		position.y = move_toward(position.y, target_position.y, velocity.y)
		position.x = move_toward(position.x, target_position.x, velocity.x)
		
		if (position.is_equal_approx(target_position)):
			position = target_position
			velocity = Vector2(0,0)
			animating_position = false
			Signals.card_reached_target.emit(get_instance_id())



func animate_to(p_target_pos: Vector2):
	target_position = p_target_pos
	animating_position = true


func _draw():
	if (highlighted):
		draw_rect(Rect2(0,0,RWIDTH,RHEIGHT), Color.RED, false, 10)

func _get_region() -> Rect2:
	
	var check_suit: int = card.suit
	
	if (card.value == 2):
		if (card.suit == Card.CLUBS):
			check_suit = Card.HEARTS
		elif (card.suit == Card.HEARTS):
			check_suit = Card.CLUBS
	
	var starting_point: Vector2 = REIGON_MAP[check_suit]
	
	starting_point.y += VALUE_ORDER[card.value]
	
	if (starting_point.y >= 10):
		starting_point.y -= 10
		starting_point.x += 1
		
	starting_point.x *= RWIDTH
	starting_point.y *= RHEIGHT
	
	scale = Vector2(0.5,0.5)
	
	
	return Rect2(starting_point,Vector2(RWIDTH,RHEIGHT))

func _mouse_entered():
	Signals.card_mouse_entered.emit(get_instance_id())

func _mouse_exited():
	Signals.card_mouse_exited.emit(get_instance_id())

func highlight(p_highlight: bool):
	highlighted = p_highlight
	queue_redraw()

func _exit_tree()->void:
	Signals.destroy_card.emit(position+ Vector2(WIDTH, HEIGHT)*0.5)
