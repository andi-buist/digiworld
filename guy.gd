class_name Guy extends CharacterBody3D

enum AI_STATE{IDLE, WANDER}

const SHOW_TARGET = false
const SPEED = 1
const IDLE_RATE = 0.2
const IDLE_TIME:= {"min": 1.5, "max": 5.0}

var target = Node3D.new()
var state:= AI_STATE.WANDER

# --- instance random traits ---
var color:= Color.from_hsv(randf(),1,1)
var guy_content: Dictionary
# ---

# --- styling ---
func build_material() -> Material:
	var material = ShaderMaterial.new()
	material.shader = load("res://guy_material.gdshader")
	material.set_shader_parameter("color", color)
	material.set_shader_parameter("color_coat", .25)
	material.set_shader_parameter("blur_amount", 2.0)
	material.set_shader_parameter("refraction_strength", 1)
	return material
# ---

# ---ai helpers---
func near_target() -> bool:
	return self.position.distance_to(target.position) <= 1 

func randomise_target_location():
	var new_pos = self.position + Vector3(0,0,5).rotated(Vector3.UP, self.rotation.y + randf_range(-PI/4, PI/4))
	target.position = new_pos
# ---

# ---ai patterns---
func move_to_target():
	self.look_at(target.position,Vector3.UP,true)
	self.rotation.x = 0
	self.rotation.z = 0
	var direction = target.position - self.position
	self.velocity = direction.normalized() * SPEED
	move_and_slide()
# ---

# ---state functions---
func idle_action():
	if %idle_timer.is_stopped():
		%idle_timer.wait_time = randf_range(IDLE_TIME["min"], IDLE_TIME["max"])
		%idle_timer.start()
			
func wander_action():
	move_to_target()
	var actual_speed = round(self.get_real_velocity().length() * 100)/100
	if actual_speed < SPEED * 0.5:
		%thoughts.show()
	else:
		%thoughts.hide()
	if near_target():
		randomise_target_location()
		if randf() < IDLE_RATE:
			state = AI_STATE.IDLE
# ---

func state_manager():
	match state:
		AI_STATE.IDLE:
			idle_action()
		AI_STATE.WANDER:
			wander_action()

func _set_name_from_api():
	if len(Api.pages) > 0: 
		self.guy_content = Api.pages.pop_front()
		%label.text = self.guy_content["title"]
	

func _ready() -> void:
	Api.pages_stocked.connect(_set_name_from_api)
	# --- styling ---
	var material = build_material()
	%head.material_override = material
	$body.material_override = material
	# ---
	
	# --- timers ---
	%idle_timer.connect("timeout", func(): state = AI_STATE.WANDER)
	# ---
	
	self.rotation = Vector3.UP * randf() * PI
	
	self.get_parent().add_child.call_deferred(target)
	randomise_target_location()
	
	if SHOW_TARGET:
		var target_indicator = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = .25
		sphere_mesh.height = .5
		target_indicator.mesh = sphere_mesh
		target.add_child(target_indicator)

func _process(delta):
	pass
	
func _physics_process(delta):
	state_manager()
