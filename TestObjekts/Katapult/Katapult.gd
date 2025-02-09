extends Node2D

@onready var animation_player = $AnimationPlayer
var isFired: bool = false
var initialVelocity = 200
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fireCatapult():
	animation_player.play("throw")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_trigger_area_body_entered(body):
	if body and !isFired:
		fireCatapult()
		isFired = true
		if body.has_method("getThrown"):
			body.getThrown(initialVelocity)
