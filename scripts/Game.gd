extends Node


func _ready():
#	datas.sort_custom(Sorter, "sort_ascending")
	#Global.obj.carte = Classes_0.Carte.new()
	pass

func _input(event):
	if event is InputEventMouseButton:
		if Global.flag.click:
			if Global.obj.keys().has("carte"):
				Global.obj.carte.pick_zone(event)
				#Global.next_zone_layer()
				#Global.next_potential_connection()
				#Global.obj.carte.drop_essences()
			Global.flag.click = !Global.flag.click
		else:
			Global.flag.click = !Global.flag.click

func _process(delta):
	pass

func _on_Timer_timeout():
	Global.node.TimeBar.value +=1
	
	if Global.node.TimeBar.value >= Global.node.TimeBar.max_value:
		Global.node.TimeBar.value -= Global.node.TimeBar.max_value
