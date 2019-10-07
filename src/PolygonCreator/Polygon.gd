extends StaticBody

var vertices = []
var pendingVertices = []
var pendingVerticesRefs = []
var C = {}
var normal = Vector3(0,0,1)
var currentFace = 0
var vertexFaceTransform = [
{"x": {"axis":"x", "sign":1}, "y":{"axis":"y", "sign":1}, "z":{"axis":"z", "sign":1}},
{"x": {"axis":"z", "sign":1}, "y":{"axis":"y", "sign":1}, "z":{"axis":"x", "sign":-1}},
{"x": {"axis":"x", "sign":-1}, "y":{"axis":"y", "sign":1}, "z":{"axis":"z", "sign":-1}},
{"x": {"axis":"z", "sign":-1}, "y":{"axis":"y", "sign":1}, "z":{"axis":"x", "sign":1}},
{"x": {"axis":"x", "sign":1}, "y":{"axis":"z", "sign":1}, "z":{"axis":"y", "sign":-1}},
{"x": {"axis":"x", "sign":1}, "y":{"axis":"z", "sign":-1}, "z":{"axis":"y", "sign":1}}]
var toggledTriangles = []

signal polygon_created
signal polygon_face_changed

func _init():
	name = "Polygon"
	var mi = MeshInstance.new()
	mi.name = "MeshInstance"
	add_child(mi)
#	return self

func _ready():
#	name = "Polygon"
#	var mi = MeshInstance.new()
#	mi.name = "MeshInstance"
#	add_child(mi)
#	return self
	get_node("/root/Main").emit_signal("polygon_created")
	
func addVertex(ref):
	if pendingVertices.size() == 2:
		var P = {"x":pendingVertices[0][0], "y":pendingVertices[0][1], "z":pendingVertices[0][2]}
		var Q = {"x":pendingVertices[1][0], "y":pendingVertices[1][1], "z":pendingVertices[1][2]}
		var R = {"x":ref.x, "y":ref.y, "z":ref.z}
		
		var PQ = {"x": Q.x - P.x, "y":Q.y - P.y, "z":Q.z - P.z}
		var PR = {"x": R.x - P.x, "y":R.y - P.y, "z":R.z - P.z}
		var PQPR = {"x":PQ.y*PR.z - PQ.z*PR.y, "y":PQ.z*PR.x-PQ.x*PR.z, "z":PQ.x*PR.y - PQ.y*PR.x}
		var PQPRMag = sqrt(pow(PQPR.x, 2) + pow(PQPR.y, 2) + pow(PQPR.z, 2))
		
		var area = PQPRMag * .5
		if area == 0:
			return false
	pendingVertices.append([ref.x, ref.y, ref.z])
	pendingVerticesRefs.append(ref)
	return true
	
func removeVertex(ref):
	pendingVertices.erase([ref.x, ref.y, ref.z])
	pendingVerticesRefs.erase(ref)
	return true
	
func draw():
	if pendingVertices.size() != 3:
		return false
	
	for i in pendingVertices:
		var coords = {"x":i[0], "y":i[1], "z":i[2]}
		i[0] = coords[vertexFaceTransform[currentFace]["x"]["axis"]] * vertexFaceTransform[currentFace]["x"]["sign"]
		i[1] = coords[vertexFaceTransform[currentFace]["y"]["axis"]] * vertexFaceTransform[currentFace]["y"]["sign"]
		i[2] = coords[vertexFaceTransform[currentFace]["z"]["axis"]] * vertexFaceTransform[currentFace]["z"]["sign"]
	
	C = {"x":float(pendingVertices[0][0] + pendingVertices[1][0] + pendingVertices[2][0])/3 , "y":float(pendingVertices[0][1] + pendingVertices[1][1] + pendingVertices[2][1])/3, "z":float(pendingVertices[0][2] + pendingVertices[1][2] + pendingVertices[2][2])/3}
	pendingVertices.sort_custom(self, "sort")
	vertices = vertices + pendingVertices
#	var st = SurfaceTool.new()
#	st.begin(Mesh.PRIMITIVE_TRIANGLES)
#	for i in vertices:
#		st.add_vertex(Vector3(i[0], i[1], i[2]))
#	get_node("MeshInstance").set_mesh(st.commit())

	add_child(Triangle.new().draw(pendingVertices))
	
	clearPendingVertices()

