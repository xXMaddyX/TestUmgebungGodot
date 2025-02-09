extends Node2D

@onready var player = $Player

const CAMERA_TOP_LIMIT = 0
const CAMERA_LEFT_LIMIT = 0
const CAMERA_RIGHT_LIMIT = 2350
const CAMERA_BOTTOM_LIMIT = 540
# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("setCameraBorders")

func setCameraBorders():
	player.setCameraBorders(CAMERA_LEFT_LIMIT, CAMERA_TOP_LIMIT, CAMERA_BOTTOM_LIMIT, CAMERA_RIGHT_LIMIT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
