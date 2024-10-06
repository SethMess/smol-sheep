extends Node2D

@onready var sheep_scene = load("res://sheep.tscn")  # Drag and drop `Sheep.tscn` here in the Inspector
@export var spawn_count: int = 50  # Number of sheep to spawn
@export var spawn_area_size: Vector2 = Vector2(1000, 1000)  # Define the spawn area dimensions

func _ready():
	spawn_sheep()

func spawn_sheep():
	for i in range(spawn_count):
		var sheep_instance = sheep_scene.instantiate()
		
		# Set a random position within the spawn area
		var random_x = randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
		var random_y = randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
		sheep_instance.position = Vector2(random_x, random_y)
		
		# Add the sheep instance to the scene
		#add_child(sheep_instance)
		get_parent().add_child.call_deferred(sheep_instance)
