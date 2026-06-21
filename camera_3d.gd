extends Camera3D

var tween_node: Tween

const TWEEN_TIME = 5

# --- tweening ---
func smooth_look_at(target_position: Vector3, delta: float):
	var new_transform = self.transform.looking_at(target_position, Vector3.UP)
	self.transform = self.transform.interpolate_with(new_transform, TWEEN_TIME * delta)
# ---

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var all_guys = Tools.get_all_children(get_parent()).filter(func(node): return node is Guy)
	var all_guys_distances = all_guys.map(func(guy): return self.position.distance_to(guy.position))
	var closest_guy = all_guys[all_guys_distances.find(all_guys_distances.min())]
	smooth_look_at(closest_guy.position, delta)
