extends Node
class_name Attack

var damage: float = 0.0
var attacker: Node3D = null

func _init(damage: float = 0.0, attacker: Node3D = null) -> void:
	self.damage = damage
	self.attacker = attacker
