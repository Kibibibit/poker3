extends Node


signal card_reached_target(instance_id: int)
signal card_mouse_entered(instance_id: int)
signal card_mouse_exited(instance_id: int)

signal add_line(a: int, b: int)
signal clear_lines()

signal update_potential_hand(hand_type: int, score: int)
signal clear_potential_hand()

signal destroy_card(pos: Vector2)
