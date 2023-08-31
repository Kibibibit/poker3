extends RefCounted
class_name Card

const DIAMONDS: int = 0
const HEARTS: int = 1
const SPADES: int = 2
const CLUBS: int = 3

const ACE: int = 0
const TWO: int = 1
const THREE: int = 2
const FOUR: int = 3
const FIVE: int = 4
const SIX: int = 5
const SEVEN: int = 6
const EIGHT: int = 7
const NINE: int = 8
const TEN: int = 9
const JACK: int = 10
const QUEEN: int = 11
const KING: int = 12

var value: int
var suit: int

func _init(p_value: int, p_suit: int)->void:
	value = p_value
	suit = p_suit