func clearPendingVertices():
	var material = SpatialMaterial.new()
	material.albedo_color = Color8(0,0,255)
	for i in pendingVerticesRefs:
		var mi = i.get_node("MeshInstance")
		mi.set_surface_material(0, material)
		i.toggled = false
	pendingVertices.clear()
	pendingVerticesRefs.clear()
	
func sort(inputA, inputB):
	var a = {"x":inputA[0], "y": inputA[1], "z":inputA[2]}
	var b = {"x":inputB[0], "y": inputB[1], "z":inputB[2]}
	var P = Vector3(C.x, C.y, C.z)
	var Q = Vector3(a.x,a.y,a.z)
	var R = Vector3(b.x,b.y,b.z)
	
	var side1 = Q - P
	var side2 = R - P
	var cross = side1.cross(side2)
	var dot = normal.dot(cross)
	return dot < 0
	
func sort_old(inputA, inputB):
	var a = {"x":inputA[0], "y": inputA[1]}
	var b = {"x":inputB[0], "y": inputB[1]}
	if a.x - C.x >= 0 && b.x - C.x < 0:
		return true
	if a.x - C.x < 0 and b.x - C.x >= 0:
		return false
	if a.x - C.x == 0 and b.x - C.x == 0:
		if a.y - C.y >= 0 or b.y - C.y >= 0:
			return a.y > b.y
		return b.y > a.y
		
	var det = (a.x - C.x) * (b.y - C.y) - (b.x - C.x) * (a.y - C.y)
	if det < 0:
		return true
	if det > 0:
		return false
	
	var d1 = (a.x - C.x) * (a.x - C.x) + (a.y - C.y) * (a.y - C.y)
	var d2 = (b.x - C.x) * (b.x - C.x) + (b.y - C.y) * (b.y - C.y)
	return d1 > d2
	
func changeFace(face):
	currentFace = face
	match face:
		0:
			normal = Vector3(0,0,1)
		1:
			normal = Vector3(1,0,0)
		2:
			normal = Vector3(0,0,-1)
		3:
			normal = Vector3(-1,0,0)
		4:
			normal = Vector3(0,1,0)
		5:
			normal = Vector3(0,-1,0)
	emit_signal("polygon_face_changed")
	
class Triangle extends StaticBody:
	var toggled = false
	var colors = {"default": Color8(128,128,128), "selected": Color8(128,32,32), "hover_default": Color8(160,160,160), "hover_selected": Color8(160,32,32)}
	func _ready():
	#	sb.translate(Vector3(5,5,-5))
		connect("input_event", self, "onClick")
		connect("mouse_entered", self, "onEntered")
		connect("mouse_exited", self, "onExited")
	func draw(pendingVertices):
		var pva = PoolVector3Array()
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in pendingVertices:
			st.add_vertex(Vector3(i[0], i[1], i[2]))
			pva.append(Vector3(i[0], i[1], i[2]))
		
		var convexShape = ConvexPolygonShape.new()
		convexShape.set_points(pva)
		
		var mi = MeshInstance.new()
		mi.name = "MeshInstance"
		mi.set_mesh(st.commit())
		var material = SpatialMaterial.new()
		material.albedo_color = colors.default
		mi.set_surface_material(0, material)
		add_child(mi)
		
		var cs = CollisionShape.new()
		cs.set_shape(convexShape)
		add_child(cs)
		return self
	func onClick(camera, event, click_position, click_normal, shape_idx):
		if event is InputEventMouseButton and !event.pressed:
			var mi = self.get_node("MeshInstance")
			var material = SpatialMaterial.new()
			var toggledTriangles = get_parent().toggledTriangles
			var deleteButton = get_node("/root/Main/UI/DeleteButton")
			if !self.toggled:
				material.albedo_color = colors.selected
				toggledTriangles.append(self)
				if deleteButton.disabled:
					deleteButton.disabled = false
			else:
				material.albedo_color = colors.default
				toggledTriangles.erase(self)
				if toggledTriangles.size() == 0 and !deleteButton.disabled:
					deleteButton.disabled = true
			self.toggled = !self.toggled
			mi.set_surface_material(0, material)
			print(self)
	func onEntered():
		var mi = self.get_node("MeshInstance")
		var material = SpatialMaterial.new()
		if self.toggled:
			material.albedo_color = colors.hover_selected
		else:
			material.albedo_color = colors.hover_default
		mi.set_surface_material(0, material)
	func onExited():
		var mi = self.get_node("MeshInstance")
		var material = SpatialMaterial.new()
		if self.toggled:
			material.albedo_color = colors.selected
		else:
			material.albedo_color = colors.default
		mi.set_surface_material(0, material)