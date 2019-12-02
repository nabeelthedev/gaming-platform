extends Node

const Canvas = preload("res://src/PolygonCreator/Canvas.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(camera())
	add_child(Canvas.new())

func camera():
	var camera = Camera.new()
	camera.name = "Camera"
	camera.translate(Vector3(0,0,0))
	return camera
		
