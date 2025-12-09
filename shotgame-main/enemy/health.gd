extends Node
class_name HealthComponent

@export var max_health: float = 100.0
var health: float

func _ready() -> void:
	health = max_health

func apply_damage(amount: float, attacker: Node3D = null) -> void:
	# usa o Attack global (Attack.gd com class_name Attack)
	var atk := Attack.new(amount, attacker)

	health -= atk.damage

	var parent := get_parent()
	if parent.has_method("on_damage"):
		parent.on_damage(atk)

	if health <= 0 and parent.has_method("on_death"):
		parent.on_death()
