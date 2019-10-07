extends HBoxContainer

func _init():
	name = "UI"
	add_child(RotateButton.new("Left"))
	add_child(RotateButton.new("Right"))
	add_child(RotateButton.new("Up"))
	add_child(RotateButton.new("Down"))
	add_child(FaceLabel.new())
	add_child(DeleteButton.new())
	
class RotateButton extends Button:
	var Polygon
	
	func _init(direction):
		text = direction
		disabled = true
		connect("pressed", self, "onClick" + direction)
		
	func _ready():
		get_node("/root/Main").connect("polygon_created", self, "onPolygonCreate")
		
	func onPolygonCreate():
		Polygon = get_node("/root/Main/Polygon")
		get_node("/root/Main").disconnect("polygon_created", self, "onPolygonCreate")
		Polygon.connect("polygon_face_changed", self, "onFaceChange")
		disabled = false
		
	func onClickLeft():
		Polygon.clearPendingVertices()
		Polygon.rotate(Vector3(0, 1, 0), PI/2)
		if Polygon.currentFace != 0:
			Polygon.changeFace(Polygon.currentFace - 1)
		else:
			Polygon.changeFace(3)
			
	func onClickRight():
		Polygon.clearPendingVertices()
		Polygon.rotate(Vector3(0, 1, 0), -PI/2)
		if Polygon.currentFace != 3:
			Polygon.changeFace(Polygon.currentFace + 1)
		else:
			Polygon.changeFace(0)
			
	func onClickUp():
		Polygon.clearPendingVertices()
		if Polygon.currentFace == 1 or Polygon.currentFace == 2 or Polygon.currentFace == 3:
			var radians = 2 * PI * (1 - float(Polygon.currentFace)/4)
			Polygon.rotate(Vector3(0, 1, 0), -radians)
		Polygon.rotate(Vector3(1, 0, 0), PI/2)
		if Polygon.currentFace == 5:
			Polygon.changeFace(0)
		else:
			Polygon.changeFace(4)
			
	func onClickDown():
		Polygon.clearPendingVertices()
		if Polygon.currentFace == 1 or Polygon.currentFace == 2 or Polygon.currentFace == 3:
			var radians = 2 * PI * (1 - float(Polygon.currentFace)/4)
			Polygon.rotate(Vector3(0, 1, 0), -radians)
		Polygon.rotate(Vector3(1, 0, 0), -PI/2)
		if Polygon.currentFace == 4:
			Polygon.changeFace(0)
		else:
			Polygon.changeFace(5)
			
	func onFaceChange():
		match Polygon.currentFace:
			4:
				if(text == "Left" or text == "Right" or text == "Up"):
					disabled = true
			5:
				if(text == "Left" or text == "Right" or text == "Down"):
					disabled = true
			_:
				disabled = false
				
class FaceLabel extends Label:
	var Polygon
	
	func _ready():
		get_node("/root/Main").connect("polygon_created", self, "onPolygonCreate")
		
	func onPolygonCreate():
		Polygon = get_node("/root/Main/Polygon")
		get_node("/root/Main").disconnect("polygon_created", self, "onPolygonCreate")
		Polygon.connect("polygon_face_changed", self, "onFaceChange")
		text = String(Polygon.currentFace)
		
	func onFaceChange():
		text = String(Polygon.currentFace)
		
class DeleteButton extends Button:
	var Polygon
	
	func _init():
		name = "DeleteButton"
		text = "Delete"
		disabled = true
		connect("pressed", self, "onClick")
	
	func _ready():
		get_node("/root/Main").connect("polygon_created", self, "onPolygonCreate")
		
	func onClick():
		print("DELETING TOGGLED TRIANGLES...")
		for i in range(Polygon.toggledTriangles.size()):
			Polygon.toggledTriangles[0].queue_free()
			Polygon.toggledTriangles.remove(0)
		disabled = true
		
	func onPolygonCreate():
		Polygon = get_node("/root/Main/Polygon")
		get_node("/root/Main").disconnect("polygon_created", self, "onPolygonCreate")