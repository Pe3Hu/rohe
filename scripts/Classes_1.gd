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
		dict.task = {}
		init_arrs()
		init_objs()
		init_flags()
		set_points() 
		color.background = Color().from_hsv(0,0,1.0)
		
		for condition in Global.dict.trigger.condition.keys():
			for subcondition in Global.dict.trigger.condition[condition]:
				if !dict.task.keys().has(subcondition):
					dict.task[subcondition] = []

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
		num.task = {}
		num.task.max = Global.num.task.max
		obj.carte = input_.carte
		obj.zone = input_.zone
		obj.zone.obj.stronghold = self
		obj.zone.obj.demesne.arr.stronghold.append(self)
		obj.demesne = obj.zone.obj.demesne
		init_arrs()
		add_dominance(obj.zone)
		flag.continuity = true
		dict.relationship = {}
		init_privates()

	func init_arrs():
		arr.neighbor = []
		arr.dominance = []
		arr.borderline = []
		arr.trigger = []
		arr.task = []

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
							data.zones.append_array(pool.zones)
						"bid":
							if pool.strongholds.front() == self:
								data.zones.append_array(pool.zones)
						"private":
							if pool.strongholds.front() == self:
								data.zones.append_array(pool.zones)
				
				#data.value = Global.num.trigger.max-Global.get_index_trigger_sequence(data.zones.size())
				
				if data.zones.size() > 0:
					datas.append(data)
		
		for data in datas:
			for condition in Global.dict.trigger.condition.keys():
				for subcondition in Global.dict.trigger.condition[condition]:
					var values = []
					
					if condition == "element" && subcondition == "infiltrated":
						for values_ in Global.dict.trigger.value[condition]:
							if values_.size() == 1 && values_.front() == get_main_element():
								values = values_
					if condition == "vertexs" && subcondition == "merged":
						values = Global.dict.trigger.value[condition].front()
					
					if values.size() > 0:
						var input = {}
						input.place = data.place
						input.subplace = data.subplace
						input.condition = condition
						input.subcondition = subcondition
						input.zones = data.zones
						#input.reward = data.value
						input.values = values
						input.stronghold = self
						var trigger = Classes_1.Trigger.new(input)
						
						if (trigger.flag.reiterated && subcondition == "infiltrated") || subcondition == "merged":
							arr.trigger.append(trigger)
							obj.carte.dict.trigger[subcondition].append(trigger)

	func add_dominance(zone_):
		if zone_.obj.dominance != null && zone_.obj.dominance != self:
			zone_.obj.dominance.arr.dominance.erase(zone_)
		
		zone_.obj.dominance = self
		arr.dominance.append(zone_)

	func refill_tasks():
		while arr.task.size() < num.task.max:
			issue_task()

	func issue_task():
		var input = {}
		var options = []
		
		for trigger in arr.trigger:
			if trigger.flag.reiterated:
				var already = false
				
				for task in arr.task:
					if task.obj.trigger == trigger:
						already = true
				
				if !already:
					options.append(trigger)
		
		if options.size() > 0:
			input.repeat = Global.num.task.reiterated
			input.trigger = Global.get_random_element(options)
			input.element = input.trigger.arr.value
			input.vertexs = [0]
		else:
			input.repeat = Global.num.task.standart
			var values = []
			
			for trigger in arr.trigger:
				if !trigger.flag.reiterated:
					var n = Global.get_index_trigger_sequence(trigger.arr.zone.size())
					
					for _i in n:
						options.append(trigger)
			
			input.trigger = Global.get_random_element(options)
			input.element = Global.dict.trigger.value["element"].front()
			input.vertexs = input.trigger.arr.value
		
		input.rewards = Global.spread(input.trigger.num.reward,input.repeat)
		input.stronghold = self
		var task = Classes_1.Task.new(input)
		
		if num.index == 0:
			print(input.trigger.num.reward,input.rewards,input.repeat,input.trigger.word)
	
		arr.task.append(task)

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

	func get_ally():
		for stronghold in dict.relationship:
			if dict.relationship[stronghold].num.value > 0:
				return stronghold
		
		return null

	func get_main_element():
		return obj.zone.obj.essence.word.element

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
	var flag = {}

	func _init(input_):
		arr.reward = input_.rewards
		arr.performer = []
		arr.element = input_.element
		arr.vertexs = input_.vertexs
		obj.trigger = input_.trigger
		obj.client = input_.stronghold
		
		for zone in obj.trigger.arr.zone:
			zone.dict.task[obj.trigger.word.subcondition].append(self)

	func complete():
		if arr.performer.size() >= arr.reward.size():
			get_rewards()

	func get_rewards():
		pass

class Trigger:
	var num = {}
	var word = {}
	var arr = {}
	var obj = {}
	var flag = {}

	func _init(input_):
		word.subplace = input_.subplace
		word.place = input_.place
		word.condition = input_.condition
		word.subcondition = input_.subcondition
		arr.value = input_.values
		arr.zone = input_.zones
		obj.stronghold = input_.stronghold
		calc_reward()
		check_reiterated()

	func calc_reward():
		num.reward = Global.num.trigger.max-Global.get_index_trigger_sequence(arr.zone.size())

	func check_reiterated():
		flag.reiterated = true
		
		for data in Global.dict.task.reiterated:
			for key in word.keys():
				flag.reiterated = flag.reiterated && data[key] == word[key]
		
		#if reiterated && obj.stronghold.num.index == 0:
		#	print("reiterated",word)
