extends Node2D
class_name GameBoard

const GRID_WIDTH: int = 5
const GRID_HEIGHT: int = 4

signal score_updated(amount: int, new_score:int)


@onready
var grid: Grid = Grid.new(Vector2i(GRID_WIDTH, GRID_HEIGHT))

var deck: Array[Card] = []
var discards: Array[Card] = []

var awaiting_cards: Array[int]

var spawn_queues: Dictionary = {}

var mouse_down: bool = false
var current_card: int = -1

var selected_cards: Array[int] = []
var dragging = false

var score: int = 0

func _ready():
	for x in GRID_WIDTH:
		spawn_queues[x] = []
	start_game()

func start_game():
	_generate_deck()
	_spawn_initial_cards()

func _draw_card() -> Card:
	if (deck.is_empty()):
		_shuffle_discards()
	return deck.pop_back()

func _generate_deck() -> void:
	for suit in 4:
		for value in 13:
			deck.append(Card.new(value, suit))
	deck.shuffle()

func _shuffle_discards() -> void:
	while !discards.is_empty():
		deck.append(discards.pop_back())
	deck.shuffle()

func _spawn_initial_cards():
	for y in GRID_HEIGHT:
		for x in GRID_WIDTH:
			_spawn_card(Vector2i(x,y))

func _get_card(card_id: int) -> CardNode:
	if (is_instance_id_valid(card_id)):
		return instance_from_id(card_id)
	else:
		return null

func _can_select(card_id: int) -> bool:
	if (selected_cards.is_empty()):
		return true
	else:
		var last_pos: Vector2 = Vector2(_get_card(selected_cards.back()).grid_position)
		var new_pos: Vector2 = Vector2(_get_card(card_id).grid_position)
		return last_pos.distance_squared_to(new_pos) <= 2

func _spawn_card(grid_pos: Vector2i):
	var card: Card = _draw_card()
	var card_node: CardNode = CardNode.new(card)
	card_node.grid_position = grid_pos
	var card_id = card_node.get_instance_id()
	awaiting_cards.append(card_id)
	
	grid.set_at(card_id, grid_pos)
	
	add_child(card_node)
	
	card_node.mouse_entered.connect(_card_mouse_entered)
	card_node.mouse_exited.connect(_card_mouse_exited)
	card_node.reached_target_position.connect(_card_finished_animating)
	

	
	card_node.position = _get_card_pos(Vector2i(grid_pos.x, grid_pos.y-GRID_HEIGHT))
	card_node.animate_to(_get_card_pos(grid_pos))
	


func _fill_board():
	for x in GRID_WIDTH:
		for _y in GRID_HEIGHT:
			var y = GRID_HEIGHT-_y-1
			var pos: Vector2i = Vector2i(x,y)
			var card_at_pos: int = grid.get_at(pos)
			for _i in y:
				var i = y-_i-1
				if (card_at_pos == Grid.NULL):
					var check_pos = Vector2i(x,i)
					var card_at_check: int = grid.get_at(check_pos)
					if (card_at_check != Grid.NULL):
						var card_node: CardNode = _get_card(card_at_check)
						grid.set_at(Grid.NULL, check_pos)
						grid.set_at(card_at_check, pos)
						card_node.grid_position = pos
						card_node.animate_to(_get_card_pos(pos))
						break
		for _y in GRID_HEIGHT:
			var y = GRID_HEIGHT-_y-1
			var pos: Vector2i = Vector2i(x,y)
			var card_at_pos: int = grid.get_at(pos)
			if (card_at_pos == Grid.NULL):
				_spawn_card(pos)

				


func _get_card_pos(grid_pos: Vector2i):
	return (Vector2(grid_pos)*Vector2(CardNode.HEIGHT+8, CardNode.HEIGHT+8))+Vector2(8,8)

func _card_finished_animating(card_id: int):
	if (card_id in awaiting_cards):
		awaiting_cards.remove_at(awaiting_cards.find(card_id))

func _card_mouse_entered(card_id: int):
	current_card = card_id
	if (dragging && !card_id in selected_cards && !card_id in awaiting_cards && selected_cards.size() < 5):
		if (_can_select(card_id)):
			selected_cards.append(card_id)
			_highlight_card(card_id)

func _card_mouse_exited(_card_id: int):
	current_card = -1



func _unhandled_input(event):
	if (event is InputEventMouseButton):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			if (event.pressed):
				mouse_down = true
				if (current_card != -1 && !current_card in awaiting_cards):
					_start_drag()
					_highlight_card(current_card)
			else:
				mouse_down = false
				if (!selected_cards.is_empty()):
					_end_drag()

func _highlight_card(card_id: int):
	var card_node: CardNode = _get_card(card_id)
	if (card_node != null):
		card_node.highlight(true)


func _delete_card(card_id: int):
	var pos: Vector2i = _get_card(card_id).grid_position
	grid.set_at(Grid.NULL, pos)
	
	var card_node: CardNode = _get_card(card_id)
	
	card_node.mouse_entered.disconnect(_card_mouse_entered)
	card_node.mouse_exited.disconnect(_card_mouse_exited)
	card_node.reached_target_position.disconnect(_card_finished_animating)
	discards.append(card_node.card)
	remove_child(card_node)
	card_node.queue_free()
	
	
func _start_drag():
	dragging = true
	selected_cards.append(current_card)
	

func _end_drag():
	var cards: Array[Card] = []
	for card_id in selected_cards:
		var card_node: CardNode = _get_card(card_id)
		if (card_node != null):
			card_node.highlight(false)
			cards.append(card_node.card)
	
	if (cards.size() == 5):
		var hand_score = Scoring.score_hand(cards)
		score += hand_score
		score_updated.emit(hand_score, score)
		for card_id in selected_cards:
			_delete_card(card_id)
		_fill_board()
	
	selected_cards.clear()
	dragging = false
	

