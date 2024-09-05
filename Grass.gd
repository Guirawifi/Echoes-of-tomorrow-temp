extends TileMap

var wait_time = Time.get_unix_time_from_system() + randi_range(1, 3)*1.2
var animating = false
var time = Time.get_unix_time_from_system()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_layer_enabled(1, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#time = Time.get_unix_time_from_system()
	#if time >= wait_time and not animating:
		#wait_time = time + 0.8
		#set_layer_enabled(1, false)
		#set_layer_enabled(0, true)
		#animating = true
	#if animating and time >= wait_time:
		#animating = false
		#set_layer_enabled(1, true)
		#set_layer_enabled(0, false)
		#wait_time = time + randi_range(1, 3)*1.2
		#print((wait_time - time)/1.2)
	return
