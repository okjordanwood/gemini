extends Node

var light_sources: Array = []
var light_receivers: Array = []

func _ready():
	# Automatically find light sources and receivers in the scene
	# Populate light_sources with instances of light_source
	light_sources = get_tree().get_nodes_in_group("light_sources")
	light_receivers = get_tree().get_nodes_in_group("light_receivers")

func	 _process(delta):
	process_light_interactions()

func process_light_interactions():
	for source in light_sources:
		if source:  # Ensure source is valid
			var intersection = source.get_beam_intersection()
			if not intersection.is_empty():
				for receiver in light_receivers:
					if intersection["object"] == receiver:
						receiver.receive_light(
							intersection["color"], 
							intersection["intensity"]
						)

func add_light_source(source):
	if not source in light_sources:
		light_sources.append(source)
		source.add_to_group("light_sources")

func add_light_receiver(receiver):
	if not receiver in light_receivers:
		light_receivers.append(receiver)
		receiver.add_to_group("light_receivers")
