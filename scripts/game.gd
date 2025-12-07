extends Node

@export var star_scene : PackedScene

const SCROLL_SPEED : int = 1
const STAR_DELAY : int = 50
const STAR_RANGE : int = 200

var game_running : bool
var game_over : bool
var scroll
var score
var ground_height : int

var screen_size : Vector2i
var stars : Array

var base_height := 720  # la altura original de tu juego (cámbiala si es otra)ç
var scale_y


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	scale_y = screen_size.y / base_height
	ground_height = $Floor/Ground.get_node("Floor").texture.get_height()
	new_game()


func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	stars.clear()
	get_tree().call_group("stars", "queue_free")
	$GameOver.hide()
	$ScoreLabel.text = str(score)
	$Background.autoscroll = Vector2(0,0)
	$Floor.autoscroll = Vector2(0,0)
	$Bunny.reset()
	generate_stars()
	

func _input(event) -> void:
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bunny.jumping:
						$Bunny.hop()
						check_top()

func start_game():
	game_running = true
	$Bunny.jumping = true
	$Bunny.hop()
	$StarTimer.start()
	$Background.autoscroll = Vector2(-100,0)
	$Floor.autoscroll = Vector2(-200,0)
	
func _process(delta: float) -> void:
	if game_running:
		for star in stars:
			star.position.x -= SCROLL_SPEED
		
		
func _on_star_timer_timeout() -> void:
	generate_stars()

func generate_stars():
	var star = star_scene.instantiate()
	star.position.x = screen_size.x + STAR_DELAY
	
	var mid_y = (screen_size.y - ground_height) / 2
	var range_scaled = STAR_RANGE * scale_y
	
	star.position.y = mid_y + randi_range(-range_scaled, range_scaled)
	
	star.hit.connect(bunny_hit)
	star.scored.connect(scored)
	
	add_child(star)
	stars.append(star)

func check_top():
	if $Bunny.position.y < 0:
		$Bunny.falling = true
		stop_game()


func stop_game():
	$StarTimer.stop()
	$Bunny.jumping = false
	game_running = false
	game_over = true
	$Background.autoscroll = Vector2(0,0)
	$Floor.autoscroll = Vector2(0,0)
	$GameOver.show()


func _on_ground_hit() -> void:
	$Bunny.falling = false
	SoundPlayer.play_sound(SoundPlayer.LOOSE)
	stop_game()

func bunny_hit():
	stop_game()
	$Bunny.falling = true

func scored():
	score += 1
	$ScoreLabel.text = str(score)
	SoundPlayer.play_sound(SoundPlayer.POINT)


func _on_game_over_restart() -> void:
	new_game()
