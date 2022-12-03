extends Node


func _ready():
#	datas.sort_custom(Sorter, "sort_ascending")
	Global.obj.carte = Classes.Carte.new()

func _input(event):
	if event is InputEventMouseButton:
		if Global.flag.click:
			if Global.obj.keys().has("carte"):
				Global.obj.carte.drop_essences()
			Global.flag.click = !Global.flag.click
		else:
			Global.flag.click = !Global.flag.click

func _process(delta):
	pass

func _on_Timer_timeout():
	Global.node.TimeBar.value +=1
	
	if Global.node.TimeBar.value >= Global.node.TimeBar.max_value:
		Global.node.TimeBar.value -= Global.node.TimeBar.max_value
