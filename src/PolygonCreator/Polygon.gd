extends StaticBody

var vertices = []
var edgeVertices = []
var bodyVertices = []
const maxEdgeLength = .25
var wireframe = StaticBody.new()
var pendingEdge = MeshInstance.new()

func _init():
	name = "Polygon"
	wireframe.name = "WireFrame"
	pendingEdge.name = "PendingEdge"
	add_child(wireframe)
	wireframe.add_child(pendingEdge)
	
func drawEdge(input):
	var lastVertexVector = vertices[vertices.size() - 1].vector
	var P = lastVertexVector
	var Q = input.clickPosition
	var R
	var PQ = Q - P
	# Distance Formula: {a^2} + {b^2} = {c^2}
	var distance = sqrt(pow((Q.x - P.x), 2) + pow((Q.y - P.y), 2) + pow((Q.z - P.z), 2))
	
	if distance >= maxEdgeLength:
		var st = SurfaceTool.new()
		while distance >= maxEdgeLength:
			st.begin(Mesh.PRIMITIVE_LINES)
			R = P + (PQ.normalized() * maxEdgeLength)
			st.add_vertex(P)
			st.add_vertex(R)
			
			var mi = MeshInstance.new()
			mi.name = "MeshInstance"
			mi.set_mesh(st.commit())
			st.clear()
			
			var pva = PoolVector3Array()
			pva.append(P)
			pva.append(R)
			var cps = ConvexPolygonShape.new()
			cps.set_points(pva)
			var cs = CollisionShape.new()
			cs.name = "CollisionShape"
			cs.set_shape(cps)
			
			var sb = StaticBody.new()
			sb.name = "Edge"
			sb.add_child(mi)
			sb.add_child(cs)
			wireframe.add_child(sb)
			var position = vertices.size()
			vertices.append({"vector":R, "type": "edge", "position":position})
			vertices[vertices.size() - 2].staticBody = sb
			P = R
			distance = sqrt(pow((Q.x - P.x), 2) + pow((Q.y - P.y), 2) + pow((Q.z - P.z), 2))
	if "finishPolygon" in input and input.finishPolygon and distance > 0:
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_LINES)
		st.add_vertex(P)
		st.add_vertex(Q)
		
		var mi = MeshInstance.new()
		mi.set_mesh(st.commit())
		
		var pva = PoolVector3Array()
		pva.append(P)
		pva.append(Q)
		var cps = ConvexPolygonShape.new()
		cps.set_points(pva)
		var cs = CollisionShape.new()
		cs.name = "CollisionShape"
		cs.set_shape(cps)
		
		var sb = StaticBody.new()
		sb.name = "Line"
		sb.add_child(mi)
		sb.add_child(cs)
		wireframe.add_child(sb)
		vertices[vertices.size() - 1].staticBody = sb
		edgeVertices = vertices
	updatePendingEdge({"clickPosition": input.clickPosition})
	
func updatePendingEdge(input):
	if !pendingEdge:
		return false
	var lastVertexVector = vertices[vertices.size() - 1].vector
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	st.add_vertex(lastVertexVector)
	st.add_vertex(input.clickPosition)
	pendingEdge.set_mesh(st.commit())
	
func finishPolygon():
	if vertices.size() < 3:
		self.queue_free()
		return false
	pendingEdge.queue_free()
	drawEdge({"clickPosition": vertices[0].vector, "finishPolygon":true})
	setSurfaceNormals()
	setBodyVertices()
	drawPoints()
	
func setBodyVertices():
	var planes = []
	for i in vertices:
		var N = i.normal
		var D = N.dot(i.vector)
		i.plane = Plane(N, D)
		planes.append(Plane(N, D))
		
	var maxRow = 10
	var maxCol = 10
	var row = 0
	var col = 0
	var count = 0
	var space_state = get_world().direct_space_state
	while row <= maxRow:
		while col <= maxCol:
			var valid = true
			var newPoint = Vector3(col, row, 0)
			for i in vertices:
				if i.plane.distance_to(newPoint) >= 0:
					#check if ray intersects anything
					var from = i.midpoint
					var to = newPoint
					var exceptions = [i.staticBody]
					var collisions = space_state.intersect_ray(from, to, exceptions)
					if !collisions:
						valid = false
						break
			if valid:
				bodyVertices.append({"vector": newPoint, "type":"body", "position":count})
			count += 1
			col += maxEdgeLength
		row += maxEdgeLength
		col = 0
			
	vertices += bodyVertices
	
func setSurfaceNormals():
	#set surface line midpoint and arbitrary normal
	for i in range(vertices.size()):
		var a = vertices[i].vector
		var b
		if i != vertices.size() - 1:
			b = vertices[i + 1].vector
		else:
			b = vertices[0].vector
		var dvec = (b - a).normalized()
		var normal = Vector3(-dvec.y, dvec.x, dvec.z)
		var midpoint = Vector3((a.x + b.x)/2, (a.y + b.y)/2, (a.z + b.z)/2)
		vertices[i].normal = normal
		vertices[i].midpoint = midpoint
		
	#set correct ourward facing normals
	var space_state = get_world().direct_space_state
	var invertSurfaceNormal = false
	for i in vertices:
		var from = i.midpoint
		var to = i.normal + i.midpoint
		to = to + ((to - from)*20)
		var exceptions = [i.staticBody]
		var side1 = space_state.intersect_ray(from, to, exceptions)
		var side2 = space_state.intersect_ray(from, -to, exceptions)
		if !side1:
			break
		elif !side2:
			invertSurfaceNormal = true
			break
	if invertSurfaceNormal:
		for i in vertices:
			i.normal = -i.normal
		vertices.invert()
			
	var drawData = []
	for i in vertices:
		i.staticBody.get_node("CollisionShape").queue_free()
		var from = i.midpoint
		var to = i.midpoint + i.normal
		to = to - ((to - from)*.5)
		drawData.append(from)
		drawData.append(to)

	var input = {"type": Mesh.PRIMITIVE_LINES, "data":drawData}
	draw(input)
	
func draw(input):
	var st = SurfaceTool.new()
	st.begin(input.type)
	for i in input.data:
		st.add_vertex(i)
	var mi = MeshInstance.new()
	mi.set_mesh(st.commit())
	add_child(mi)

func drawPoints():
	var drawData = []
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_POINTS)
	for i in vertices:
		st.add_vertex(i.vector)

	var mi = MeshInstance.new()
	mi.name = "VerticesMeshInstance"
	mi.set_mesh(st.commit())
	var material = SpatialMaterial.new()
	material.albedo_color = Color8(255,0,0)
	material.flags_use_point_size = true
	material.params_point_size = 5
	mi.set_surface_material(0, material)
	wireframe.add_child(mi)