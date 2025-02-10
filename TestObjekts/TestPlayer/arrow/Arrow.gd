extends CharacterBody2D

const SPEED = 10.0
var direction = 0
var isCollidet = false
var drag = 0.8
var pushForce = 100
var isInAir = true
var rotationForce = 0.08

var isShotFromAir = false

@onready var arrow_sprite = $ArrowSprite
@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	pass
	
func setDirection(directionIn, shotFromAir):
	direction = directionIn
	isShotFromAir = shotFromAir
	
func stopAfterCollide():
	velocity = Vector2(0, 0)

func flipHandler():
	if velocity.x > 0:
		arrow_sprite.flip_h = false
	elif velocity.x < 0:
		arrow_sprite.flip_h = true

func moveHandler(delta):
	velocity = Vector2(direction * SPEED, velocity.y + drag * delta)
	if velocity.x > 0:
		rotation = rotation + delta * rotationForce
	elif velocity.x < 0:
		rotation = rotation - delta * rotationForce
		
func isAirShotHandler(delta):
	if direction == 1:
		velocity.x = direction * SPEED / 1.2
		rotation_degrees = +45
	elif direction == -1:
		velocity.x = direction * SPEED / 1.2
		rotation_degrees = -45
	velocity.y = SPEED / 1.2
		
func reparentArrow(body, position: Vector2):
	global_position = position
	reparent(body)
	velocity = Vector2.ZERO
	collision_shape_2d.set_deferred("disabled", true)
	await get_tree().create_timer(10).timeout
	queue_free()

func _physics_process(delta):
	if isInAir:
		if !isShotFromAir:
			moveHandler(delta)
		if isShotFromAir:
			isAirShotHandler(delta)
			
	flipHandler()
	if !isCollidet:
		var collider = move_and_collide(velocity)
		if collider:
			if collider.get_collider() is RigidBody2D:
				collider.get_collider().apply_central_impulse(-collider.get_normal() * pushForce)
			var hit_body = collider.get_collider()
			reparentArrow(hit_body, collider.get_position())
			stopAfterCollide()
			isInAir = false
			isCollidet = true
