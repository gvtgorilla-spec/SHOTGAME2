extends Sprite3D

signal no_hp_left

@export var max_health: int = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewport/Panel/ProgressBar.max_value = max_health
	$SubViewport/Panel/ProgressBar.value = max_health


func take_damage(damage: float):
	$SubViewport/Panel/ProgressBar.value -= damage
	
	if $SubViewport/Panel/ProgressBar.value <= 0.1:
		no_hp_left.emit()
