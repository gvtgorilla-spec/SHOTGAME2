extends RigidBody3D

# rotação da camera
var mouse_sensitivity := 0.002
var twist_input := 0.0
var pitch_input := 0.0

# movimentação
var move_force := 3000.0
var current_force := 3000.0
var run_force := 4000.0
var jump_force := 12.0
var crouch_force := 1000.0
var is_crouching = false


# animação da camera
var bob_speed := 8.0
var bob_amount := 0.2
var bob_timer := 0.0

#crouch
var default_height = 2.0
var crouch_height = 1.0
var capsule: CapsuleShape3D  # declarar a variável

#soco
var punch_cooldown := 0.3
var can_punch := true


@onready var camera = $TwistPivot/PitchPivot/Camera3D
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var ray_floor := $RayCastFloor
@onready var collider := $CollisionShape3D
@onready var RayTop  := $RayCastTop
@onready var RayFloor := $RayCastFloor
@onready var healthlbl := $health
@onready var health := $HealthComponent
@onready var punch_ray := $TwistPivot/PitchPivot/Camera3D/PunchRayCast
@onready var raycrush := $RayCruched

func _ready() -> void:
	capsule = collider.shape as CapsuleShape3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gravity_scale = 3.0

func _process(delta: float) -> void:
	var input := Vector3.ZERO
	var move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	if input.length() > 0:
		input = input.normalized()
		apply_central_force(twist_pivot.basis * input * current_force * delta)

	if Input.is_action_just_pressed("jump") and RayFloor.is_colliding() and !is_crouching:
		apply_impulse(Vector3.UP * jump_force)

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)

	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,
		deg_to_rad(-70),
		deg_to_rad(70)
	)

	# SHIFT para correr
	if Input.is_action_pressed("shift"):
		current_force = run_force
	else:
		current_force = move_force
		

	# RESET
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

	if is_moving():
		bob_timer += delta * bob_speed
		camera.transform.origin.y = sin(bob_timer) * bob_amount
	else:
		camera.transform.origin.y = lerp(camera.transform.origin.y, 0.0, delta * 10)
		
	#crounch
	
	var crouch_pressed = Input.is_action_pressed("crouch")
	var blocked_above = RayTop.is_colliding()
	var crushed = raycrush.is_colliding()
	
	if Input.is_action_pressed("crouch"):
		camera.transform.origin.y = sin(deg_to_rad(-20))
		current_force = crouch_force
		is_crouching = true
		capsule.height = crouch_height
	else:
		if blocked_above:
			camera.transform.origin.y = sin(deg_to_rad(-20))
			current_force = crouch_force
			is_crouching = true
			capsule.height = crouch_height
		else:
			camera.transform.origin.y = lerp(camera.transform.origin.y, 0.0, delta * 10)
			is_crouching = false
			capsule.height = default_height
		
		if crushed:
			on_death()
		
	healthlbl.text =str(health.health)
		

	twist_input = 0.0
	pitch_input = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity

func is_moving() -> bool:
	return linear_velocity.length()> 1.3 and ray_floor.is_colliding()
	
func on_death() -> void:
	get_tree().quit()
	
func punch():
	if not can_punch:
		return
		
	can_punch = false
	
	
	punch_ray.enabled = true
	await get_tree().process_frame
	
	
	if punch_ray.is_colliding():
		var hit = punch_ray.get_collider()
		print ("SOCÃO")
		
		if hit.has_method("take_damage"):
			hit.take_damage(10)
			
	punch_ray.enabled = false
	
	await get_tree().create_timer(punch_cooldown).timeout
	can_punch = true
	
func _input(event):
	if event.is_action_pressed("punch"):
		punch()
