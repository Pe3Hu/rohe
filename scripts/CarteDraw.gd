extends Node2D


func _draw():
	if Global.obj.keys().has("carte"):
		for zones in Global.obj.carte.arr.zone:
			for zone in zones:
				draw_polygon(zone.arr.point, PoolColorArray([zone.color.background]))
				
				if zone.obj.essence != null && false == true:
					if zone.obj.essence.num.vertexs == 0:
						draw_circle(zone.vec.center, zone.obj.essence.num.a, zone.obj.essence.color.background)
					else:
						draw_polygon(zone.obj.essence.arr.point, PoolColorArray([zone.obj.essence.color.background]))
						
				if zone.obj.stronghold:
					#draw_circle(zone.vec.center, Global.num.stronghold.a, Color.black)
					draw_polygon(zone.arr.point, PoolColorArray([Color.dimgray]))
			
#		for zones in Global.obj.carte.arr.zone:
#			for zone in zones:
#				if zone.arr.dominanceline.size() > 0:
#					for dominanceline in zone.arr.dominanceline:
#						draw_line(dominanceline.front(), dominanceline.back(), Color.black, Global.num.dominanceline.width)

		for zones in Global.obj.carte.arr.zone:
			for zone in zones:
				if zone.arr.bidline.size() > 0:
					for bidline in zone.arr.bidline:
						draw_line(bidline.front(), bidline.back(), Color.black, Global.num.dominanceline.width)
		
		#for diplomacy in Global.obj.carte.arr.diplomacy:
		#	draw_line(diplomacy.arr.point.front(), diplomacy.arr.point.back(), Color.black, Global.num.diplomacy.width)
		
		for relationship in Global.obj.carte.arr.relationship:
			if relationship.num.value > 0:
				draw_line(relationship.arr.point.front(), relationship.arr.point.back(), relationship.color.line, Global.num.diplomacy.width)

func _process(delta):
	update()
