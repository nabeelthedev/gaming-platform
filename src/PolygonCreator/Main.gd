extends Node

const Polygon = preload("res://src/PolygonCreator/Polygon.gd")
const Grid = preload("res://src/PolygonCreator/Grid.gd")
const UI = preload("res://src/PolygonCreator/UI.gd")

signal polygon_created

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(camera())
	add_child(UI.new())
	add_child(Polygon.new())
#	emit_signal("polygon_created")
	add_child(Grid.new())

func camera():
	var camera = Camera.new()
	camera.name = "Camera"
	camera.translate(Vector3(0,0,0))
	return camera
		
