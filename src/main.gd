extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(camera())
	add_child(grid())
	add_child(Polygon.new().create())

func camera():
	var camera = Camera.new()
	camera.name = "Camera"
	camera.translate(Vector3(0,0,10))
	return camera

func grid():
	var gridSize = 10
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	for i in range(gridSize + 1):
		st.add_vertex(Vector3(i, 0, 0))
		st.add_vertex(Vector3(i, gridSize, 0))
		st.add_vertex(Vector3(0, i, 0))
		st.add_vertex(Vector3(gridSize, i, 0))
	
	var sb = StaticBody.new()
	var mi = MeshInstance.new()
	mi.set_mesh(st.commit())
	sb.add_child(mi)
	get_node("Camera").translate(Vector3(gridSize/2,gridSize/2,0))
	
	for i in range (gridSize + 1):
		for j in range (gridSize + 1):
			add_child(VertexButton.new().create(i,j))
	return sb
	
class VertexButton extends StaticBody:
	var toggled = false
	var xPos = null
	var yPos = null
	func create(x, y):
		var buttonSize = .2
		var coordinateSize = buttonSize/2
		xPos = x
		yPos = y
		
		var pva = PoolVector3Array()
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		
		var botLeft = Vector3(x - coordinateSize, y - coordinateSize, 0)
		var topLeft = Vector3(x - coordinateSize, y + coordinateSize, 0)
		var botRight = Vector3(x + coordinateSize, y - coordinateSize, 0)
		var topRight = Vector3(x + coordinateSize, y + coordinateSize, 0)
		
		st.add_vertex(botLeft)
		st.add_vertex(topLeft)
		st.add_vertex(botRight)
		st.add_vertex(topRight)
		
		pva.append(botLeft)
		pva.append(topLeft)
		pva.append(botRight)
		pva.append(topRight)
		var convexShape = ConvexPolygonShape.new()
		convexShape.set_points(pva)
		
		var sb = StaticBody.new()
		var mi = MeshInstance.new()
		mi.name = "MeshInstance"
		mi.set_mesh(st.commit())
		var material = SpatialMaterial.new()
		material.albedo_color = Color8(0,0,255)
		mi.set_surface_material(0, material)
		add_child(mi)
		
		var cs = CollisionShape.new()
		cs.set_shape(convexShape)
		add_child(cs)
		
		connect("input_event", self, "onClick")
		return self
		
	func onClick(camera, event, click_position, click_normal, shape_idx):
		if event is InputEventMouseButton and !event.pressed:
			var mi = self.get_node("MeshInstance")
			var material = SpatialMaterial.new()
			if !self.toggled:
				material.albedo_color = Color8(255,0,0)
				get_node("/root/Main/Polygon").addVertex(self.xPos, self.yPos, 0)
			else:
				material.albedo_color = Color8(0,0,255)
				get_node("/root/Main/Polygon").removeVertex(self.xPos, self.yPos, 0)
			self.toggled = !self.toggled
			mi.set_surface_material(0, material)
			
			
func draw():
	pass
	
class Polygon extends StaticBody:
	var vertices = []
	
	func create():
		name = "Polygon"
		var mi = MeshInstance.new()
		mi.name = "MeshInstance"
		add_child(mi)
		return self
	func addVertex(x, y, z):
		vertices.append([x, y, z])
		print(vertices)
		draw()
	func removeVertex(x, y, z):
		vertices.erase([x, y, z])
		print(vertices)
		draw()
	func draw():
		if vertices.size() < 3:
			get_node("MeshInstance").set_mesh(null)
		else:
			var st = SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			for i in vertices:
				st.add_vertex(Vector3(i[0], i[1], i[2]))
			get_node("MeshInstance").set_mesh(st.commit())
	