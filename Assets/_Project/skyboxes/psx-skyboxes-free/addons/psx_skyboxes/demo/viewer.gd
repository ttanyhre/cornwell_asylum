extends Node
## A place to look at the pack's skies: each sky's Environment (its fog and ambient light matched
## to it) over a flat plain with a few houses, poles and pines against the horizon. With PSX Look
## in the project (res://addons/psx_look/), as the pack ships it, P shows it through it.
## Keys: left / right the sky, up / down the category, C the cubemap or the panorama material,
## G the ground, P PSX Look; drag to look, the wheel to zoom. Left alone, it turns slowly.

const PSX_LOOK := "res://addons/psx_look/"
const AFFINE := 0.3  # PSX Look's warp, as the gallery's (gallery.gd)
const EYE := 1.7

## Hides the panel and holds the view still, for the store captures.
@export var still := false

var dir: String
var skies: Array
var index := -1
var cube := true  # the cubemap material, or else the panorama one
var world := Node3D.new()
var ground := Node3D.new()
var sun := DirectionalLight3D.new()
var cam := Camera3D.new()
var we := WorldEnvironment.new()
var yaw := PI  # towards +z, where a sky's sun or moon is
var pitch := 0.12
var idle := 0.0
var psx_screen: Control
var psx_on := false
var ui := CanvasLayer.new()
var title := Label.new()
var info := Label.new()
var psx_button := Button.new()


func _ready() -> void:
	dir = (get_script() as Script).resource_path.get_base_dir().get_base_dir()
	skies = JSON.parse_string(FileAccess.get_file_as_string(dir + "/skies.json"))["skies"]
	add_child(world)
	world.add_child(we)
	sun.rotation = Vector3(-0.7, 0.6, 0)
	sun.shadow_enabled = true
	world.add_child(sun)
	world.add_child(ground)
	_stage()
	world.add_child(cam)
	cam.current = true
	cam.fov = 75
	cam.far = 800
	cam.position = Vector3(0, EYE, 6)
	_ui()
	if ResourceLoader.exists(PSX_LOOK + "psx_screen.gd"):
		psx_screen = load(PSX_LOOK + "psx_screen.gd").new()
		psx_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(psx_screen)
		move_child(psx_screen, 0)
		psx_screen.hide()  # as the pack ships: P turns it on
	else:
		psx_button.hide()
	show_sky(skies[0]["name"])


## A plain to the horizon, and on it what gives a sky its scale: houses, a line of poles, pines.
func _stage() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var dark := _mat(Color(0.13, 0.13, 0.12))
	var plain := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(600, 600)
	pm.subdivide_width = 30
	pm.subdivide_depth = 30
	plain.mesh = pm
	plain.material_override = _mat(Color(0.2, 0.2, 0.18))
	ground.add_child(plain)
	for i in 16:  # houses round the plain, a gable roof on most
		var a := TAU * i / 16.0 + rng.randf_range(-0.12, 0.12)
		var r := rng.randf_range(70, 150)
		var size := Vector3(rng.randf_range(6, 12), rng.randf_range(4, 9), rng.randf_range(6, 10))
		var house := Node3D.new()
		house.position = Vector3(sin(a) * r, 0, -cos(a) * r)
		house.rotation.y = rng.randf_range(0, TAU)
		ground.add_child(house)
		_box(house, Vector3(0, size.y / 2, 0), size, dark)
		if rng.randf() < 0.75:
			var roof := MeshInstance3D.new()
			var prism := PrismMesh.new()
			prism.size = Vector3(size.x + 0.6, size.y * 0.45, size.z + 0.6)
			roof.mesh = prism
			roof.position.y = size.y + prism.size.y / 2
			roof.material_override = dark
			house.add_child(roof)
	for i in 9:  # a line of telegraph poles, with their wires
		var p := Vector3(-48 + i * 12, 0, -14)
		_box(ground, p + Vector3(0, 4, 0), Vector3(0.25, 8, 0.25), dark)
		_box(ground, p + Vector3(0, 7.3, 0), Vector3(0.15, 0.15, 2.2), dark)
		if i < 8:
			for side in [-0.9, 0.9]:
				_box(ground, p + Vector3(6, 7.2, side), Vector3(12, 0.05, 0.05), dark)
	for i in 22:  # pines, in two stands
		var a := rng.randf_range(-0.9, 0.9) + (PI if i % 2 else 0.0)
		var r := rng.randf_range(55, 120)
		var h := rng.randf_range(6, 13)
		var pine := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = h * 0.28
		cone.height = h
		cone.radial_segments = 6
		pine.mesh = cone
		pine.position = Vector3(sin(a) * r, h / 2 + 1.2, -cos(a) * r)
		pine.material_override = dark
		ground.add_child(pine)
		_box(ground, pine.position - Vector3(0, h / 2 + 0.6, 0), Vector3(0.4, 1.2, 0.4), dark)


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 1.0
	return m


