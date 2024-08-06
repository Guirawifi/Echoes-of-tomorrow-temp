extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _ready():
	DiscordRPC.app_id = 1270324608859635824
	DiscordRPC.details = "In the menu"
	DiscordRPC.state = "So many options ;-;"
	DiscordRPC.large_image = "capture_of_the_game"
	DiscordRPC.small_image = "dinssons"
	DiscordRPC.large_image_text = "I know it look nice"
	DiscordRPC.small_image_text = "He's better than you"
	#DiscordRPC.current_party_size = 1
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	
	DiscordRPC.refresh()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://main.tscn")


func _on_option_pressed():
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit()
