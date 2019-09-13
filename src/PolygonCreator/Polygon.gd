extends StaticBody

var vertices = []
var pendingVertices = []
var C = {}

func create():
	name = "Polygon"
	var mi = MeshInstance.new()
	mi.name = "MeshInstance"
	add_child(mi)
	return self
	
func addVertex(ref):
	if pendingVertices.size() == 2:
		var P = {"x":pendingVertices[0].x, "y":pendingVertices[0].y, "z":pendingVertices[0].z}
		var Q = {"x":pendingVertices[1].x, "y":pendingVertices[1].y, "z":pendingVertices[1].z}
		var R = {"x":ref.x, "y":ref.y, "z":ref.z}
		
		var PQ = {"x": Q.x - P.x, "y":Q.y - P.y, "z":Q.z - P.z}
		var PR = {"x": R.x - P.x, "y":R.y - P.y, "z":R.z - P.z}
		var PQPR = {"x":PQ.y*PR.z - PQ.z*PR.y, "y":PQ.z*PR.x-PQ.x*PR.z, "z":PQ.x*PR.y - PQ.y*PR.x}
		var PQPRMag = sqrt(pow(PQPR.x, 2) + pow(PQPR.y, 2) + pow(PQPR.z, 2))
		
		var area = PQPRMag * .5
		if area == 0:
			return false
		
		C = {"x":float(P.x + Q.x + R.x)/3 , "y":float(P.y + Q.y + R.y)/3, "z":float(P.z + Q.z + R.z)/3}

	pendingVertices.append(ref)
	return true
	
func removeVertex(ref):
	pendingVertices.erase(ref)
	return true
	
func draw():
	if pendingVertices.size() != 3:
		return false
	pendingVertices.sort_custom(self, "sort")
	vertices = vertices + pendingVertices
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in vertices:
		st.add_vertex(Vector3(i.x, i.y, i.z))
	get_node("MeshInstance").set_mesh(st.commit())
	
	var material = SpatialMaterial.new()
	material.albedo_color = Color8(0,0,255)
	
	for i in pendingVertices:
		var mi = i.get_node("MeshInstance")
		mi.set_surface_material(0, material)
		i.toggled = false
	pendingVertices.clear()
	
func sort(a, b):
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