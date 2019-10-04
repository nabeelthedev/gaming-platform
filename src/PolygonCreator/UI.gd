extends HBoxContainer
var L = LeftB()
var R = RightB()
var U = UpB()
var D = DownB()
var delete = DeleteB()
var Polygon
var FL = FaceLabel()

func _ready():
	name = "UI"
	get_parent().connect("polygon_created", self, "onPolygonCreated")
	add_child(L)
	add_child(R)
	add_child(U)
	add_child(D)
	add_child(FL)
	add_child(delete)
	return self
			
func LeftB():
	var button = Button.new()
	button.text = "Left"
	button.connect("pressed", self, "onClickLeftB")
	return button

func onClickLeftB():
	Polygon.clearPendingVertices()
	Polygon.rotate(Vector3(0, 1, 0), PI/2)
	if Polygon.currentFace != 0:
		Polygon.changeFace(Polygon.currentFace - 1)
	else:
		Polygon.changeFace(3)
			
func RightB():
	var button = Button.new()
	button.text = "Right"
	button.connect("pressed", self, "onClickRightB")
	return button

func onClickRightB():
	Polygon.clearPendingVertices()
	Polygon.rotate(Vector3(0, 1, 0), -PI/2)
	if Polygon.currentFace != 3:
		Polygon.changeFace(Polygon.currentFace + 1)
	else:
		Polygon.changeFace(0)
			
func UpB():
	var button = Button.new()
	button.text = "Up"
	button.connect("pressed", self, "onClickUpB")
	return button
	
func onClickUpB():
	Polygon.clearPendingVertices()
	if Polygon.currentFace == 1 or Polygon.currentFace == 2 or Polygon.currentFace == 3:
		var radians = 2 * PI * (1 - float(Polygon.currentFace)/4)
		Polygon.rotate(Vector3(0, 1, 0), -radians)
	Polygon.rotate(Vector3(1, 0, 0), PI/2)
	if Polygon.currentFace == 5:
		Polygon.changeFace(0)
		L.disabled = false
		R.disabled = false
		D.disabled = false
	else:
		Polygon.changeFace(4)
		U.disabled = true
		L.disabled = true
		R.disabled = true
			
func DownB():
	var button = Button.new()
	button.text = "Down"
	button.connect("pressed", self, "onClickDownB")
	return button

func onClickDownB():
	Polygon.clearPendingVertices()
	if Polygon.currentFace == 1 or Polygon.currentFace == 2 or Polygon.currentFace == 3:
		var radians = 2 * PI * (1 - float(Polygon.currentFace)/4)
		Polygon.rotate(Vector3(0, 1, 0), -radians)
	Polygon.rotate(Vector3(1, 0, 0), -PI/2)
	if Polygon.currentFace == 4:
		Polygon.changeFace(0)
		U.disabled = false
		L.disabled = false
		R.disabled = false
	else:
		Polygon.changeFace(5)
		D.disabled = true
		L.disabled = true
		R.disabled = true
			
func FaceLabel():
	var label = Label.new()
	return label
		
func onPolygonCreated():
	Polygon = get_node("/root/Main/Polygon")
	Polygon.connect("polygon_face_changed", self, "onFaceChange")
	FL.text = String(Polygon.currentFace)
	
func onFaceChange():
	FL.text = String(Polygon.currentFace)
	
func DeleteB():
	var button = Button.new()
	button.name = "DeleteButton"
	button.text = "Delete"
	button.disabled = true
	button.connect("pressed", self, "onClickDeleteB")
	return button
	
func onClickDeleteB():
	var Polygon = get_node("/root/Main/Polygon")
	print("DELETING TOGGLED TRIANGLES...")
	for i in range(Polygon.toggledTriangles.size()):
		Polygon.toggledTriangles[0].queue_free()
		Polygon.toggledTriangles.remove(0)
	self.get_node("DeleteButton").disabled = true
	return true