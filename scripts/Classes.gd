extends Node


class Zone:
	var num = {}
	var word = {}
	var vec = {}
	var arr = {}
	var flag = {}
	var color = {}
	var obj = {}

	func _init(input_):
		num.wave = -1
		word.windrose = ""
		vec.grid = input_.grid
		vec.center = input_.grid*Global.num.zone.a + Global.vec.carte
		obj.carte = input_.carte
		init_arrs()
		init_objs()
		init_flags()
		set_points() 
		color.background = Color().from_hsv(0,0,1.0)

	func init_arrs():
		arr.point = []
		arr.neighbor = []
		arr.frontiere = []
		arr.delimited = []
		arr.associated = []

	func init_objs():
		obj.secteur = null
		obj.diagonal = null
		obj.line = null
		obj.district = null
		obj.essence = null
		obj.heir = self

	func init_flags():
		flag.well = false
		flag.onto = {} 
		flag.onto.intersection = false
		flag.onto.frontiere = false
		flag.onto.secteur = false
		flag.near = {} 
		flag.near.intersection = false
		flag.near.frontiere = false
		flag.near.border = false
		obj.diagonal = null
		obj.line = null

	func set_points():
		for point in Global.arr.point:
			var vertex = point * Global.num.zone.a/2 + vec.center
			arr.point.append(vertex)

	func drop_essence():
		if obj.heir.obj.essence == null:
			obj.essence.obj.zone = obj.heir
			obj.heir.obj.essence = obj.essence
			obj.essence = null
		
		if flag.near.border:
			obj.carte.arr.ejection.append(self)

	func update_color():
		if flag.onto.frontiere:
			color.background = Color.orange
		if flag.onto.intersection:
			color.background = Color.red
		if flag.onto.secteur:
			color.background = Color.green
		if flag.near.frontiere:
			color.background = Color.aqua
		if flag.near.border:
			color.background = Color.purple

	func color_flag(key_, name_):
		if flag[key_][name_]:
			color.background = Color.black
		else:
			color.background = Color.white

	func check_near_border():
		return vec.grid.x == 0 || vec.grid.x == Global.num.carte.cols-1 || vec.grid.y == 0 || vec.grid.y == Global.num.carte.rows-1

class Frontiere:
	var num = {}
	var arr = {}
	var obj = {}

	func _init(input_):
		obj.carte = input_.carte
		num.row = input_.row
		num.col = input_.col
		arr.zone = []

class Secteur:
	var num = {}
	var arr = {}
	var obj = {}

	func _init(input_):
		num.index = Global.num.primary_key.secteur
		Global.num.primary_key.secteur += 1
		obj.carte = input_.carte
		arr.zone = []

class District:
	var num = {}
	var arr = {}
	var obj = {}
	var flag = {}

	func _init(input_):
		obj.carte = input_.carte
		arr.zone = []
		arr.neighbor = []
		arr.domain = []
		arr.domain.append_array(Global.arr.domain)

	func add_zone(zone_):
		arr.zone.append(zone_)
		zone_.obj.district = self
		
		for neigbhor in zone_.arr.neighbor:
			if arr.zone.has(neigbhor):
				zone_.arr.associated.append(neigbhor)
			
			zone_.arr.delimited.erase(neigbhor)
			neigbhor.arr.delimited.erase(zone_)

	func update_domain_by(district_, flag_):
		if arr.domain.has(district_.arr.domain.front()):
			if arr.domain.size() > 1:
				arr.domain.erase(district_.arr.domain.front())
				
				if flag_:
					for neighbor in arr.neighbor:
						neighbor.update_domain_by(district_, false)
			
				if arr.domain.size() == 1:
					for neighbor in arr.neighbor:
						neighbor.update_domain_by(self, true)
			else:
				obj.carte.flag.domain = false

	func merge_with(district_):
		for zone in district_.arr.zone:
			add_zone(zone)
		
		for neighbor in district_.arr.neighbor:
			if !arr.neighbor.has(neighbor) && neighbor != self:
				arr.neighbor.append(neighbor)
		
		obj.carte.arr.district.erase(district_)

