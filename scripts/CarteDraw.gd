extends Node2D


func _draw():
	if Global.obj.keys().has("carte"):
		for zones in Global.obj.carte.arr.zone:
			for zone in zones:
				draw_polygon(zone.arr.point, PoolColorArray([zone.color.background]))#zone.color.background
				
				if zone.obj.essence != null && false == true:
					if zone.obj.essence.num.vertexs == 0:
						draw_circle(zone.vec.center, zone.obj.essence.num.a, zone.obj.essence.color.background)
					else:
						draw_polygon(zone.obj.essence.arr.point, PoolColorArray([zone.obj.essence.color.background]))
						
				if zone.obj.stronghold:
					draw_circle(zone.vec.center, Global.num.essence.a/1.3, Color.black)
		
		for diplomacy in Global.obj.carte.arr.diplomacy:
			draw_line(diplomacy.arr.point.front(), diplomacy.arr.point.back(), Color.black, Global.num.diplomacy.width)

func _process(delta):
	update()
