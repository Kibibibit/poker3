extends Node

const HIGH_CARD: int = 0
const ONE_PAIR: int = 1
const TWO_PAIR: int = 2
const THREE_OF_A_KIND: int = 4
const STRAIGHT: int = 8
const FLUSH: int = 16
const FULL_HOUSE: int = 32
const FOUR_OF_A_KIND: int = 64
const STRAIGHT_FLUSH: int = 128
const ROYAL_FLUSH: int = 256

func score_hand(hand: Array[Card]) -> int:
	
	var histogram: Dictionary = {}
	
	var hand_type: int = HIGH_CARD
	var base_points: int = 0
	
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
		
		if (card.value == Card.ACE):
			base_points += Card.KING+1
		else:
			base_points += card.value+1
		
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
		print("ROYAL FLUSH")
	elif (is_straight && is_flush):
		hand_type = STRAIGHT_FLUSH
		print("STRAIGHT FLUSH")
	elif (four_of_a_kind):
		hand_type = FOUR_OF_A_KIND
		print("FOUR OF A KIND")
	elif (full_house):
		hand_type = FULL_HOUSE
		print("FULL HOUSE")
	elif (is_flush):
		hand_type = FLUSH
		print("FLUSH")
	elif (is_straight):
		hand_type = STRAIGHT
		print("STRAIGHT")
	elif (three_of_a_kind):
		hand_type = THREE_OF_A_KIND
		print("THREE OF A KIND")
	elif (two_pair):
		hand_type = TWO_PAIR
		print("TWO PAIR")
	elif (one_pair):
		hand_type = ONE_PAIR
		print("ONE PAIR")
	else:
		print("HIGH CARD")
		return keys.max()+1
	
	return base_points*hand_type
