extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ARROW = preload("res://TestObjekts/TestPlayer/arrow/Arrow.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var idle = $PlayerAnims/Idle
@onready var run = $PlayerAnims/Run
@onready var player_anims = $PlayerAnims
@onready var shoot = $PlayerAnims/Shoot
@onready var camera_2d = $Camera2D

var direction: int = 0
var shootDirection: int = 1
var isShooting: bool = false
var arrowfired: bool = false
var isThrown: bool = false
var pushForce = 50.0

func _ready():
	idle.play("default")
	
func setCameraBorders(left, top, bottom, right):
	camera_2d.limit_left = left
	camera_2d.limit_right = right
	camera_2d.limit_bottom = bottom
	camera_2d.limit_top = top

func animationHandler():
	if velocity.x > 0 or velocity.x < 0 and !isShooting:
		idle.stop()
		idle.hide()
		run.show()
		run.play("default")
		
	elif velocity.x == 0 and !isShooting:
		run.stop()
		run.hide()
		idle.show()
		idle.play("default")
		
	elif isShooting:
		run.stop()
		idle.stop()
		idle.hide()
		run.hide()
		shoot.show()
		shoot.play("default")
		if shoot.frame == 8 and !arrowfired:
			arrowfired = true
			var newArrow = ARROW.instantiate()
			newArrow.setDirection(shootDirection)
			newArrow.global_position = Vector2(global_position.x, global_position.y + 35)
			
			get_tree().current_scene.add_child(newArrow)
			pass
		if shoot.frame == 14:
			shoot.frame = 0
			shoot.stop()
			shoot.hide()
			idle.show()
			isShooting = false
			arrowfired = false
	
func shootArrow():
	pass
	
func getThrown(initialVelocity):
	isThrown = true
	velocity.x = initialVelocity
	
func moveHandler():
	if Input.is_action_pressed("move-right") and !isShooting:
		direction = 1
	elif Input.is_action_pressed("move-left") and !isShooting:
		direction = -1
	elif Input.is_action_just_pressed("shoot"):
		isShooting = true
		direction = 0
	else: direction = 0
	velocity.x = direction * SPEED

func flipHandler():
	if direction == 1:
		shootDirection = 1
		player_anims.scale.x = 1 
	elif direction == -1:
		shootDirection = -1
		player_anims.scale.x = -1
		
func handelThrow(delta):
	velocity.x = lerp(velocity.x, 0.0, delta)
	if velocity.x < 5.0:
		isThrown = false
		
func resetCharacter():
	if global_position.y > 1300:
		get_tree().reload_current_scene()

func _physics_process(delta):
	resetCharacter()
	if !isThrown:
		moveHandler()
		
	if isThrown:
		handelThrow(delta)
		
	animationHandler()
	flipHandler()
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collition = get_slide_collision(i)
		if collition.get_collider() is RigidBody2D:
			collition.get_collider().apply_central_impulse(-collition.get_normal() * pushForce)
