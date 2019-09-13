extends Node

var Polygon = preload("res://src/PolygonCreator/Polygon.gd")
var Grid = preload("res://src/PolygonCreator/Grid.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(camera())
	add_child(Grid.new().create())
	add_child(Polygon.new().create())

func camera():
	var camera = Camera.new()
	camera.name = "Camera"
	camera.translate(Vector3(0,0,10))
	return camera
		
