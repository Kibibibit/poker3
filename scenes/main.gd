extends Node2D



@onready
var game_board: GameBoard = $GameBoard

@onready
var score_label: Label = $VBoxContainer/ScoreLabel

@onready
var hand_value_label: Label = $VBoxContainer/HandValueLabel

func _ready():
	game_board.score_updated.connect(_score_updated)
	
	
func _score_updated(amount: int, new_score: int):
	score_label.text = "Score: %s" % new_score
	hand_value_label.text = "Last Hand: +%s" % amount
