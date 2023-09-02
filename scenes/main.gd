extends Node2D



@onready
var game_board: GameBoard = $GameBoard

@onready
var score_label: Label = $VBoxContainer/ScoreLabel

@onready
var hand_value_label: Label = $VBoxContainer/HandValueLabel

@onready
var hand_labels: Label = $VBoxContainer/HandsLabels

var previous_hands: Array[String] = []

func _ready():
	get_tree().set_auto_accept_quit(false)
	game_board.score_updated.connect(_score_updated)
	Signals.destroy_card.connect(_destroy_card)
	
func _score_updated(amount: int, new_score: int, base_points: int, hand_type: int, cards: Array[Card]):
	score_label.text = "Score: %s" % new_score
	hand_value_label.text = "Last Hand: +%s (%s x%s for %s)" % [amount, base_points, hand_type, Scoring._HAND_TYPE_MAP[hand_type]]
	
	var cards_string = "%s,%s,%s,%s,%s" % cards
	var hand_string = "%s : %s : %s" % [Scoring._HAND_TYPE_MAP[hand_type], amount, cards_string]
	previous_hands.append(hand_string)
	if (previous_hands.size() > 10):
		previous_hands.pop_front()
	
	var label_string: String = "Previous Hands:"
	for string in previous_hands:
		label_string = "%s\n%s" % [label_string,string]
	hand_labels.text = label_string

func _destroy_card(pos: Vector2):
	var card_destroy: Node2D = Assets.card_destroy.instantiate()
	card_destroy.position = pos
	add_child.call_deferred(card_destroy)



func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().root.queue_free()
		get_tree().quit() # default behavior

