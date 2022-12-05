extends Node


class Zone:
	var num = {}
	var word = {}
	var vec = {}
	var arr = {}
	var flag = {}
	var color = {}
	var obj = {}
	var dict = {}

	func _init(input_):
		num.wave = -1
		num.ring = -1
		word.windrose = ""
		vec.grid = input_.grid
		vec.center = input_.grid*Global.num.zone.a + Global.vec.carte
		obj.carte = input_.carte
		dict.potential = {}
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
		arr.dominanceline = []
		arr.bid = []
		arr.bidline = []

	func init_objs():
		obj.secteur = null
		obj.diagonal = null
		obj.line = null
		obj.district = null
		obj.essence = null
		obj.heir = self
		obj.demesne = null
		obj.stronghold = null
		obj.dominance = null
		obj.private = null

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
		for point in Global.arr.diagonal:
			var vertex = point * Global.num.zone.a/2 + vec.center
			arr.point.append(vertex)

	func drop_essence():
		if obj.heir.obj.essence == null:
			obj.essence.obj.zone = obj.heir
			obj.heir.obj.essence = obj.essence
			obj.essence = null
			
			if obj.heir.obj.essence.num.vertexs > 2:
				obj.heir.obj.essence.update_points()
		
		if flag.near.border:
			obj.carte.arr.ejection.append(self)

	func update_color():
		if flag.onto.frontiere:
			color.background = Color.orange
		if flag.onto.secteur:
			color.background = Color.green
		if flag.onto.intersection:
			color.background = Color.red
		if flag.near.frontiere:
			color.background = Color.aqua
		if flag.near.border:
			color.background = Color.purple
		if flag.near.intersection:
			color.background = Color.yellow

	func color_flag(key_, name_):
		if flag[key_][name_]:
			color.background = Color.black
		else:
			color.background = Color.white

	func check_near_border():
		return vec.grid.x == 0 || vec.grid.x == Global.num.carte.cols-1 || vec.grid.y == 0 || vec.grid.y == Global.num.carte.rows-1

	func check_trigger(data_):
		if data_.place == "carte":
			return true
		
		if !Global.dict.trigger.exception.has(data_.place):
			if flag[data_.subplace][data_.place]:
				return true
		else:
			match data_.place:
				"demesne":
					for stronghold in data_.strongholds:
						if stronghold.arr.dominance.has(self):
							return true
				"ally":
					for stronghold in data_.strongholds:
						if stronghold.arr.dominance.has(self):
							return true
				"bid":
					for stronghold in data_.strongholds:
						if stronghold.arr.bid.has(self):
							return true
				"private":
					for stronghold in data_.strongholds:
						if obj.private == stronghold:
							return true
		
		return false

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
		num.index = Global.num.primary_key.district
		Global.num.primary_key.district += 1
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
	var arr = {}
	var obj = {}
	var color = {}

	func _init(input_):
		num.rank = 0
		num.vertexs = input_.vertexs
		num.a = Global.num.zone.a/3
		word.element = input_.element
		obj.zone = input_.zone
		obj.carte = input_.carte
		obj.zone.obj.essence = self
		color.background = Global.color.essence[word.element]

	func growth(value_):
		if num.vertexs == 0:
			num.vertexs = value_
		else:
			num.rank += value_-1
		
		update_points()

	func update_points():
		arr.point = []
		
		for _i in num.vertexs:
			var angle = PI+PI*2/num.vertexs*_i
			var vertex = Vector2(Global.num.essence.a*sin(angle),Global.num.essence.a*cos(angle))
			vertex += obj.zone.vec.center
			arr.point.append(vertex)

	func check_drop_end():
		if obj.zone.obj.heir.obj.essence == null:
			if obj.zone.obj.heir == obj.zone.obj.heir.obj.heir || obj.zone.obj.heir.word.windrose == obj.zone.word.windrose:
				return true 
		return false

	func check_similar(essence_):
		return essence_.word.element == word.element && essence_.num.vertexs == num.vertexs 

