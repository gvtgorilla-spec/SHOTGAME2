extends Node3D

@onready var tween := get_tree().create_tween()

var point_a := Vector3(0, 0, 0)
var point_b := Vector3(0, 12.0, 0)
var velocity := 2.0

func _ready():
	start_loop()

func start_loop():
	tween = get_tree().create_tween().set_loops() # loop infinito
	tween.tween_property(self, "position", point_b, velocity)
	tween.tween_property(self, "position", point_a, velocity)
	
