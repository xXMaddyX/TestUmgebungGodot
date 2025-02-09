extends Node2D
@onready var animation_player = $AnimationPlayer

var bridgeClosed = false
var leverPulled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _on_lever_trigger_body_entered(body):
	if body and !bridgeClosed:
		animation_player.play("LeverActivate")
		bridgeClosed = true


func _on_animation_player_animation_finished(anim_name):
	if !leverPulled:
		animation_player.play("BridgeClose")
		leverPulled = true
