extends StaticBody

const gridSize = 10
const zOffset = .001
var leftClicked = false
const Polygon = preload("res://src/PolygonCreator/Polygon.gd")
var currentPolygon

func _init():
	name = "Canvas"
	drawCanvasLines()
	connect("input_event", self, "onClick")
	connect("input_event", self, "onMove")
	connect("mouse_exited", self, "onExit")

func _ready():
	get_node("/root/Main/Camera").translate(Vector3(gridSize/2,gridSize/2,gridSize))
	
func onClick(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		leftClicked = event.pressed
		if event.pressed:
			currentPolygon = Polygon.new()
			add_child(currentPolygon)
			currentPolygon.vertices.append({"vector": Vector3(click_position.x, click_position.y, 0), "type":"edge", "position":0})
		elif !event.pressed:
			if currentPolygon:
				currentPolygon.finishPolygon()
				currentPolygon = null
		
func onMove(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseMotion and leftClicked:
		currentPolygon.drawEdge({"clickPosition": Vector3(click_position.x, click_position.y, 0)})
		
func onExit():
	leftClicked = false
	if currentPolygon:
		currentPolygon.finishPolygon()
		currentPolygon = null
		
func drawCanvasLines():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	for i in range(gridSize + 1):
		st.add_vertex(Vector3(i, 0, zOffset))
		st.add_vertex(Vector3(i, gridSize, zOffset))
		st.add_vertex(Vector3(0, i, zOffset))
		st.add_vertex(Vector3(gridSize, i, zOffset))

	var mi = MeshInstance.new()
	mi.name = "CanvasMesh"
	mi.set_mesh(st.commit())
	add_child(mi)
	
	var pva = PoolVector3Array()
	pva.append(Vector3(0, 0, zOffset))
	pva.append(Vector3(0, gridSize, zOffset))
	pva.append(Vector3(gridSize, 0, zOffset))
	pva.append(Vector3(0, gridSize, zOffset))
	pva.append(Vector3(gridSize, gridSize, zOffset))
	var convexShape = ConvexPolygonShape.new()
	convexShape.set_points(pva)
	var cs = CollisionShape.new()
	cs.name = "CanvasCollisionShape"
	cs.set_shape(convexShape)
	add_child(cs)