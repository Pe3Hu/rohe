extends Node2D


func _draw():
	if Global.obj.keys().has("carte"):
		for zones in Global.obj.carte.arr.zone:
			for zone in zones:
				#if zone.flag.visiable:
				draw_polygon(zone.arr.point, PoolColorArray([Color.white]))#zone.color.background
				
				if zone.obj.essence != null:
					draw_circle(zone.vec.center, zone.obj.essence.num.a, zone.obj.essence.color.background)

func _process(delta):
	update()
