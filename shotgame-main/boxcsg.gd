extends CSGBox3D

@export var texture_size := 1.0

func _ready():
	_update_material_uv()

func _update_material_uv():
	if not material:
		material = StandardMaterial3D.new()

	var mat = material as StandardMaterial3D
	if mat:
		var global_scale_vec = global_transform.basis.get_scale()
		var real_size = size * global_scale_vec
		mat.uv1_scale = Vector3(
			real_size.x / texture_size,
			real_size.y / texture_size,
			real_size.z / texture_size
		)
