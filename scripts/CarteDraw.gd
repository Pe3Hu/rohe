extends Node2D


func _draw():
	if Global.obj.keys().has("carte"):
		for zones in Global.obj.carte.arr.zone:
			for zone in zones:
				#draw_polygon(zone.arr.point, PoolColorArray([zone.color.background]))
				
				if zone.obj.dominance != null && Global.arr.layer[Global.num.layer.current] == "Dominance":
					if true:#zone.obj.dominance.num.index != 0:
						draw_polygon(zone.arr.point, PoolColorArray([Color.white]))
				draw_polygon(zone.arr.point, PoolColorArray([Color.white]))
		
		if Global.arr.layer[Global.num.layer.current] == "Dominance":
			for stronghold in Global.obj.carte.arr.stronghold:
				var hue = float(stronghold.num.index)/float(Global.obj.carte.arr.stronghold.size())
				var color = Color().from_hsv(hue,1,1) 
				
				for zone in stronghold.obj.task.arr.zone:
					draw_polygon(zone.arr.point, PoolColorArray([color]))
			
			for zone in Global.obj.carte.arr.picked:
				draw_polygon(zone.arr.point, PoolColorArray([Color.black]))
	
		for zones in Global.obj.carte.arr.zone:
			for zone in zones:
				if zone.obj.essence != null:
					if Global.arr.layer[Global.num.layer.current] == "Dominance" || Global.arr.layer[Global.num.layer.current] == "Potential":
						
						if zone.obj.essence.num.vertexs == 0:
							draw_circle(zone.vec.center, zone.obj.essence.num.a, zone.obj.essence.color.background)
							draw_circle_arc(zone.vec.center, zone.obj.essence.num.a, 0, 360, Color.black)
						else:
							draw_polygon(zone.obj.essence.arr.point, PoolColorArray([zone.obj.essence.color.background]))
							
							for _i in range(1, zone.obj.essence.arr.point.size()):
								draw_line(zone.obj.essence.arr.point[_i-1] , zone.obj.essence.arr.point[_i], Color.black, Global.num.dominanceline.width)
							
							draw_line(zone.obj.essence.arr.point[zone.obj.essence.arr.point.size()-1] , zone.obj.essence.arr.point[0], Color.black, Global.num.dominanceline.width)
		
		if Global.arr.layer[Global.num.layer.current] == "Demesne":
			for zones in Global.obj.carte.arr.zone:
				for zone in zones:
					if zone.arr.dominanceline.size() > 0:
						for dominanceline in zone.arr.dominanceline:
							draw_line(dominanceline.front(), dominanceline.back(), Color.black, Global.num.dominanceline.width)
		
		if Global.arr.layer[Global.num.layer.current] == "Dominance":
			for zones in Global.obj.carte.arr.zone:
				for zone in zones:
					if zone.arr.bidline.size() > 0:
						for bidline in zone.arr.bidline:
							draw_line(bidline.front(), bidline.back(), Color.black, Global.num.dominanceline.width)
		
			for relationship in Global.obj.carte.arr.relationship:
				if relationship.num.value > 0:
					draw_line(relationship.arr.point.front(), relationship.arr.point.back(), relationship.color.line, Global.num.diplomacy.width)

func _process(delta):
	update()

func draw_circle_arc(center_, radius_, angle_from_, angle_to_, color_):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from_ + i * (angle_to_-angle_from_) / nb_points - 90)
		points_arc.push_back(center_ + Vector2(cos(angle_point), sin(angle_point)) * radius_)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color_)
