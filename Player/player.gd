extends KinematicBody

export var speed = 5#5
export var acceleration = 10
export var friction = 25
export var gravity = 0.98

onready var camera = $Camera
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var ground_raycast = $GroundCast
onready var timer: = $Timer

var velocity = Vector3()
var is_grounded = false
var till_cooldown = 0.3
var can_till = true

#Slope variables
const MAX_SLOPE_ANGLE = 35

func _ready():
	timer.connect("timeout", self, "_update_till")

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Unlocks mouse when esc is clicked

func _physics_process(delta):	
	var direction = _get_input_axis()
	_update_grounded()
	
	# While touching the ground out player will not continue to fall.
	# Prevents camera stuttering when player walks to the edge of a tile
	if !is_grounded:
		velocity.y -= gravity #turns on gravity
	
	#velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	if  can_till:
		if direction != Vector3.ZERO:	# When moving
			var treeVector = Vector2(direction.x ,direction.z)
			animationTree.set("parameters/Idle/blend_position", treeVector)
			animationTree.set("parameters/Walk/blend_position", treeVector)
			animationState.travel("Walk")
			velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
		else:							#Not moving
			animationState.travel("Idle")
			velocity = velocity.linear_interpolate(Vector3.ZERO, friction * delta)
		
		velocity = move_and_slide(velocity, Vector3.UP, true, 4, 0.785398)


func _get_input_axis():
	var axis = Vector3.ZERO
	axis.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_foward")
	axis.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	return axis.normalized() #Cuts off value at one so player doesn't move faster diagonally

func _update_grounded():
	# Make sure we have the latest raycast data
	ground_raycast.force_raycast_update()
	# Update the is_grounded variable
	is_grounded = ground_raycast.is_colliding()

func _update_till():
	can_till = true

func till(block_position):
	if can_till:
		can_till = false
		animationTree.set("parameters/Idle/blend_position", block_position)
		animationTree.set("parameters/Tool/blend_position", block_position)
		animationState.travel("Tool")
		timer.set_wait_time(till_cooldown)
		timer.start()
		return true
	else:
		return false

