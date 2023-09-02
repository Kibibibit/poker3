extends Node2D
class_name GameBoard

const GRID_WIDTH: int = 5
const GRID_HEIGHT: int = 6

signal score_updated(amount: int, new_score:int, hand_type: int, cards: Array[Card])


@onready
var grid: Grid = Grid.new(Vector2i(GRID_WIDTH, GRID_HEIGHT))

var deck: Array[Card] = []
var discards: Array[Card] = []

var awaiting_cards: Array[int]

var spawn_queues: SpawnQueues = SpawnQueues.new(GRID_WIDTH)

var mouse_down: bool = false
var current_card: int = -1

var selected_cards: Array[int] = []
var dragging = false

var score: int = 0

func _ready():
	start_game()
	Signals.card_mouse_entered.connect(_card_mouse_entered)
	Signals.card_mouse_exited.connect(_card_mouse_exited)
	Signals.card_reached_target.connect(_card_finished_animating)

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
		if !card_id in awaiting_cards:
			var last_card: CardNode = _get_card(selected_cards.back())
			var next_card: CardNode = _get_card(card_id)
			if (last_card != null && next_card != null):
				var last_pos: Vector2 = Vector2(last_card.grid_position)
				var new_pos: Vector2 = Vector2(next_card.grid_position)
				return last_pos.distance_squared_to(new_pos) <= 2
	return false

func _spawn_card(grid_pos: Vector2i):
	var card: Card = _draw_card()
	var card_node: CardNode = CardNode.new(card)
	card_node.grid_position = grid_pos
	spawn_queues.add_card(card_node)

func _process(_delta: float) -> void:
	for x in GRID_WIDTH:
		if (spawn_queues.column_not_empty(x)):
			_do_spawn_cards(x)

func _do_spawn_cards(column: int):
	var card_ids: Array[int] = spawn_queues.empty_column(column)
	for i in card_ids.size():
		var card_id: int = card_ids[i]
		awaiting_cards.append(card_id)
		var card_node: CardNode = instance_from_id(card_id)
		var grid_pos: Vector2i = card_node.grid_position
		grid.set_at(card_id, grid_pos)
		add_child(card_node)
		card_node.position = _get_card_pos(Vector2i(grid_pos.x, -i-1))
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
		if (awaiting_cards.is_empty()):
			_cascade()

func _clear_selected() -> void:
	while (!selected_cards.is_empty()):
		var card_node: CardNode = _get_card(selected_cards.pop_back())
		if (card_node != null):
			card_node.highlight(false)
	dragging = false
	mouse_down = false
	Signals.clear_lines.emit()

func _cascade() -> void:
	for _y in GRID_HEIGHT:
		var y: int = GRID_HEIGHT-1-_y
		var cards: Array[Card] = []
		var card_ids: Array[int] = []
		for x in GRID_WIDTH:
			var card_id: int = grid.get_at(Vector2i(x, y))
			if (card_id != grid.NULL && !card_id in awaiting_cards):
				card_ids.append(card_id)
				var card_node: CardNode = instance_from_id(card_id)
				cards.append(card_node.card)
		if (cards.size() == 5):
			var hand_type = Scoring.get_hand_type(cards)
			if (hand_type > Scoring.ONE_PAIR):
				_clear_selected()
				_clear_cards(card_ids)

func _card_mouse_entered(card_id: int):
	current_card = card_id
	if (dragging && !card_id in selected_cards && !card_id in awaiting_cards && selected_cards.size() < 5):
		if (_can_select(card_id)):
			selected_cards.append(card_id)
			_highlight_card(card_id)
			if (selected_cards.size() > 1):
				Signals.add_line.emit(card_id, selected_cards[selected_cards.size()-2])

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
					_end_drag(true)
		if (event.button_index == MOUSE_BUTTON_RIGHT && event.pressed):
			_end_drag(false)

func _highlight_card(card_id: int):
	var card_node: CardNode = _get_card(card_id)
	if (card_node != null):
		card_node.highlight(true)


func _delete_card(card_id: int):
	var pos: Vector2i = _get_card(card_id).grid_position
	grid.set_at(Grid.NULL, pos)
	
	var card_node: CardNode = _get_card(card_id)

	discards.append(card_node.card)
	remove_child(card_node)
	card_node.queue_free()
	
	
func _start_drag():
	dragging = true
	selected_cards.append(current_card)

func _end_drag(do_clear: bool):
	if (do_clear):
		_clear_cards(selected_cards)
	Signals.clear_lines.emit()
	Signals.clear_potential_hand.emit()
	for card_id in selected_cards:
		var card_node: CardNode = _get_card(card_id)
		if (card_node != null):
			card_node.highlight(false)
	selected_cards.clear()
	dragging = false

func _clear_cards(card_ids: Array[int]) -> void:
	var cards: Array[Card] = []
	for card_id in card_ids:
		var card_node: CardNode = _get_card(card_id)
		if (card_node != null):
			cards.append(card_node.card)
	if (cards.size() == 5):
		var hand_type = Scoring.get_hand_type(cards)
		var base_points = Scoring.get_base_points(cards, hand_type)
		var hand_score = base_points*hand_type
		score += hand_score
		score_updated.emit(hand_score, score, base_points, hand_type, cards)
		for card_id in card_ids:
			_delete_card(card_id)
		_fill_board()

func _exit_tree():
	
	Signals.card_mouse_entered.disconnect(_card_mouse_entered)
	Signals.card_mouse_exited.disconnect(_card_mouse_exited)
	Signals.card_reached_target.disconnect(_card_finished_animating)
	
	for child in get_children():
		remove_child(child)
		child.free()