class Stronghold:
	var num = {}
	var word = {}
	var arr = {}
	var obj = {}
	var dict = {}
	var flag = {}

	func _init(input_):
		num.index = Global.num.primary_key.stronghold
		Global.num.primary_key.stronghold += 1
		obj.carte = input_.carte
		obj.zone = input_.zone
		obj.zone.obj.stronghold = self
		obj.zone.obj.demesne.arr.stronghold.append(self)
		obj.demesne = obj.zone.obj.demesne
		arr.neighbor = []
		arr.dominance = []
		arr.borderline = []
		add_dominance(obj.zone)
		flag.continuity = true
		dict.relationship = {}
		init_privates()

	func init_privates():
		obj.carte.arr.zone[obj.zone.vec.grid.y][obj.zone.vec.grid.x].obj.private = self
		var neighbors = []
		neighbors.append_array(Global.arr.diagonal)
		neighbors.append_array(Global.arr.neighbor)
		
		for neighbor in neighbors:
			var grid = obj.zone.vec.grid + neighbor
			
			if obj.carte.check_border(grid):
				obj.carte.arr.zone[grid.y][grid.x].obj.private = self

	func set_triggers():
		var sizes = []
		var datas = []
		var words = ["carte","private"]
		
		for pool in obj.carte.arr.pool:
			var check = false
			
			if pool.place == "ally":
				if dict.relationship.keys().has(pool.strongholds.front()):
					if dict.relationship[pool.strongholds.front()].num.value > 0:
						check = true #data.zones.append_array(pool.zones.size())
			else:
				check = pool.strongholds.has(self)
				
			if check || pool.strongholds.front() == null:
				#for condition in Global.dict.trigger.condition.keys():
				#	for subcondition in Global.dict.trigger.condition[condition]:
						
						
						#if subcondition == "generated":
						
				var data = {}
				data.place = pool.place
				data.subplace = pool.subplace
				data.zones = []
				
				if Global.dict.trigger.dominance.has(pool.place):
					for zone in pool.zones:
						if zone.obj.dominance == self:
							data.zones.append(zone)
				else:
					match pool.place:
						"ally":
							if num.index == 0:
								print(dict.relationship.keys())
								print(self,pool.strongholds.front())
							data.zones.append_array(pool.zones)
						"bid":
							if pool.strongholds.front() == self:
								data.zones.append_array(pool.zones)
						"private":
							if pool.strongholds.front() == self:
								data.zones.append_array(pool.zones)
				
				data.value = Global.num.trigger.max-Global.get_index_trigger_sequence(data.zones.size())
				data.size = data.zones.size()
				data.zones = []
				
				if data.size > 0:
					datas.append(data)
					
					if num.index == 0:
						print(data)
					
					if !sizes.has(pool.zones.size()):
						sizes.append(pool.zones.size())
					
					
					#if !words.has(datas.back().place):
					#	print(self,datas.back())
				
		datas.sort_custom(Sorter, "sort_ascending")
		
#		var input = {}
#		input.place = 
#		input.condition = input_.condition
#		input.subtype = input_.subtype
#		input.value = input_.values
#		input.stronghold = input.stronghold

	func add_dominance(zone_):
		if zone_.obj.dominance != null && zone_.obj.dominance != self:
			zone_.obj.dominance.arr.dominance.erase(zone_)
		
		zone_.obj.dominance = self
		arr.dominance.append(zone_)

	func get_chain():
		flag.continuity = true
		var result = {}
		result.zones = [obj.zone]
		result.chains = [[obj.zone]]
		
		while flag.continuity:
			var neighbors = []
			flag.continuity = false
			
			for zone in result.zones:
				for neighbor in zone.arr.neighbor:
					if arr.dominance.has(neighbor) && !result.zones.has(neighbor) && !neighbors.has(neighbor):
						neighbors.append(neighbor)
			
			if neighbors.size() > 0:
				flag.continuity = neighbors.size() > 0
				result.zones.append_array(neighbors)
				result.chains.append(neighbors)
		
		return result

	func check_continuity():
		flag.continuity = true
		var result = get_chain()
		
		if result.zones.size() != arr.dominance.size():
			for _i in range(arr.dominance.size()-1,-1,-1):
				var zone = arr.dominance[_i]
				
				if !result.zones.has(zone):
					arr.dominance.erase(zone)

	func check_ally():
		var ally = false
		
		for stronghold in dict.relationship:
			if dict.relationship[stronghold].num.value > 0:
				ally = true
		
		return ally

	func get_ally():
		for stronghold in dict.relationship:
			if dict.relationship[stronghold].num.value > 0:
				return stronghold
		
		return null

