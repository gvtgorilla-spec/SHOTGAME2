extends CharacterBody3D

@export var MoveSpeed: float = 6.0
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health_component = $HealthComponent
@onready var mesh := $inimigomesh
var original_color := Color(2,0.2,0.2,1)
var flashing := false


var reach_block = 1.0

var player: RigidBody3D = null


func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	var m: StandardMaterial3D = mesh.get_active_material(0)
	original_color = m.albedo_color  # salva cor original
	
func _process(delta: float) -> void:
	navigation_agent.target_position = player.global_position
	
func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	# Atualiza a posição alvo do agente de navegação
	
	
	if navigation_agent.is_navigation_finished():
		return
		
	var next_position: Vector3 = navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next_position) * MoveSpeed
	
	move_and_slide()
	
func take_damage(amount: float) -> void:
	health_component.apply_damage(amount, self)
	flash_hit()
	$HealthBar.take_damage(amount)
	
func on_death():
	queue_free()
	
func flash_hit():
	if flashing:
		return

	flashing = true

	var m: StandardMaterial3D = mesh.get_active_material(0)
	m.albedo_color = Color(1, 1, 1)

	await get_tree().create_timer(0.1).timeout

	m.albedo_color = original_color
	flashing = false
