extends RefCounted
class_name Grid

const NULL: int = -1
var _data: Array[int] = []

var size: Vector2i = Vector2i(0,0)


func _init(p_size: Vector2i) -> void:
	size=p_size
	for i in size.x*size.y:
		_data.append(NULL)


func contains_pos(vector: Vector2i) -> bool:
	return vector.x >= 0 && vector.y >= 0 && vector.x < size.x && vector.y < size.y


func _index_of(vector: Vector2i)->int:
	assert(contains_pos(vector), "%s is out of bounds for grid of size %s" % [vector, size])
	return (vector.y*size.x)+vector.x

func get_at(vector: Vector2i)->int:
	return _data[_index_of(vector)]

func set_at(value: int, vector: Vector2i)->void:
	_data[_index_of(vector)] = value
