extends Node


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
			find_best_task_solution()
			#recolor_zones()
			#color_districts()
			change_zones_color()
			flag.game = true
			
#			for stronghold in arr.stronghold:
#				rint(stronghold.obj.task.obj.trigger.word, stronghold.obj.task.arr.zone.size())
#				for zone in stronghold.obj.task.arr.zone:
#					rint(zone.vec.grid)
		
		check_reset()

	func init_flags():
		flag.domain = false
		flag.essence = false
		flag.limit = false
		flag.success = true
		flag.dominance = true
		flag.game = false

	func init_zones():
		arr.zone = []
		arr.well = []
		arr.ejection = []
		arr.essence = []
		arr.connection = []
		arr.picked = []
		
		for _i in Global.num.carte.rows:
			arr.zone.append([])
			
			for _j in Global.num.carte.cols:
				var input = {}
				input.grid = Vector2(_j,_i)
				input.carte = self
				var zone = Classes_1.Zone.new(input)
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
					var frontiere = Classes_1.Frontiere.new(input)
					arr.frontiere.append(frontiere)
				
				if y == 0 && _j == 0:
					var input = {}
					input.carte = self
					input.row = _i
					input.col = null
					var frontiere = Classes_1.Frontiere.new(input)
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
			var secteur = Classes_1.Secteur.new(input)
			
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
		var district = Classes_1.District.new(input)
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
		dict.windrose_reflect = {}
		var center = Vector2(Global.num.carte.half,Global.num.carte.half)
		
		for key in Global.dict.windrose.keys():
			if key.length() == 1:
				dict.windrose_reflect[key] = []
		
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
						zone.arr.heir = [arr.zone[grid.y][grid.x]]
						arr.zone[grid.y][grid.x].arr.ancestor = [zone]
						
						if key.length() == 1:
							var vecs = zone.get_row_and_col()
							
							for vec_ in vecs:
								if !dict.windrose_reflect[Global.dict.windrose_reflect[key]].has(vec_):
									dict.windrose_reflect[Global.dict.windrose_reflect[key]].append(vec_)
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
		var essence = Classes_1.Essence.new(input)
		arr.essence.append(essence)

	func drop_essences():
		for essence in arr.essence:
			if essence.obj.zone.check_drop_end():
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
			
			var demesne = Classes_1.Demesne.new(input)
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
		init_stronghold_tasks()
		set_heirs_and_ancestors()

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
			var stronghold = Classes_1.Stronghold.new(input)
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
		
		for stronghold in arr.stronghold:
			stronghold.set_equilibrium()
		
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
								var relationship = Classes_1.Relationship.new(data)
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
					
					if Global.dict.trigger.subexception.has(place):
						for stronghold in arr.stronghold:
							strongholds.append([stronghold])
				
				for strongholds_ in strongholds:
					var data = {}
					data.subplace = subplace
					data.place = place
					data.zones = []
					data.strongholds = strongholds_
					
					if data.place == "windrose_reflect":
						data.equilibrium = Global.get_random_element(dict.windrose_reflect[strongholds_.front().word.equilibrium])
					
					for zones in arr.zone:
						for zone in zones:
							if zone.check_trigger(data):
								data.zones.append(zone)
					
					arr.pool.append(data)
		
		set_stronghold_triggers()

	func set_stronghold_triggers():
		dict.trigger = {}
		
		for condition in Global.dict.trigger.condition.keys():
			for subcondition in Global.dict.trigger.condition[condition]:
				if !dict.trigger.keys().has(subcondition):
					dict.trigger[subcondition] = []
		
		for stronghold in arr.stronghold:
			stronghold.set_triggers()

	func init_stronghold_tasks():
		for stronghold in arr.stronghold:
			stronghold.refill_tasks()

	func set_heirs_and_ancestors():
		for stronghold in arr.stronghold:
			print(stronghold.num.index)
			stronghold.obj.zone.update_ancestor()
			pass

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

	func get_zone_for_merge(task_):
		var datas = []
		
		for zone in task_.obj.trigger.arr.zone:
			if task_.arr.element.has(zone.obj.essence.word.element):
				for essence in zone.dict.potential.keys(): 
					var data = {}
					data.zone = zone
					data.essence = essence
					data.value = 1
					var min_ = Global.num.connection.max
					
					for key in zone.dict.potential[essence]:
						data.value += dict.connection[key].size()
						
						if min_ > dict.connection[key].size():
							min_ = dict.connection[key].size()
					
					data.value -= min_
					
					if data.value >= Global.num.connection.min && task_.arr.vertexs.has(data.value):
						datas.append(data)
		
		datas.sort_custom(Sorter, "sort_descending")
		return datas

	func find_best_task_solution():
		var strongholds_ = arr.stronghold
		var datas = []
		
		for stronghold in strongholds_:
			for task in stronghold.arr.task:
				if task.obj.trigger.word.subcondition == "merged":
					#if stronghold.num.index == 0:
					#	rint("@@@")
					var datas_ = get_zone_for_merge(task)
					datas.append(datas_)
		
					#rint(datas_)

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

	func pick_zone(event_):
		var vec_ = event_.position-Global.vec.carte
		var x = stepify(vec_.x,Global.num.zone.a)/Global.num.zone.a
		var y = stepify(vec_.y,Global.num.zone.a)/Global.num.zone.a
		var grid = Vector2(x,y)
		
		if check_border(grid):
			arr.picked.append(arr.zone[grid.y][grid.x])
			arr.zone[grid.y][grid.x].flag.picked = true
			
			if arr.picked.size() >= Global.num.zone.picked:
				picked_action()
				
			#for task in arr.zone[grid.y][grid.x].dict.task["infiltrated"]:
			#	if task.obj.trigger.word.place == "windrose_reflect":
			#		rint(task.obj.client)

	func picked_action():
		for picked in arr.picked:
			picked.flag.picked = false
		
		if arr.picked.front() == arr.picked.back():
			arr.picked = []
			return
		
		if arr.picked.front().arr.neighbor.has(arr.picked.back()):
			swap_near()
		
		arr.picked = []

	func swap_near():
		swap_by_zones(arr.picked)
		update_connections()
		merge_connections()

	func swap_by_zones(zones_):
		var swap = true
		var essences = [zones_.front().obj.essence,zones_.back().obj.essence]
		
		for essence in essences:
			if Global.dict.essence[essence.num.vertexs] == "Castle":
				swap = false
		
		if swap:
			#rint("swaped")
			zones_.front().obj.essence = essences.back()
			zones_.back().obj.essence = essences.front()
			essences.front().obj.zone = zones_.back()
			essences.back().obj.zone = zones_.front()
			essences.front().update_points()
			essences.back().update_points()

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
