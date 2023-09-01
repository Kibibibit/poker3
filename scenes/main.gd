extends Node2D



@onready
var game_board: GameBoard = $GameBoard

@onready
var score_label: Label = $VBoxContainer/ScoreLabel

@onready
var hand_value_label: Label = $VBoxContainer/HandValueLabel

func _ready():
	game_board.score_updated.connect(_score_updated)
	Signals.destroy_card.connect(_destroy_card)
	
func _score_updated(amount: int, new_score: int):
	score_label.text = "Score: %s" % new_score
	hand_value_label.text = "Last Hand: +%s" % amount

func _destroy_card(pos: Vector2):
	var card_destroy: Node2D = Assets.card_destroy.instantiate()
	card_destroy.position = pos
	add_child.call_deferred(card_destroy)
