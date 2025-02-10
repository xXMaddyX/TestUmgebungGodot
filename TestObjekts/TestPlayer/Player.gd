extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const ARROW = preload("res://TestObjekts/TestPlayer/arrow/Arrow.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var idle = $PlayerAnims/Idle
@onready var run = $PlayerAnims/Run
@onready var jump_up = $PlayerAnims/JumpUp
@onready var jump_mid = $PlayerAnims/JumpMid
@onready var jump_down = $PlayerAnims/JumpDown
@onready var shot_in_air = $PlayerAnims/ShotInAir

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
			newArrow.setDirection(shootDirection, false)
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
	
enum ANIM_STATE {
	UP,
	MID,
	DOWN,
	SHOOT,
}
var currentState = null
func animJumpState(newState):
	idle.hide()
	run.hide()
	if newState == ANIM_STATE.UP:
		jump_up.show()
		jump_up.play("default")
		
	elif newState == ANIM_STATE.MID:
		jump_mid.show()
		jump_up.hide()
		jump_down.hide()
		jump_mid.play("default")
		
	elif newState == ANIM_STATE.DOWN:
		jump_mid.hide()
		jump_down.show()
		jump_down.play("default")
		
	elif newState == ANIM_STATE.SHOOT:
		jumpHide()
		if !isInAirShoot:
			shot_in_air.show()
			shot_in_air.frame = 0
			shot_in_air.play("default")
			isInAirShoot = true
		if isInAirShoot:
			if shot_in_air.frame == 7 and !arrowAirShot:
				arrowAirShot = true
				var newArrow = ARROW.instantiate()
				newArrow.setDirection(shootDirection, true)
				newArrow.global_position = Vector2(global_position.x + (shootDirection * 10), global_position.y + 35)
				get_tree().current_scene.add_child(newArrow)
				
			if shot_in_air.frame == 9:
				inAirShoot = false
				isInAirShoot = false
				arrowAirShot = false
				shot_in_air.hide()
				shot_in_air.frame = 0
		
	else: idle.show(); idle.play("default")
	
var inJump:bool = false
var inAirShoot = false
var isInAirShoot = false
var arrowAirShot = false
func jumpAnimHandler():
	if Input.is_action_just_pressed("shoot") and !inAirShoot:
		inAirShoot = true
		
	if velocity.y < -100 and !inAirShoot:
		animJumpState(ANIM_STATE.UP)
	elif velocity.y < 0 and velocity.y > -100 and !inAirShoot:
		animJumpState(ANIM_STATE.MID)
	elif velocity.y > 0 and !inAirShoot:
		animJumpState(ANIM_STATE.DOWN)
	elif inAirShoot:
		animJumpState(ANIM_STATE.SHOOT)
		velocity.y = 0
		
	
func moveHandler():
	if Input.is_action_pressed("move-right") and !isShooting and !isInAirShoot:
		direction = 1
	elif Input.is_action_pressed("move-left") and !isShooting and !isInAirShoot:
		direction = -1
	elif Input.is_action_just_pressed("shoot") and !inAir:
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
		
func jumpHide():
	jump_up.hide()
	jump_up.frame = 0
	jump_mid.hide()
	jump_mid.frame = 0
	jump_down.hide()
	jump_down.frame = 0

var inAir = false
func _physics_process(delta):
	if not is_on_floor():
		if !inAirShoot:
			velocity.y += gravity * delta
		inAir = true
	else: inAir = false
	flipHandler()
	resetCharacter()
	
	if !isThrown:
		moveHandler()
	if isThrown:
		handelThrow(delta)
	if !inAir:
		jumpHide()
		animationHandler()
	elif inAir:
		jumpAnimHandler()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !isShooting:
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collition = get_slide_collision(i)
		if collition.get_collider() is RigidBody2D:
			collition.get_collider().apply_central_impulse(-collition.get_normal() * pushForce)
