extends Node2D


func _draw():
	if Global.obj.keys().has("carte"):
		for zones in Global.obj.carte.arr.zone:
			for zone in zones:
				#if zone.flag.visiable:
				draw_polygon(zone.arr.point, PoolColorArray([zone.color.background]))
#				if zone.flag.capital:
#					var color = Color.black
#
#					if zone.obj.village.flag.arenas:
#						color = Color.white
#
#					#if zone.obj.village.flag.interior:
#					#	color  = Color.blue
#
#					draw_circle(zone.vec.center, Global.num.zone.a/4, color)

func _process(delta):
	update()