class Relationship:
	var num = {}
	var arr = {}
	var obj = {}
	var color = {}

	func _init(input_):
		num.value = -1
		obj.carte = input_.carte
		arr.stronghold = input_.strongholds
		arr.stronghold.front().dict.relationship[arr.stronghold.back()] = self 
		arr.stronghold.back().dict.relationship[arr.stronghold.front()] = self 
		arr.point = []
		arr.point.append(arr.stronghold.front().obj.zone.vec.center)
		arr.point.append(arr.stronghold.back().obj.zone.vec.center)
		color.line = Color.black

	func add_value(value_):
		num.value += value_
		
		if num.value > 0:
			color.line = Color.webgray
		if num.value < 0:
			color.line = Color.black

class Demesne:
	var word = {}
	var arr = {}
	var obj = {}

	func _init(input_):
		word.region = input_.region
		obj.carte = input_.carte
		arr.zone = []
		arr.stronghold = []
		
		for zone in input_.zones:
			add_zone(zone)

	func add_zone(zone_):
		arr.zone.append(zone_)
		zone_.obj.demesne = self

	func forfeit_zone(zone_):
		arr.zone.erase(zone_)
		zone_.obj.demesne = null

class Task:
	var word = {}
	var arr = {}
	var obj = {}

	func _init(input_):
		word.region = input_.region

class Trigger:
	var word = {}
	var arr = {}
	var obj = {}

	func _init(input_):
		word.subplace = input_.subplace
		word.place = input_.place
		word.condition = input_.condition
		word.subcondition = input_.subcondition
		arr.value = input_.values
		arr.zone = input_.zones
		obj.stronghold = input_.stronghold

