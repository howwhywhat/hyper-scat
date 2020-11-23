extends TileMap

onready var liquidSim = $LiquidSim
export(NodePath) var WATER_SPAWN

var finalPos

func _ready():
	for node in get_tree().get_nodes_in_group("WaterPosition"):
		finalPos = world_to_map(node.position)
		liquidSim.add_liquid(finalPos.x, finalPos.y, 0.1)

func _on_IfVisible_screen_entered():
	var waterSpawn = get_node(WATER_SPAWN)
	finalPos = world_to_map(waterSpawn.position)
	liquidSim.add_liquid(finalPos.x, finalPos.y, 0.25)

func _on_IfVisible_screen_exited():
	get_tree().current_scene.get_node("SewerPipes").get_node("SewerPipe").get_node("IfVisible").disconnect("screen_entered", self, "_on_IfVisible_screen_entered")
	yield(get_tree().create_timer(2), "timeout")
	get_tree().current_scene.get_node("SewerPipes").get_node("SewerPipe").get_node("IfVisible").disconnect("screen_exited", self, "_on_IfVisible_screen_exited")