func _box(parent: Node3D, at: Vector3, size: Vector3, m: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.position = at
	mi.material_override = m
	parent.add_child(mi)
	return mi


func sky(name: String) -> Dictionary:
	for s in skies:
		if s["name"] == name:
			return s
	return {}


func environment(name: String) -> Environment:
	return load("%s/environments/%s.tres" % [dir, name])


func material(name: String, as_cube: bool) -> Material:
	return load("%s/materials/%s%s.tres" % [dir, "cube/" if as_cube else "", name])


## Puts sky `name` up: its Environment, with the cubemap or panorama material, and a light of its
## colour.
func show_sky(name: String) -> void:
	var s := sky(name)
	if s.is_empty():
		return
	index = skies.find(s)
	# the loaded one, its material swapped: a Sky made or duplicated here leaks its radiance maps
	# on Godot 4.3's Compatibility renderer
	var env := environment(name)
	env.sky.sky_material = material(name, cube)
	we.environment = env
	var c := Color(s["light"])
	sun.light_color = c
	sun.light_energy = s["light_energy"]
	_label()


func step(by: int) -> void:
	show_sky(skies[posmod(index + by, skies.size())]["name"])


## The first sky of the category `by` on from this one's.
func step_category(by: int) -> void:
	var cats := []
	for s in skies:
		if s["category"] not in cats:
			cats.append(s["category"])
	var cat: String = cats[posmod(cats.find(skies[index]["category"]) + by, cats.size())]
	for s in skies:
		if s["category"] == cat:
			show_sky(s["name"])
			return


func set_cube(on: bool) -> void:
	cube = on
	show_sky(skies[index]["name"])


func set_psx(on: bool) -> void:
	if not psx_screen:
		return
	psx_on = on
	psx_button.set_pressed_no_signal(on)
	world.get_parent().remove_child(world)
	if on:
		psx_screen.viewport.add_child(world)
	else:
		add_child(world)
	psx_screen.visible = on
	if on:
		load(PSX_LOOK + "psx.gd").convert(ground)
		load(PSX_LOOK + "psx.gd").set_param(ground, &"affine", AFFINE)


## Turns the camera to `turn` from looking down -z and tilts it `tilt`, in radians. A sky's
## painters' ahead is +z: a turn of PI.
func look(turn: float, tilt: float) -> void:
	yaw = turn
	pitch = tilt
	idle = 0.0


func _ui() -> void:
	add_child(ui)
	var words := VBoxContainer.new()
	words.position = Vector2(20, 16)
	ui.add_child(words)
	for l in [title, info]:
		l.add_theme_color_override("font_shadow_color", Color.BLACK)
		l.add_theme_constant_override("shadow_offset_x", 2)
		l.add_theme_constant_override("shadow_offset_y", 2)
		words.add_child(l)
	title.add_theme_font_size_override("font_size", 26)
	info.add_theme_font_size_override("font_size", 15)
	info.modulate = Color(0.85, 0.82, 0.75)
	var bar := HBoxContainer.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bar.position.y -= 16
	ui.add_child(bar)
	_button(bar, "<", step.bind(-1))
	_button(bar, ">", step.bind(1))
	_button(bar, "Category", step_category.bind(1))
	_button(bar, "Cube / panorama", func() -> void: set_cube(not cube))
	_button(bar, "Ground", func() -> void: ground.visible = not ground.visible)
	psx_button.text = "PSX Look"
	psx_button.toggle_mode = true
	psx_button.focus_mode = Control.FOCUS_NONE
	psx_button.toggled.connect(set_psx)
	bar.add_child(psx_button)
	var hint := Label.new()
	hint.text = "drag to look, wheel to zoom\nleft / right: sky, up / down: category\nC: cube / panorama, G: ground, P: PSX Look"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.add_theme_font_size_override("font_size", 13)
	hint.modulate = Color(1, 1, 1, 0.55)
	hint.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	hint.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hint.position += Vector2(-16, 16)
	ui.add_child(hint)
	ui.visible = not still


func _button(box: Container, text: String, pressed: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size.x = 44
	b.pressed.connect(pressed)
	box.add_child(b)


func _label() -> void:
	var s: Dictionary = skies[index]
	title.text = s["name"].replace("_", " ").capitalize()
	info.text = "%s  |  %d of %d  |  %s" % [s["category"], index + 1, skies.size(), "cubemap" if cube else "panorama"]


func _process(delta: float) -> void:
	idle += delta
	if not still and idle > 4.0:
		yaw -= delta * 0.08
	pitch = clampf(pitch, -1.4, 1.5)
	cam.rotation = Vector3(pitch, yaw, 0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		yaw -= event.relative.x * 0.006
		pitch -= event.relative.y * 0.006
		idle = 0.0
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam.fov = clampf(cam.fov - 4, 30, 100)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam.fov = clampf(cam.fov + 4, 30, 100)
	elif event is InputEventKey and event.pressed:
		idle = 0.0
		match event.keycode:
			KEY_LEFT:
				step(-1)
			KEY_RIGHT:
				step(1)
			KEY_UP:
				step_category(-1)
			KEY_DOWN:
				step_category(1)
			KEY_C:
				if not event.echo:
					set_cube(not cube)
			KEY_G:
				if not event.echo:
					ground.visible = not ground.visible
			KEY_P:
				if not event.echo:
					set_psx(not psx_on)