class Carte:
	var num = {}
	var arr = {}
	var vec = {}
	var flag = {}
	var dict = {}

	func _init():
		num.round = 1
		num.resets = 0
		dict.connection = {}
		init_flags()
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
			init_demesnes()
			init_strongholds()
			find_potential_connections()
			#recolor_zones()
			#color_districts()
			change_zones_color()
		
		check_reset()

	func init_flags():
		flag.domain = false
		flag.essence = false
		flag.limit = false
		flag.success = true
		flag.dominance = true

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
		set_sectors()

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
		var n = Global.arr.diagonal.size()
		var wave = 0
		var grid = Vector2(Global.num.carte.half,Global.num.carte.half)
		arr.zone[grid.y][grid.x].num.wave = wave
		arr.zone[grid.y][grid.x].num.ring = wave
		wave += 1
		
		for _i in range(1,Global.num.carte.half+1):
			
			for _j in n:
				grid = Vector2(Global.num.carte.half,Global.num.carte.half)
				grid.x += Global.arr.diagonal[_j].x*_i
				grid.y += Global.arr.diagonal[_j].y*_i
				arr.zone[grid.y][grid.x].num.wave = wave
				arr.zone[grid.y][grid.x].num.ring = _i
				var direction = {}
				direction.first = Global.arr.neighbor[(_j+2)%n]
				direction.second = Global.arr.neighbor[(_j+3)%n]
				
				for _k in _i+1:
					arr.zone[grid.y+direction.first.y*_k][grid.x+direction.first.x*_k].num.wave = wave+_k
					arr.zone[grid.y+direction.second.y*_k][grid.x+direction.second.x*_k].num.wave = wave+_k
					arr.zone[grid.y+direction.first.y*_k][grid.x+direction.first.x*_k].num.ring = _i
					arr.zone[grid.y+direction.second.y*_k][grid.x+direction.second.x*_k].num.ring = _i
					
			wave += _i+1

	func set_sectors():
		var zone_counters = []
		var sum = 0
		
		for _i in Global.num.carte.rings:
			zone_counters.append(0)
		
		for zones in arr.zone:
			for zone in zones:
				if zone.num.ring != -1:
					zone_counters[zone.num.ring] += 1
					sum += 1
		
		var sector_sums = []
		var sector_begins = [0]
		var sector_ends = []
		
		for _i in Global.num.carte.sectors:
			sector_sums.append(0)
		
		for _i in zone_counters.size():
			if sector_ends.size() < sector_sums.size():
				sector_sums[sector_ends.size()] += zone_counters[_i]
				
				if sector_sums[sector_ends.size()] >= sum/Global.num.carte.sectors:
					if sector_ends.size() < Global.num.carte.sectors:
						sector_sums[sector_ends.size()] -= zone_counters[_i]
					
					sector_ends.append(_i-1)
					
					if sector_ends.size() != Global.num.carte.sectors:
						sector_sums[sector_ends.size()] += zone_counters[_i]
						sector_begins.append(sector_ends.back()+1)
					else:
						sector_sums[sector_ends.size()-1] += zone_counters[_i]
		
		if sector_ends.size() == Global.num.carte.sectors:
			sector_ends.pop_back()
		
		sector_ends.append(Global.num.carte.rings-1)
		var ring_to_sector = []
		
		for _i in Global.num.carte.sectors:
			for ring_ in sector_ends[_i]-sector_begins[_i]+1:
				ring_to_sector.append(_i)
		
		for zones in arr.zone:
			for zone in zones:
				zone.num.sector = ring_to_sector[zone.num.ring]

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
					arr.zone[grid.y][grid.x].flag.near.intersection = true
			
			for vec in Global.arr.diagonal:
				var grid = intersection.vec.grid
				
				for _i in Global.num.intersection.diagonal:
					grid += vec
					arr.zone[grid.y][grid.x].obj.diagonal = intersection
					arr.zone[grid.y][grid.x].flag.near.intersection = true

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
				var option = Global.get_random_element(options)
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
		
		var option = Global.get_random_element(options_2)
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
					if data.value > Global.num.associate.max:
						district.arr.domain = [Global.get_random_element(biggest)]
						biggest.erase(district.arr.domain.front())
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
				var grid = center-zone.vec.grid
				grid /= max(abs(grid.x),abs(grid.y))
				
				if abs(grid.x) != 1:
					grid.x = 0
				if abs(grid.y) != 1:
					grid.y = 0
				
				for key in Global.dict.windrose.keys():
					if Global.dict.windrose[key] == grid:
						zone.word.windrose = key
						var f = zone.word.windrose
						grid = zone.vec.grid
						grid += Global.dict.windrose[zone.word.windrose]
						zone.obj.heir = arr.zone[grid.y][grid.x]
						break

	func generate_essence(zone_):
		var input = {}
		input.carte = self
		input.zone = zone_
		input.vertexs = 0
		var options = []
		
		for _i in Global.arr.element.size():
			var n = pow(Global.arr.element.size()-_i,2)
			
			for element in Global.arr.element[_i]:
				for _j in n:
					options.append(element)
		
		input.element = Global.get_random_element(options)
		var essence = Classes.Essence.new(input)
		arr.essence.append(essence)

	func drop_essences():
		for essence in arr.essence:
			if essence.check_drop_end():
				essence.obj.zone.drop_essence()
		
		arr.well.append_array(arr.ejection)
		arr.ejection = []
		fill_wells()
		
		var essences = []
		var zones = []
		
		for zones_ in arr.zone:
			for zone in zones_:
				if zone.obj.essence != null:
					essences.append(zone.obj.essence)
		
		for essence in arr.essence:
			zones.append(essence.obj.zone)
		
		if flag.essence:
			update_connections()
			merge_connections()

	func fill_wells():
		while arr.well.size() > 0:
			generate_essence(arr.well.pop_front())
		
		flag.essence = arr.essence.size() == Global.num.zone.count

	func auto_fill_wells():
		while !flag.essence:
			drop_essences()

	func update_connections():
		dict.connection = {}
		
		for essence in arr.essence:
			if !dict.connection.keys().has(essence):
				dict.connection[essence] = [essence]
			
			for neighbor in essence.obj.zone.arr.neighbor:
				if neighbor.obj.essence != null:
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
						if !dict.connection[third].has(first):
							checked = false
							connect_connection(first, third)

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

	func merge_connections():
		flag.limit = false
		
		for key in dict.connection.keys():
			limit_connection(key)
		
		for key in dict.connection.keys():
			if dict.connection.keys().has(key):
				if dict.connection[key].size() >= Global.num.connection.min:
					var anchor = find_anchor(dict.connection[key])
					merge_essence_with(anchor)
		
		if flag.limit:
			update_connections()
			merge_connections()
			
		flag.essence = arr.essence.size() == Global.num.zone.count
		auto_fill_wells()

	func limit_connection(key_):
		var connection = []
		connection.append_array(dict.connection[key_])
		
		while connection.size() > Global.num.connection.max:
			flag.limit = true
			var head = connection.front()
			var datas = []
			
			for essence in dict.connection[head]:
				var data = {}
				data.essence = essence
				data.value = 0
				
				for neighbor in essence.obj.zone.arr.neighbor:
					if dict.connection[head].has(neighbor.obj.essence):
						data.value += 1
				
				datas.append(data)
		
			datas.sort_custom(Sorter, "sort_ascending")
			var tail = datas.front().essence
			connection.erase(tail)
			dict.connection[tail] = [tail]
			
			for essence in connection:
				dict.connection[essence].erase(tail)

	func find_anchor(connection_):
		var datas = []
		
		for essence in connection_:
			var data = {}
			data.essence = essence
			data.value = 0
			
			for neighbor in essence.obj.zone.arr.neighbor:
				if connection_.has(neighbor.obj.essence):
					data.value += 1
			
			datas.append(data)
		
		datas.sort_custom(Sorter, "sort_descending")
		
		for _i in range(datas.size()-1,-1,-1):
			if datas[_i].value < datas.front().value:
				datas.erase(datas[_i])
		
		for data in datas:
			data.value = data.essence.obj.zone.num.wave
			
		datas.sort_custom(Sorter, "sort_ascending")
		return datas.front().essence

	func merge_essence_with(anchor_):
		var essences = []
		essences.append_array(dict.connection[anchor_])
		anchor_.growth(essences.size())
		
		for essence in essences:
			if anchor_ != essence:
				essence.obj.zone.obj.essence = null
				arr.essence.erase(essence)
				dict.connection.erase(essence)
				
				if essence.obj.zone.flag.near.border:
					arr.well.append(essence.obj.zone)
			else:
				dict.connection[essence] = [essence]

	func init_demesnes():
		arr.demesne = []
		
		for region in Global.arr.region:
			var input = {}
			input.region = region
			input.carte = self
			input.zones = []
			
			for zones in arr.zone:
				for zone in zones:
					if zone.word.windrose == region[0] && zone.word.windrose.length() == 1 && zone.num.sector != 0:
						input.zones.append(zone)
					if region == "Center" && zone.num.sector == 0:
						input.zones.append(zone)
			
			var demesne = Classes.Demesne.new(input)
			arr.demesne.append(demesne)
		
		for demesne in arr.demesne:
			if demesne.word.region != "Center":
				var forfeits = []
				
				for zone in demesne.arr.zone:
					for neighbor in zone.arr.neighbor:
						if neighbor.obj.demesne == null || neighbor.obj.demesne.word.region == "Center":
							if !forfeits.has(zone):
								forfeits.append(zone)
				
				for zone in forfeits:
					demesne.forfeit_zone(zone)

	func init_strongholds():
		arr.stronghold  = []
		var total_options = []
		
		for demesne in arr.demesne:
			for zone in demesne.arr.zone:
				if !zone.flag.near.border:
					total_options.append(zone)
		
		fill_demesne(["Center"],total_options)
		fill_demesne(["North","East","South","West"],total_options)
		set_dominances()
		set_stronghold_relationships()
		prepare_stronghold_essences()
		init_triggers_pool()

	func fill_demesne(demesnes_,total_options_):
		var options = []
		
		for demesne in arr.demesne:
			if demesnes_.has(demesne.word.region):
				for zone in demesne.arr.zone:
					if total_options_.has(zone):
						options.append(zone)
				
		while options.size() > 0:
			var input = {}
			input.zone = Global.get_random_element(options)
			input.carte = self
			var stronghold = Classes.Stronghold.new(input)
			arr.stronghold.append(stronghold)
			var arounds = [input.zone]
			
			for _i in Global.num.stronghold.estrangement:
				for _j in range(arounds.size()-1,-1,-1):
					for neighbor in arounds[_j].arr.neighbor:
						if !arounds.has(neighbor):
							arounds.append(neighbor)
			
			for around in arounds:
				options.erase(around)
				total_options_.erase(around)

	func set_dominances():
		var zones = {}
		
		for demesne in arr.demesne:
			zones[demesne] = []
		
		for zones_ in arr.zone:
			for zone in zones_:
				if zone.obj.demesne != null && zone.obj.dominance == null:
					zones[zone.obj.demesne].append(zone)
		
		next_dominances(zones)
		print("dominance size: ",arr.stronghold.front().arr.dominance.size())
		set_borderlines()
		update_demesnes()

	func next_dominances(zones_):
		var stop = false
		
		while !stop:
			var surroundeds = []
			var datas = []
			
			for stronghold in arr.stronghold:
				var data = {}
				data.stronghold = stronghold
				data.value = 0
				data.options = []
				
				for zone in stronghold.arr.dominance:
					for neighbor in zone.arr.neighbor:
						if !data.options.has(neighbor) && neighbor.obj.dominance == null && neighbor.obj.demesne == stronghold.obj.zone.obj.demesne:
							if neighbor.obj.private == null || neighbor.obj.private == stronghold:
								data.options.append(neighbor)
				
				data.value = data.options.size()
				datas.append(data)
			
			while datas.size() > 0:
				datas.sort_custom(Sorter, "sort_ascending")
				var data = datas.pop_front()
				
				if data.options.size() > 0:
					var neighbor = Global.get_random_element(data.options)
					data.stronghold.add_dominance(neighbor)
					zones_[neighbor.obj.demesne].erase(neighbor)
					
					for data_ in datas:
						data_.options.erase(neighbor)
				else:
					surroundeds.append(data.stronghold)
			
			if surroundeds.size() > 0:
				fix_dominance_inequality(1,zones_)
			
			for demesne in zones_.keys():
				if zones_[demesne].size() < demesne.arr.stronghold.size():
					stop = true
		
		if !flag.dominance:
			fix_dominance_inequality(-1,zones_)

	func fix_dominance_inequality(shift_,zones_):
		if !flag.dominance:
			flag.dominance = true
		
		var datas = []
		
		for stronghold in arr.stronghold:
			var data = {}
			data.stronghold = stronghold
			data.value = stronghold.arr.dominance.size()
			datas.append(data)
		
		datas.sort_custom(Sorter, "sort_ascending")
		
		while datas.front().value != datas.back().value && flag.dominance:
			var stronghold = null
			var options = []
			
			match shift_:
				1:
					stronghold = datas.front().stronghold
					
					for zone in stronghold.arr.dominance:
						for neighbor in zone.arr.neighbor:
							if !options.has(neighbor) && neighbor.obj.dominance == null:
								if neighbor.obj.private == null || neighbor.obj.private == stronghold:
									options.append(neighbor)
				-1:
					stronghold = datas.back().stronghold
					var result = stronghold.get_chain()
					options.append_array(result.chains.back())
			
			if options.size() > 0:
				var zone = Global.get_random_element(options)
				
				match shift_:
					1:
						stronghold.add_dominance(zone)
						datas.front().value += shift_
					-1:
						stronghold.arr.dominance.erase(zone)
						zone.obj.dominance = null
						zones_[stronghold.obj.demesne].append(zone)
						datas.back().value += shift_
					
				datas.sort_custom(Sorter, "sort_ascending")
			else:
				flag.dominance = false

	func set_borderlines():
		for stronghold in arr.stronghold:
			for zone in stronghold.arr.dominance:
				for neighbor in zone.arr.neighbor:
					if neighbor.obj.dominance != zone.obj.dominance:
						var vector = zone.vec.center-neighbor.vec.center
						vector = vector.normalized()
						var index = Global.arr.neighbor.find(vector)
						var n = zone.arr.point.size()
						var begin = zone.arr.point[(index+1)%n]
						var end = zone.arr.point[(index+2)%n]
						zone.arr.dominanceline.append([begin,end])
				
				if zone.arr.dominanceline.size() > 0:
					stronghold.arr.borderline.append(zone)

	func update_demesnes():
		for demesne in arr.demesne:
			for _i in range(demesne.arr.zone.size()-1,-1,-1):
				demesne.forfeit_zone(demesne.arr.zone[_i])
				
			for stronghold in demesne.arr.stronghold:
				for zone in stronghold.arr.dominance:
					demesne.add_zone(zone)

	func set_stronghold_relationships():
		arr.relationship = []
		set_stronghold_bids()
		
		for stronghold in arr.stronghold:
			for zone in stronghold.arr.bid: 
				if zone.arr.bid.size() > 1:
					for stronghold_ in zone.arr.bid:
						if stronghold_ != stronghold:
							if !stronghold.dict.relationship.keys().has(stronghold_):
								var data = {}
								data.carte = self
								data.strongholds = [stronghold_,stronghold]
								var relationship = Classes.Relationship.new(data)
								arr.relationship.append(relationship)
		
		find_allys()

	func set_stronghold_bids():
		for stronghold in arr.stronghold:
			stronghold.arr.bid = []
			stronghold.arr.bid.append_array(stronghold.arr.dominance)
			
			for zone in stronghold.arr.dominance:
				for neighbor in zone.arr.neighbor:
					if !stronghold.arr.bid.has(neighbor):
						if neighbor.obj.private == null || neighbor.obj.dominance == null:
							stronghold.arr.bid.append(neighbor)
			
			for zone in stronghold.arr.bid: 
				zone.arr.bid.append(stronghold)
		
		for stronghold in arr.stronghold:
			for zone in stronghold.arr.bid:
				for neighbor in zone.arr.neighbor:
					if !neighbor.arr.bid.has(stronghold) || (neighbor.obj.dominance == null && !stronghold.arr.bid.has(neighbor)):
						var vector = zone.vec.center-neighbor.vec.center
						vector = vector.normalized()
						var index = Global.arr.neighbor.find(vector)
						var n = zone.arr.point.size()
						var begin = Global.arr.diagonal[(index+1)%n]*Global.num.dominanceline.a
						begin += zone.vec.center
						var end = Global.arr.diagonal[(index+2)%n]*Global.num.dominanceline.a
						end += zone.vec.center
						zone.arr.bidline.append([begin,end])

	func find_allys():
		var datas = []
		var ally_value = 2
		
		for stronghold in arr.stronghold:
			var data = {}
			data.stronghold = stronghold
			data.value = 0 
			data.relationships = []
			
			for key in stronghold.dict.relationship.keys():
				if key.obj.zone.obj.demesne == stronghold.obj.zone.obj.demesne:
					data.relationships.append(key)
					data.value += 1
			
			datas.append(data)
		
		datas.sort_custom(Sorter, "sort_ascending")
		
		while datas.size() > 0:
			var data = datas.pop_front()
			
			if data.relationships.size() > 0:
				var ally = Global.get_random_element(data.relationships)
				var relationship = data.stronghold.dict.relationship[ally]
				relationship.add_value(ally_value)
				
				for _i in range(datas.size()-1,-1,-1):
					var data_ = datas[_i]
					
					for stronghold in relationship.arr.stronghold:
						data_.relationships.erase(stronghold)
					
						if stronghold == data_.stronghold:
							datas.erase(data_)
				datas.sort_custom(Sorter, "sort_ascending")

	func prepare_stronghold_essences():
		var stop = false
		
		while !stop:
			stop = true
			
			for essence in arr.essence:
				if essence.num.vertexs > 0:
					essence.num.vertexs = 0
					stop = false
					
				if essence.obj.zone.obj.stronghold != null && Global.arr.element.back().has(essence.word.element):
					essence.word.element = Global.get_random_element(Global.arr.element.front())
					essence.color.background = Global.color.essence[essence.word.element]
					stop = false
		
			if !stop:
				update_connections()
				merge_connections()
				auto_fill_wells()
		
		for stronghold in arr.stronghold:
			stronghold.obj.zone.obj.essence.num.vertexs = 6
		
		for zones in arr.zone:
			for zone in zones:
				zone.obj.essence.update_points()

	func init_triggers_pool():
