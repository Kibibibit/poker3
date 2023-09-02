extends RefCounted
class_name SpawnQueues


var _data: Dictionary = {}


func _init(width: int):
	for x in width:
		_data[x] = {}


func add_card(card_node: CardNode):
	_data[card_node.grid_position.x][card_node.grid_position.y] = card_node.get_instance_id()

func column_not_empty(column: int) -> bool:
	return !_data[column].is_empty()

func empty_column(column: int) -> Array[int]:
	var column_list: Dictionary = _data[column]
	var keys = column_list.keys()
	keys.sort()
	keys.reverse()
	
	var out: Array[int] = []
	for key in keys:
		out.append(column_list[key])
	
	_data[column].clear()
	return out
	
