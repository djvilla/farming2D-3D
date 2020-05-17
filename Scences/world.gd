extends Spatial

const CAMERA_RAY_LENGTH = 1000
const MOUSE_HOVER_Y_OFFSET = Vector3(0, .01, 0)
const MOUSE_CLICK_EFFECT_Y_OFFSET = Vector3(0, .8, 0)

onready var camera := $Player/Camera
onready var player := $Player
onready var gridMap := $GridMap
onready var mouseHover := $MouseHover
onready var clickEffect := $TillEffect
onready var particles := $TillEffect/TillParticle
onready var groundLibary := preload("res://Resources/MeshLibrary/GroundLibrary.meshlib")

# Array for raycast to ignore
var selection_ignore = []

func _ready():
	# Add objects that must be ignored to the array
	selection_ignore = [player]

func _input(event: InputEvent):
	_handle_mouse_click(event)
	_handle_mouse_move(event)


func _handle_mouse_click(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	
	var m_position = _get_mouse_projected_position(event.position)
	if m_position:
		#var world_position = Vector3(m_position.x, m_position.y, m_position.z)
		var grid_position = gridMap.world_to_map(m_position)
		var selected_cell = gridMap.get_cell_item(grid_position.x, grid_position.y, grid_position.z)
		
		# Disables the user from placing a tile next to another existing tile
		if selected_cell != gridMap.INVALID_CELL_ITEM:
			#Get the items name
			var choosenBlock = groundLibary.get_item_name(selected_cell)
			# Logic for choosen block
			_handle_block(m_position, grid_position, choosenBlock)
		
		# Uncomment this and comment the select cell conditional above to build tiles in game
		#gridMap.set_cell_item(grid_position.x, grid_position.y, grid_position.z, -1)

func _handle_block(mpos: Vector3, itemPos: Vector3, block_name: String):
	match block_name:
		"Dirt_Block":
			# Till effect
			_play_effect_at_click(mpos)
			# Change block type
			gridMap.set_cell_item(itemPos.x, itemPos.y, itemPos.z, groundLibary.find_item_by_name("Mud_block"))


func _play_effect_at_click(pos: Vector3):
	clickEffect.set_translation(gridMap.get_map_cell_center(pos) + MOUSE_CLICK_EFFECT_Y_OFFSET)
	particles.set_emitting(true)


func _handle_mouse_move(event: InputEvent):
	if not event is InputEventMouseMotion:
		return
	var m_position = _get_mouse_projected_position(event.position)
	if m_position:
		_move_mouse_hover(m_position)


func _move_mouse_hover(pos: Vector3):
	mouseHover.translation = gridMap.get_map_cell_center(pos) + MOUSE_HOVER_Y_OFFSET


func _get_mouse_projected_position(screen_position: Vector2):
	
	
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * CAMERA_RAY_LENGTH
	var space_state = camera.get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, selection_ignore, 1)
	
	if not result:
		return null
	return result.position