class Essence:
	var num = {}
	var word = {}
	var obj = {}
	var color = {}

	func _init(input_):
		num.rank = input_.rank
		num.a = Global.num.zone.a/4
		word.element = input_.element
		obj.zone = input_.zone
		obj.carte = input_.carte
		obj.zone.obj.essence = self
		color.background = Global.color.essence[word.element]

	func check_drop_end():
		if obj.zone.obj.heir.obj.essence == null:
			if obj.zone.obj.heir == obj.zone.obj.heir.obj.heir || obj.zone.obj.heir.word.windrose == obj.zone.word.windrose:
				return true 
		return false

	func check_similar(essence_):
		return essence_.word.element == word.element &&  essence_.num.rank == num.rank 

class Demesne:
	var word = {}
	var arr = {}
	var obj = {}

	func _init(input_):
		word.windrose = input_.windrose
		obj.carte = input_.carte
		arr.zone = []

	func set_chain():
		pass

class Carte:
	var num = {}
	var arr = {}
	var vec = {}
	var flag = {}
	var dict = {}

	func _init():
		num.round = 1
		num.resets = 0
		flag.domain = false
		flag.essence = false
		flag.success = true
		dict.connection = {}
		init_zones()
		init_frontieres()
		init_secteurs()
		update_zone_flags()
		init_districts()
		set_domains()
		
		if flag.success:
			print("total resets: ", num.resets)
			set_windroses()
			auto_fill_wells()
			update_connections()
			init_demesnes()
			#recolor_zones()
			#color_districts()
		check_reset()

	func init_zones():
		arr.zone = []
		arr.well = []
		arr.ejection = []
		arr.essence = []
		arr.connection = []
		
		for _i in Global.num.carte.rows:
			arr.zone.append([])
			
			for _j in Global.num.carte.cols:
				var input = {}
				input.grid = Vector2(_j,_i)
				input.carte = self
				var zone = Classes.Zone.new(input)
				arr.zone[_i].append(zone)
		
		vec.center = Vector2(Global.num.carte.cols,Global.num.carte.rows)*Global.num.zone.a/2 + Global.vec.carte
		set_zone_neighbors()
		set_waves()

	func set_zone_neighbors():
		for zones in arr.zone:
			for zone in zones:
				for vec in Global.arr.neighbor:
					var grid = zone.vec.grid + vec

					if check_border(grid):
						var neighbor = arr.zone[grid.y][grid.x]
						
						if !zone.arr.neighbor.has(neighbor):
							zone.arr.neighbor.append(neighbor)
							neighbor.arr.neighbor.append(zone)
							zone.arr.delimited.append(neighbor)
							neighbor.arr.delimited.append(zone)

	func set_waves():
		pass

	func init_frontieres():
		arr.frontiere = []
		var a = Global.num.secteur.a+Global.num.frontiere.a
		
		for _i in Global.num.carte.rows:
			for _j in Global.num.carte.cols:
				var y = (_i+1)%a
				var x = (_j+1)%a
				
				if x == 0 && _i == 0:
					var input = {}
					input.carte = self
					input.row = null
					input.col = _j
					var frontiere = Classes.Frontiere.new(input)
					arr.frontiere.append(frontiere)
				
				if y == 0 && _j == 0:
					var input = {}
					input.carte = self
					input.row = _i
					input.col = null
					var frontiere = Classes.Frontiere.new(input)
					arr.frontiere.append(frontiere)
		
		for frontiere in arr.frontiere:
			if frontiere.num.row == null:
				for zones in arr.zone:
					zones[frontiere.num.col].arr.frontiere.append(frontiere)
			
			if frontiere.num.col == null:
				for zone in arr.zone[frontiere.num.row]:
					zone.arr.frontiere.append(frontiere)

	func init_secteurs():
		arr.secteur = []
		var unsecteured = []
		
		for zones in arr.zone:
			for zone in zones:
				if zone.arr.frontiere.size() == 0:
					unsecteured.append(zone)
		
		while unsecteured.size() > 0:
			var previous = [[unsecteured.pop_front()]]
			
			while previous.back().size() > 0:
				var next = []
				
				for zone in previous.back():
					for neighbor in zone.arr.neighbor:
						if unsecteured.has(neighbor):
							next.append(neighbor)
							unsecteured.erase(neighbor)
				
				previous.append(next)
			
			var input = {}
			input.carte = self
			var secteur = Classes.Secteur.new(input)
			
			for zones in previous:
				for zone in zones:
					secteur.arr.zone.append(zone)
					zone.obj.secteur = secteur
					
			arr.secteur.append(secteur)

	func update_zone_flags():
		var intersections = []
		for zones in arr.zone:
			for zone in zones:
				zone.flag.onto.intersection = zone.arr.frontiere.size() > 1
				zone.flag.onto.frontiere = zone.arr.frontiere.size() > 0
				zone.flag.onto.secteur = zone.obj.secteur != null
				
				if zone.flag.onto.intersection:
					intersections.append(zone)
		
		for zones in arr.zone:
			for zone in zones:
				zone.flag.near.border = zone.check_near_border()
				if zone.flag.near.border:
					arr.well.append(zone)
				
				if !zone.flag.onto.frontiere:
					var flag_ = false
					
					for neighbor in zone.arr.neighbor:
						flag_ = flag_ || neighbor.flag.onto.frontiere
					
					zone.flag.near.frontiere = flag_
		
		for intersection in intersections:
			for vec in Global.arr.neighbor:
				var grid = intersection.vec.grid
				
				for _i in Global.num.intersection.line:
					grid += vec
					arr.zone[grid.y][grid.x].obj.line = intersection
			
			for vec in Global.arr.point:
				var grid = intersection.vec.grid
				
				for _i in Global.num.intersection.diagonal:
					grid += vec
					arr.zone[grid.y][grid.x].obj.diagonal = intersection

	func init_districts():
		arr.district = []
		init_associates()
		set_district_neighbors()
		merge_small_districts()
		set_biggest_districts()

	func init_associates():
		var unused = []
		
		for zones in arr.zone:
			for zone in zones:
				unused.append(zone)
		
		while unused.size() > 0:
			generate_associate(unused)

	func generate_associate(unused_):
		var input = {}
		input.carte = self
		var district = Classes.District.new(input)
		arr.district.append(district)
		var begin = corner_zone(unused_)
		district.add_zone(begin)
		var zones = [begin]
		Global.rng.randomize()
		var size = Global.rng.randi_range(Global.num.associate.min, Global.num.associate.max)
		
		while zones.size() < size:
			var options = []
			
			for zone in zones:
				for neighbor in zone.arr.neighbor:
					if neighbor.obj.district == null:
						options.append(neighbor)
			
			if options.size() > 0:
				Global.rng.randomize()
				var index_r = Global.rng.randi_range(0, options.size()-1)
				var option = options[index_r]
				unused_.erase(option)
				zones.append(option)
				district.add_zone(option)
			else:
				size = 0

	func corner_zone(unused_):
		var min_neighbor = Global.arr.neighbor.size()
		var options = []
		
		for zone in unused_:
			if min_neighbor > zone.arr.delimited.size():
				min_neighbor = zone.arr.delimited.size()
		
		for zone in unused_:
			if min_neighbor == zone.arr.delimited.size():
				options.append(zone)
		
		var mid = round(Global.num.carte.half)
		var max_far_away = 0
		
		for option in options:
			var d = abs(mid-option.vec.grid.x)+abs(mid-option.vec.grid.y)
			
			if d > max_far_away:
				max_far_away = d
		
		var options_2 = []
		
		for option in options:
			var d = abs(mid-option.vec.grid.x)+abs(mid-option.vec.grid.y)
		
			if d == max_far_away:
				options_2.append(option)
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options_2.size()-1) 
		var option = options_2[index_r]
		unused_.erase(option)
		option.flag.free = false
		return option

	func set_district_neighbors():
		for district in arr.district:
			for zone in district.arr.zone:
				for neighbor in zone.arr.neighbor:
					if neighbor.obj.district != zone.obj.district && neighbor.obj.district != null:
						if !district.arr.neighbor.has(neighbor.obj.district):
							district.arr.neighbor.append(neighbor.obj.district)
							neighbor.obj.district.arr.neighbor.append(district)

	func merge_small_districts():
		var datas = []
		
		for district in arr.district:
			if district.arr.zone.size() < Global.num.associate.min:
				var data = {}
				data.district = district
				data.value = district.arr.zone.size()
				datas.append(data)
		
		datas.sort_custom(Sorter, "sort_ascending")
		
		for data in datas:
			var datas_2 = []
			
			for neighbor in data.district.arr.neighbor:
				var data_2 = {}
				data_2.neighbor = neighbor
				data_2.value = neighbor.arr.zone.size()
				datas_2.append(data_2)
			
			datas_2.sort_custom(Sorter, "sort_ascending")
			datas_2.front().neighbor.merge_with(data.district)

	func set_biggest_districts():
		var datas = []
		var bans = []
		
		for district in arr.district:
			var data = {}
			data.district = district
			data.value = district.arr.zone.size()
			datas.append(data)
		
		datas.sort_custom(Sorter, "sort_descending")
		
		for _i in Global.arr.domain:
			var district = datas.pop_front().district
			
			while bans.has(district):
				district = datas.pop_front().district
			
			bans.append(district)
			var datas_2 = []
			
			for neighbor in district.arr.neighbor:
				if !bans.has(neighbor):
					var data = {}
					data.neighbor = neighbor
					data.value = neighbor.arr.zone.size()
					datas_2.append(data)
			
			datas_2.sort_custom(Sorter, "sort_descending")
			
			if datas_2.size() >= Global.num.associate.biggest:
				for _j in Global.num.associate.biggest:
					var neighbor = datas_2.pop_front().neighbor
					district.merge_with(neighbor)
					bans.append(neighbor)
			else:
				flag.success = false

	func set_domains():
		var domains = []
		var biggest = []
		var datas = []
		
		for district in arr.district:
			var data = {}
			data.district = district
			data.value = district.arr.zone.size()
			datas.append(data)
		
		datas.sort_custom(Sorter, "sort_descending")
		
		while !flag.domain:
			domains = [] 
			biggest = []
			flag.domain = true
			
			for _i in Global.arr.domain:
				domains.append(0)
				biggest.append(_i)

			for data in datas:
				var district = data.district
				
				if district.arr.domain.size() > 1:
					Global.rng.randomize()
					
					if data.value > Global.num.associate.max:
						var index_r = Global.rng.randi_range(0, biggest.size()-1)
						district.arr.domain = [biggest[index_r]]
						biggest.pop_at(index_r)
					else:
						var index_r = Global.rng.randi_range(0, district.arr.domain.size()-1)
						district.arr.domain = [district.arr.domain[index_r]]
						
					for neighbor in district.arr.neighbor:
						neighbor.update_domain_by(district, true)
				else:
					#flag.success = false
					pass
			
			for district in arr.district:
				domains[district.arr.domain.front()] += district.arr.zone.size()

		for district in arr.district:
			for zone in district.arr.zone:
				if district.arr.domain.size() == 1:
					var hue = float(district.arr.domain.front())/Global.arr.domain.size()
					zone.color.background = Color().from_hsv(hue,1,1) 
		
		#rint(domains)

	func set_windroses():
		var center = Vector2(Global.num.carte.half,Global.num.carte.half)
		
		for zones in arr.zone:
			for zone in zones:
				var vec = center-zone.vec.grid
				vec /= max(abs(vec.x),abs(vec.y))
				
				if abs(vec.x) != 1:
					vec.x = 0
				if abs(vec.y) != 1:
					vec.y = 0
				
				for key in Global.dict.windrose.keys():
					if Global.dict.windrose[key] == vec:
						zone.word.windrose = key
						
						var f = zone.word.windrose
						var grid = zone.vec.grid
						grid += Global.dict.windrose[zone.word.windrose]
						zone.obj.heir = arr.zone[grid.y][grid.x]

	func generate_essence(zone_):
		var input = {}
		input.carte = self
		input.zone = zone_
		input.rank = 0
		var options = []
		
		for _i in Global.arr.element.size():
			var n = pow(Global.arr.element.size()-_i,2)
			
			for element in Global.arr.element[_i]:
				for _j in n:
					options.append(element)
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size()-1)
		input.element = options[index_r]
		var essence = Classes.Essence.new(input)
		arr.essence.append(essence)

	func drop_essences():
		for essence in arr.essence:
			if essence.check_drop_end():
				essence.obj.zone.drop_essence()
		
		arr.well.append_array(arr.ejection)
		arr.ejection = []
		fill_wells()

	func fill_wells():
		while arr.well.size() > 0:
			generate_essence(arr.well.pop_front())
		
		flag.essence = arr.essence.size() == Global.num.zone.count

	func auto_fill_wells():
		while !flag.essence:
			drop_essences()

	func update_connections():
		for essence in arr.essence:
			if !dict.connection.keys().has(essence):
				dict.connection[essence] = [essence]
			
			for neighbor in essence.obj.zone.arr.neighbor:
				if essence.check_similar(neighbor.obj.essence):
					if !dict.connection[essence].has(neighbor.obj.essence):
						dict.connection[essence].append(neighbor.obj.essence)
					
					if !dict.connection.keys().has(neighbor.obj.essence):
						dict.connection[neighbor.obj.essence] = [neighbor.obj.essence]
						
					if !dict.connection[neighbor.obj.essence].has(essence):
						dict.connection[neighbor.obj.essence].append(essence)
		
		var checked = false
		
		while !checked:
			checked = true
			
			for first in dict.connection.keys():
				for second in dict.connection[first]:
					for third in dict.connection[second]:
						#print(dict.connection[second],first)
						if !dict.connection[third].has(first):
							checked = false
							connect_connection(first, third)
		
		for key in dict.connection:
			if dict.connection[key].size() > 2:
				key.num.a *= 1.5

	func connect_connection(first_, second_):
		var essences = []
		essences.append_array(dict.connection[first_])
		
		for essence in dict.connection[second_]:
			if !essences.has(essence):
				essences.append(essence)
		
		for essence in essences:
			for essence_ in essences:
				if !dict.connection[essence].has(essence_):
					dict.connection[essence].append(essence_)
		

	func init_demesnes():
		pass

	func recolor_zones():
		for zones in arr.zone:
			for zone in zones:
				zone.update_color()

	func color_districts():
		for _i in arr.district.size():
			for zone in arr.district[_i].arr.zone:
				var hue = float(_i)/float(arr.district.size())
				zone.color.background = Color().from_hsv(hue,1,1) 

	func check_border(grid_):
		return grid_.x >= 0 && grid_.x < Global.num.carte.cols && grid_.y >= 0 && grid_.y < Global.num.carte.rows

	func check_reset():
		if !flag.success:
			arr = []
			num.resets += 1
			_init()

class Sorter:
	static func sort_ascending(a, b):
		if a.value < b.value:
			return true
		return false

	static func sort_descending(a, b):
		if a.value > b.value:
			return true
		return false
