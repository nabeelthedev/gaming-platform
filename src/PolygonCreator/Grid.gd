extends StaticBody
var gridSize = 10

func _ready():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	for i in range(gridSize + 1):
		st.add_vertex(Vector3(i, 0, 0))
		st.add_vertex(Vector3(i, gridSize, 0))
		st.add_vertex(Vector3(0, i, 0))
		st.add_vertex(Vector3(gridSize, i, 0))
	
	var mi = MeshInstance.new()
	mi.set_mesh(st.commit())
	add_child(mi)
	
	for i in range (gridSize + 1):
		for j in range (gridSize + 1):
			add_child(VertexButton.new().create(i,j, gridSize))
	get_node("/root/PolygonCreator/Camera").translate(Vector3(gridSize/2,gridSize/2,gridSize))
	get_node("/root/PolygonCreator/Polygon").translate(Vector3(gridSize/2,gridSize/2,-gridSize/2))
	return self
	
class VertexButton extends StaticBody:
	var toggled = false
	var x = null
	var y = null
	var z = null
	var zOffset = .001
	
	func create(x, y, gridSize):
		var buttonSize = .2
		var coordinateSize = buttonSize/2
		self.x = x - (gridSize/2)
		self.y = y - (gridSize/2)
		self.z = gridSize/2
		var pva = PoolVector3Array()
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		
		var botLeft = Vector3(x - coordinateSize, y - coordinateSize, zOffset)
		var topLeft = Vector3(x - coordinateSize, y + coordinateSize, zOffset)
		var botRight = Vector3(x + coordinateSize, y - coordinateSize, zOffset)
		var topRight = Vector3(x + coordinateSize, y + coordinateSize, zOffset)
		
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
		var polygon = get_node("/root/PolygonCreator/Polygon")
		if event is InputEventMouseButton and !event.pressed:
			var mi = self.get_node("MeshInstance")
			var material = SpatialMaterial.new()
			if !self.toggled:
				material.albedo_color = Color8(255,0,0)
				if !polygon.addVertex(self):
					material.albedo_color = Color8(0,0,255)
			else:
				material.albedo_color = Color8(0,0,255)
				polygon.removeVertex(self)
			self.toggled = !self.toggled
			mi.set_surface_material(0, material)
			polygon.draw()