extends Node2D

@onready var player = $Player

const LOAD_TRANSITION_SPEED = 0.2

func _ready():
	player.death.connect(_on_player_death)
	
func _on_player_death():
	# Level restart animation
	# If we're gonna have a special loader, we can switch to an instanced scene for the loading screen
	
	var fade_in = get_tree().create_tween()
	$CanvasLayer/ColorRect.color = Color(0,0,0,0)
	fade_in.tween_property($CanvasLayer/ColorRect, "color", Color(0,0,0,1), LOAD_TRANSITION_SPEED)
	await fade_in.finished
	fade_in.kill()

	player.position = Vector2(0,0)
	player.get_node("Camera2D").reset_smoothing()
	
	var fade_out = get_tree().create_tween()
	$CanvasLayer/ColorRect.color = Color(0,0,0,1)
	fade_out.tween_property($CanvasLayer/ColorRect, "color", Color(0,0,0,0), LOAD_TRANSITION_SPEED)
	await fade_out.finished
	fade_out.kill()
