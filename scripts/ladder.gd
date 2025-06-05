extends Area2D

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("set_on_ladder"):
		body.set_on_ladder(true)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("set_on_ladder"):
		body.set_on_ladder(false)
