extends Node
# Reference to our visual elements
var label: Label
var panel: Panel
var timer: Timer
var game_hud = null

func _ready():
	print("NotificationManager initialized")
	
	
	# Create a CanvasLayer to ensure UI is on top
	var canvas = CanvasLayer.new()
	canvas.layer = 50 
	add_child(canvas)
	
	# Create a Control node to hold our UI
	var control = Control.new()
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(control)
	
	# Create a Panel for the background - INCREASED SIZE
	panel = Panel.new()
	panel.position.y = 50
	panel.size.y = 80  # Increased height from 50 to 80
	panel.size.x = 500  # Increased width from 300 to 500
	
	# Center horizontally
	panel.position.x = (get_viewport().get_visible_rect().size.x - panel.size.x) / 2
	
	control.add_child(panel)
	
	# Create the Label
	label = Label.new()
	label.position = Vector2(10, 10)  # Add some padding
	label.size = Vector2(panel.size.x - 20, panel.size.y - 20)  # Account for padding
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # Enable word wrapping
	panel.add_child(label)
	
	# Create a Timer
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	
	# Initially hide the notification
	panel.visible = false
	
	# Connect to window resize to keep centered
	get_viewport().size_changed.connect(self._on_viewport_size_changed)
	
	

func _on_viewport_size_changed():
	# Keep the panel centered when window resizes
	panel.position.x = (get_viewport().get_visible_rect().size.x - panel.size.x) / 2
	
	

func register_hud(hud_instance):
	game_hud = hud_instance

# Modify your show_notification function
func show_notification(message, duration = 5.0):
	print("Showing notification: " + message)

	# If HUD is registered, use it instead
	if game_hud != null and game_hud.has_method("show_notification"):
		game_hud.show_notification(message, duration)
		return

	# Otherwise use the original functionality
	# Set the text
	label.text = message

	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Show the notification
	panel.visible = true

	# Start the timer to hide it
	if timer.is_stopped() == false:
		timer.stop()
	timer.start(duration)

	# Connect the timeout signal
	if not timer.timeout.is_connected(self._on_timer_timeout):
		timer.timeout.connect(self._on_timer_timeout)

func _on_timer_timeout():
	# Hide the notification
	panel.visible = false
