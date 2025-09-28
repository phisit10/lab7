extends RigidBody3D

signal died

var speed = randf_range(2.0, 4.0)
var health = 3

var flash_time = 0.2  # how long to stay red
var is_flashing = false
var original_materials = []  # store original materials to restore later


@onready var bat_model = %bat_model
@onready var timer = %Timer

@onready var player = get_node("/root/Game/Player")

@onready var hurt_sound = %HurtSound
@onready var ko_sound = %KOSound

@onready var anim_player2: AnimationPlayer = bat_model.get_node("Ghast/AnimationPlayer")


func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed
	bat_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI

func _ready():
	# Store original materials
	if bat_model.get_child_count() > 0:
		for mesh in bat_model.get_children():
			if mesh is MeshInstance3D:
				original_materials.append(mesh.material_override)


func flash_red():
	if is_flashing:
		return
	is_flashing = true

	# Change material to red
	for mesh in bat_model.get_children():
		if mesh is MeshInstance3D:
			var mat = mesh.material_override.duplicate()
			mat.albedo_color = Color.RED
			mesh.material_override = mat
			
	# Wait and then restore
	await get_tree().create_timer(flash_time).timeout
	restore_material()

func restore_material():
	for i in range(len(bat_model.get_children())):
		var mesh = bat_model.get_children()[i]
		if mesh is MeshInstance3D:
			mesh.material_override = original_materials[i]
	is_flashing = false


func take_damage():
	if health <= 0:
		return
		
	anim_player2.play("hurtt")
	bat_model.hurt()
	flash_red()
	health -= 1
	hurt_sound.pitch_scale = randfn(1.0, 0.1)
	hurt_sound.play()

	if health == 0:
		ko_sound.play()

		set_physics_process(false)
		gravity_scale = 1.0
		var direction = player.global_position.direction_to(global_position)
		var random_upward_force = Vector3.UP * randf() * 5.0
		apply_central_impulse(direction.rotated(Vector3.UP, randf_range(-0.2, 0.2)) * 10.0 + random_upward_force)

		timer.start()


func _on_timer_timeout():
	queue_free()
	died.emit()
