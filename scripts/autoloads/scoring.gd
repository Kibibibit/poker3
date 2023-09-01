extends Node

const HIGH_CARD: int = 1
const ONE_PAIR: int = 2
const TWO_PAIR: int = 4
const THREE_OF_A_KIND: int = 8
const STRAIGHT: int = 16
const FLUSH: int = 32
const FULL_HOUSE: int = 64
const FOUR_OF_A_KIND: int = 128
const STRAIGHT_FLUSH: int = 256
const ROYAL_FLUSH: int = 512

const _HAND_TYPE_MAP: Dictionary = {
	HIGH_CARD: "high card",
	ONE_PAIR: "pair",
	TWO_PAIR: "two-pair",
	THREE_OF_A_KIND: "3-of-a-kind",
	STRAIGHT: "straight",
	FLUSH: "flush",
	FULL_HOUSE:"full house",
	FOUR_OF_A_KIND: "4-of-a-kind",
	STRAIGHT_FLUSH: "straight flush",
	ROYAL_FLUSH: "royal flush"
}

func score_hand(hand: Array[Card]) -> int:
	var hand_type: int = get_hand_type(hand)
	var base_points: int = get_base_points(hand, hand_type)
	return hand_type*base_points

func get_base_points(hand: Array[Card], hand_type: int = HIGH_CARD) -> int:
	var out: int = 0
	for card in hand:
		var value: int = card.value+1
		if (card.value == Card.ACE):
			value = Card.KING+2
		if (hand_type == HIGH_CARD):
			out = max(out, value)
		else:
			out += value
	return out

func get_hand_type(hand: Array[Card]) -> int:
	
	var histogram: Dictionary = {}
	
	var hand_type: int = HIGH_CARD
	
	var is_flush = true
	var last_suit = -1
	var highest_dupe = 0
	var is_straight = false
	var barrow = false
	
	for card in hand:
		if (card.value in histogram.keys()):
			histogram[card.value] += 1
		else:
			histogram[card.value] = 1
		
		if (histogram[card.value] > highest_dupe):
			highest_dupe = histogram[card.value]

		if (last_suit == -1):
			last_suit = card.suit
		elif (is_flush):
			is_flush = last_suit == card.suit
	
	var keys = histogram.keys()
	
	if (keys.size() == 5):
		keys.sort()
		
		var prev_key = -1
		for key in keys:
			if (prev_key != -1):
				if (key == prev_key+1 || (key == Card.TEN && keys[0] == Card.ACE)):
					is_straight = true
				else:
					is_straight = false
					break
			prev_key = key
	
	if (is_straight):
		if (keys.front() == Card.ACE):
			barrow = keys.back() == Card.KING
	
	var one_pair: bool = false
	var two_pair: bool = false
	var three_of_a_kind: bool = false
	var full_house: bool = false
	var four_of_a_kind: bool = highest_dupe == 4
	
	if (highest_dupe == 2):
		two_pair = keys.size() == 3 # 2-2-1
		one_pair = keys.size() == 4 # 2-1-1-1-1
		
	if (highest_dupe == 3):
		three_of_a_kind = keys.size() == 3 # 3-1-1
		full_house = keys.size() == 2 # 3-2
	
	if (is_straight && is_flush && barrow):
		hand_type = ROYAL_FLUSH
	elif (is_straight && is_flush):
		hand_type = STRAIGHT_FLUSH
	elif (four_of_a_kind):
		hand_type = FOUR_OF_A_KIND
	elif (full_house):
		hand_type = FULL_HOUSE
	elif (is_flush):
		hand_type = FLUSH
	elif (is_straight):
		hand_type = STRAIGHT
	elif (three_of_a_kind):
		hand_type = THREE_OF_A_KIND
	elif (two_pair):
		hand_type = TWO_PAIR
	elif (one_pair):
		hand_type = ONE_PAIR
	
	return hand_type
