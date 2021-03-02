extends TileMap

onready var liquidSim = $LiquidSim
export(NodePath) var WATER_SPAWN

var finalPos

func _ready():
	for node in get_tree().get_nodes_in_group("WaterPosition"):
		finalPos = world_to_map(node.position)
#		liquidSim.add_liquid(finalPos.x, finalPos.y, 0.35)

func _on_IfVisible_screen_entered():
	if get_tree().current_scene != null:
		var waterSpawn = get_node(WATER_SPAWN)
		finalPos = world_to_map(waterSpawn.position)
#		liquidSim.add_liquid(finalPos.x, finalPos.y, 0.45)

func _on_IfVisible_screen_exited():
	get_parent().get_node("SewerPipes/SewerPipe/IfVisible").queue_free()