#		var sizes = []
#		for stronghold in arr.stronghold:
#			if !sizes.has(stronghold.arr.dominance.size()):
#				sizes.append(stronghold.arr.dominance.size())
#		print(sizes)
		
		arr.pool = []
		
		for subplace in Global.dict.trigger.place.keys():
			for place in Global.dict.trigger.place[subplace]:
				var strongholds = [[null]]
				
				if Global.dict.trigger.exception.has(place):
					strongholds = []
					
					match place:
						"demesne":
							for demesne in arr.demesne:
								var strongholds_ = []
								
								for stronghold in demesne.arr.stronghold:
									strongholds_.append(stronghold)
									
								strongholds.append(strongholds_)
						"ally":
							for stronghold in arr.stronghold:
								var ally = stronghold.get_ally()
								
								if ally != null:
									strongholds.append([ally])
						"bid":
							for stronghold in arr.stronghold:
								strongholds.append([stronghold])
						"private":
							for stronghold in arr.stronghold:
								strongholds.append([stronghold])
				
				for strongholds_ in strongholds:
					var data = {}
					data.subplace = subplace
					data.place = place
					#data.condition = condition
					#data.subcondition = subcondition
					data.zones = []
					data.strongholds = strongholds_
					
					for zones in arr.zone:
						for zone in zones:
							if zone.check_trigger(data):
								data.zones.append(zone)
					
					data.value = data.zones.size()
					arr.pool.append(data)
		
		set_stronghold_triggers()

	func set_stronghold_triggers():
		for stronghold in arr.stronghold:
			stronghold.set_triggers()

	func find_potential_connections():
		update_connections()
		
		for zones in arr.zone:
			for zone in zones:
				zone.dict.potential = {}
		
		for zones in arr.zone:
			for zone in zones:
				for neighbor in zone.arr.neighbor:
					var potential = true
					
					for key in zone.dict.potential.keys():
						if neighbor.obj.essence.check_similar(key):
							potential = false
							zone.dict.potential[key].append(neighbor.obj.essence)
				
					if potential:
						zone.dict.potential[neighbor.obj.essence] = []
						zone.dict.potential[neighbor.obj.essence].append(neighbor.obj.essence)
				
				for essence in zone.dict.potential.keys():
					if zone.dict.potential[essence].size() == 1:
						zone.dict.potential.erase(essence)
		
		order_potentials()

	func order_potentials():
		dict.potential = {}
		var datas = []
		
		for demesne in arr.demesne:
			dict.potential[demesne] = []
		
		for demesne in arr.demesne:
			for zone in demesne.arr.zone:
				for essence in zone.dict.potential.keys(): 
					var data = {}
					data.demesne = demesne
					data.zone = zone
					data.essence = essence
					data.value = 1
					var min_ = Global.num.connection.max
					
					for key in zone.dict.potential[essence]:
						data.value += dict.connection[key].size()
						
						if min_ > dict.connection[key].size():
							min_ = dict.connection[key].size()
					
					data.value -= min_
					
					if data.value >= Global.num.connection.min:
						dict.potential[demesne].append(data)
			
			dict.potential[demesne].sort_custom(Sorter, "sort_descending")
			
			if dict.potential[demesne].size() > 0:
				datas.append(dict.potential[demesne].front())
		
		datas.sort_custom(Sorter, "sort_descending")
		Global.num.potential.demesne = arr.demesne.find(datas.front().demesne)
		Global.num.potential.zone = dict.potential[datas.front().demesne].find(datas.front())

	func change_zones_color():
		for zones in arr.zone:
			for zone in zones:
				color_zone_as(zone,Global.arr.layer[Global.num.layer.current])

	func color_zone_as(zone_,layer_):
		zone_.color.background = Color.white
		
		match layer_:
			"Dominance":
				if zone_.obj.dominance != null:
					var hue = float(zone_.obj.dominance.num.index)/float(arr.stronghold.size())
					zone_.color.background = Color().from_hsv(hue,1,1) 
					
					if zone_.obj.stronghold != null:
						zone_.color.background = Color().from_hsv(hue,1,0.75)
			"Demesne":
				if zone_.obj.demesne != null:
					zone_.color.background = Global.color.region[zone_.obj.demesne.word.region]
			"Windrose":
				var _i = Global.dict.windrose.keys().find(zone_.word.windrose)
				
				if _i != -1:
					var hue = float(_i)/float(Global.dict.windrose.keys().size())
					zone_.color.background = Color().from_hsv(hue,1,1) 
			"District":
				var hue = float(zone_.obj.district.num.index)/float(arr.district.size())
				zone_.color.background = Color().from_hsv(hue,1,1) 
			"Flag":
				zone_.update_color()
			"Sector":
				var hue = float(zone_.num.sector)/float(Global.num.carte.sectors)
				zone_.color.background = Color().from_hsv(hue,1,1)
			"Potential":
				var demesne = arr.demesne[Global.num.potential.demesne]
				
				if zone_ == dict.potential[demesne][Global.num.potential.zone].zone:
					zone_.color.background = Color.gray

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
