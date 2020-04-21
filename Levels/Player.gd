class_name Player
extends KinematicBody2D

const GRAVITY = 10
const MAX_UP_SPEED = 10
const MAX_X_SPEED = 20
const Impact = preload("res://Impact.tscn")

onready var animation_player = $Drone/AnimationPlayer
onready var drone = $Drone
onready var drone_collision = $CollisionPolygon2D
onready var bottom_Cast = $BottomCast
onready var force_label = $GUI/Force
onready var life_label = $GUI/Life

export (float) var rotation_speed = 4
var force = 0
var velocity = Vector2()
var rotation_dir = 0
var rotation_friction = false
var life = 100
var initial_position = Vector2()

func _ready():
	rotation_degrees = 0
	position = global_position
	initial_position = global_position
	_restart()
	
func _life_change(value):
	life = max(0, life - value)
	life_label.text = "LIFE: " + String(ceil(life))
	
func _restart():
	position = initial_position
	life = 100
	_life_change(0)
	rotation_dir = 0
	velocity = Vector2()
	force = 0
	$Drone.visible = true
	$CollisionPolygon2D.disabled = false

func get_input():
	if Input.is_action_just_pressed("restart"):
		_restart()
		
	if life == 0:
		return
	
	#var friction = false
	
	var dpad_left = Input.is_action_pressed("ui_left")
	var dpad_right = Input.is_action_pressed("ui_right")
	var dpad_up  = Input.is_action_pressed("ui_up")
	var dpad_down = Input.is_action_pressed("ui_down")
	
	if dpad_up:
		force -= 100
	elif dpad_down:
		force += 100
	#else:
		#friction = true
	
	force = clamp(force, -10000, 0)
	force_label.text = "RPM: " + String(abs(force))

	if not (bottom_Cast.is_colliding() and force == 0):
		if dpad_left:
			rotation_friction = false
			rotation_dir = fmod(rotation_dir - rotation_speed, 360)
		elif dpad_right:
			rotation_friction = false
			rotation_dir = fmod(rotation_dir + rotation_speed, 360)
		else:
			rotation_friction = true


func sparks(collision):
	var impact = Impact.instance()
	var angle = position.angle_to_point(collision.position)
	var direction = Vector2(cos(angle), sin(angle))

	impact.global_position = collision.position - Vector2(10,10)
	impact.particle_direction = direction
	get_parent().add_child(impact)

func get_animation():
	var animation = "drone"
	
	if life == 0:
		animation = "dead"
	elif force == 0:
		animation = "idle"
	
	if animation != animation_player.current_animation:
		animation_player.play(animation)
		

func get_velocity(delta):
	var a = deg2rad(rotation_dir)
	var direction = Vector2(-sin(a), cos(a)) * (force / 500)

	velocity += direction * delta

	if not bottom_Cast.is_colliding():
		velocity.y += (GRAVITY * delta)
	else:
		velocity.x = lerp(velocity.x, 0, 0.1)
	

	if force != 0 and abs(rotation_dir) < 90 and rotation_friction:
		rotation_dir = lerp(rotation_dir, 0, 0.02)
		if abs(rotation_dir) < 10:
			velocity.x = lerp(velocity.x, 0, 0.02)

	velocity.x = clamp(velocity.x, -MAX_X_SPEED, MAX_X_SPEED)
	velocity.y = clamp(velocity.y, -MAX_UP_SPEED, MAX_UP_SPEED * 2)
	
	var collision = move_and_collide(velocity)
	
	if collision:
		var hit = velocity.length()
		
		if hit < 2.0:
			return collision
		
		var reflect = collision.remainder.bounce(collision.normal)
		velocity = velocity.bounce(collision.normal) * 0.3
		move_and_collide(reflect)
		sparks(collision)
		_life_change(hit)

	return collision

func _physics_process(delta):
	get_input()
	get_animation()

	if life == 0:
		return
	
	# ROTATE DRONE AND COLLIDER
	drone.rotation = deg2rad(rotation_dir)
	drone_collision.rotation = deg2rad(rotation_dir)
		
	get_velocity(delta)

func _dead():
	$Drone.visible = false
	$CollisionPolygon2D.disabled = true











