extends Node


var rng = RandomNumberGenerator.new()
var dict = {}
var num = {}
var arr = {}
var obj = {}
var node = {}
var flag = {}
var vec = {}
var color = {}

func init_num():
	init_primary_key()
	
	num.secteur = {}
	num.secteur.a = 5
	num.secteur.b = 5
	num.secteur.n = 4
	
	num.frontiere = {}
	num.frontiere.a = 1
	num.frontiere.b = 3
	num.frontiere.n = 3
	
	num.carte = {}
	num.carte.n = num.secteur.a*num.secteur.n+num.frontiere.a*num.frontiere.n
	num.carte.cols = num.carte.n
	num.carte.rows = num.carte.n
	num.carte.half = min(num.carte.cols,num.carte.rows)/2
	num.carte.l = min(dict.window_size.width,dict.window_size.height)*0.9
	num.carte.rings = num.carte.half+1
	num.carte.demesnes = 5
	num.carte.sectors = num.carte.demesnes
	
	num.zone = {}
	num.zone.count = num.carte.cols*num.carte.rows
	num.zone.a = num.carte.l/min(num.carte.cols,num.carte.rows)
	num.zone.picked = 2
	
	num.intersection = {}
	num.intersection.diagonal = 2
	num.intersection.line = 2
	
	num.associate = {}
	num.associate.min = 9
	num.associate.max = 16
	num.associate.biggest = 2
	
	num.rank = {}
	num.rank.current = -1
	
	num.essence = {}
	num.essence.a = num.zone.a*0.4
	
	num.connection = {}
	num.connection.max = 6
	num.connection.min = 3
	
	num.stronghold = {}
	num.stronghold.estrangement = 5
	num.stronghold.a = num.zone.a*0.25
	
	num.diplomacy = {}
	num.diplomacy.zone = num.stronghold.estrangement*2+1
	num.diplomacy.width = 1
	
	num.dominanceline = {}
	num.dominanceline.a = num.zone.a*0.45
	num.dominanceline.width = 1
	
	num.layer = {}
	num.layer.current = 0#arr.layer.size()-2
	
	num.potential = {}
	num.potential.demesne = 0
	num.potential.zone = 0
	
	num.trigger = {}
	num.trigger.min = num.connection.min-1
	num.trigger.max = num.carte.n
	
	num.task = {}
	num.task.max = 2
	num.task.reiterated = 10
	num.task.standart = 3
	
	init_trigger()

func init_primary_key():
	num.primary_key = {}
	num.primary_key.district = 0
	num.primary_key.secteur = 0
	num.primary_key.stronghold = 0

func init_dict():
	init_window_size()
	
	dict.windrose = {
		"N":  Vector2( 0, 1),
		"NE": Vector2(-1, 1),
		"E":  Vector2(-1, 0),
		"SE": Vector2(-1,-1),
		"S":  Vector2( 0,-1),
		"SW": Vector2( 1,-1),
		"W":  Vector2( 1, 0),
		"NW": Vector2( 1, 1)
	}
	
	var n = dict.windrose.keys().size()
	dict.drop = {}
	dict.windrose_reflect = {}
	
	for _i in n:
		var key = dict.windrose.keys()[_i]
		var shifted_index = (_i+n+n/2)%n
		var drop = dict.windrose.keys()[shifted_index]
		dict.drop[key] = dict.windrose[drop]
		dict.windrose_reflect[key] = dict.windrose.keys()[shifted_index]

func init_trigger():
	dict.trigger = {}
	dict.trigger.place = {
		"onto": ["carte","demesne","ally","bid","private","intersection","frontiere","secteur","windrose_reflect"],
		"near": ["intersection","frontiere","border"]
	}
	dict.trigger.condition = {
		"element": ["generated","infiltrated","merged"],
		"vertexs" : ["infiltrated","merged"]
	}
	dict.trigger.value = {
		"element": [[]],
		"vertexs": []
	}
	dict.trigger.exception = ["demesne","ally","bid","private","windrose_reflect"]
	dict.trigger.subexception = ["bid","private","windrose_reflect"]
	dict.trigger.dominance = ["intersection","frontiere","secteur","border"]
#	}
#		"demesne": ["demesne"],
#		"stronghold": ["ally","bid","private"]
#	}
	
	for _i in range(num.connection.min,num.connection.max+1,1):
		var values = []
		
		for _j in range(_i,num.connection.max+1,1):
			values.append(_j)
		
		dict.trigger.value["vertexs"].append(values)
	
	for elements in arr.element:
		for element in elements:
			dict.trigger.value["element"].front().append(element)
			dict.trigger.value["element"].append([element])
	
	init_trigger_sequence()
	
	dict.task = {}
	dict.task.reiterated = []
	var data = {
		"condition": "element", 
		"place": "bid", 
		"subcondition": "infiltrated", 
		"subplace": "onto"
	}
	dict.task.reiterated.append(data)
	data = {
		"condition": "element", 
		"place": "windrose_reflect", 
		"subcondition": "infiltrated", 
		"subplace": "onto"
	}
	dict.task.reiterated.append(data)
	
	dict.essence = {
		0: "",
		3: "",
		4: "",
		5: "",
		6: "Castle"
	}

func init_trigger_sequence():
	var _i = 3
	var value = 9
	arr.sequence["B000000"] = [0]
	
	while arr.sequence["B000000"].back() < num.zone.count:
		arr.sequence["B000000"].append(value)
		value += arr.sequence["A000040"][_i]
		_i += 1
	
	num.trigger.max = arr.sequence["B000000"].size()-1

func init_window_size():
	dict.window_size = {}
	dict.window_size.width = ProjectSettings.get_setting("display/window/size/width")
	dict.window_size.height = ProjectSettings.get_setting("display/window/size/height")
	dict.window_size.center = Vector2(dict.window_size.width/2, dict.window_size.height/2)
	
	OS.set_current_screen(1)

func init_arr():
	arr.sequence = {} 
	arr.sequence["A000040"] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
	arr.sequence["A000045"] = [89, 55, 34, 21, 13, 8, 5, 3, 2, 1, 1]
	arr.sequence["A000124"] = [7, 11, 16] #, 22, 29, 37, 46, 56, 67, 79, 92, 106, 121, 137, 154, 172, 191, 211]
	arr.sequence["A001358"] = [4, 6, 9, 10, 14, 15, 21, 22, 25, 26]
	arr.diagonal = [
		Vector2( 1,-1),
		Vector2( 1, 1),
		Vector2(-1, 1),
		Vector2(-1,-1)
	]
	arr.neighbor = [
		Vector2( 0,-1),
		Vector2( 1, 0),
		Vector2( 0, 1),
		Vector2(-1, 0)
	]
	
	arr.domain = [0,1,2,3,4,5,6]
	arr.element = [["Aqua","Wind","Fire","Earth"],["Ice","Storm","Lava","Plant"]]
	arr.region = ["North","East","South","West","Center"]
	#arr.layer = ["Demesne","Flag"]#,"Sector"
	arr.layer = ["Dominance","Demesne","Windrose","District","Potential","Flag"]
	sumProp(31,"М","Р")
	sumProp(22,"С","Т")
	sumProp(154323,"М","И")
	sumProp(154323,"М","Т")
	sumProp(40397012251,"М","Д")
	sumProp(40397012251,"Ж","В")
	sumProp(40397012251,"С","П")

func init_node():
	node.TimeBar = get_node("/root/Game/TimeBar") 
	node.Game = get_node("/root/Game") 

func init_flag():
	flag.click = false
	flag.stop = false

func init_vec():
	vec.carte = dict.window_size.center-Vector2(num.carte.cols,num.carte.rows)*num.zone.a/2

func init_color():
	color.essence = {
		"Aqua": Color.from_hsv(230.0/360.0,1,1),
		"Wind": Color.from_hsv(150.0/360.0,0.8,1),
		"Fire": Color.from_hsv(0.0/360.0,1,1),
		"Earth": Color.from_hsv(60.0/360.0,1,1),
		"Ice": Color.from_hsv(185.0/360.0,1,1),
		"Storm": Color.from_hsv(270.0/360.0,1,1),
		"Lava": Color.from_hsv(300.0/360.0,0.8,1),
		"Plant": Color.from_hsv(120.0/360.0,1,0.6)
	}
	color.region = {
		"North": Color.from_hsv(185.0/360.0,1,1),
		"East": Color.from_hsv(60.0/360.0,1,1),
		"South": Color.from_hsv(230.0/360.0,1,1),
		"West": Color.from_hsv(0.0/360.0,1,1),
		"Center": Color.from_hsv(120.0/360.0,1,0.6)
	}

func _ready():
	init_dict()
	init_arr()
	init_num()
	init_node()
	init_flag()
	init_vec()
	init_color()

func next_zone_layer():
	num.layer.current = (num.layer.current+1)%arr.layer.size()
	obj.carte.change_zones_color()

func next_potential_connection():
	var demesne = obj.carte.arr.demesne[num.potential.demesne]
	var previous = obj.carte.dict.potential[demesne][num.potential.zone].zone
	num.potential.zone += 1
	
	if  obj.carte.dict.potential[demesne].size() <= num.potential.zone:
		num.potential.zone = 0
		num.potential.demesne += 1
		
		if  obj.carte.arr.demesne.size() <= num.potential.demesne:
			num.potential.demesne = 0
		
		demesne = obj.carte.arr.demesne[num.potential.demesne]
	
	var next = obj.carte.dict.potential[demesne][num.potential.zone].zone
	obj.carte.color_zone_as(previous,"Potential")
	obj.carte.color_zone_as(next,"Potential")

func custom_log(value_,base_): 
	return log(value_)/log(base_)

func cross_diplomacys(diplomacys_):
	var zones = []
	
	for diplomacy in diplomacys_:
		for stronghold in diplomacy.arr.stronghold:
			if !zones.has(stronghold.obj.zone):
				zones.append(stronghold.obj.zone)
	
	if zones.size() != 4:
		return false
	var x1 = diplomacys_[0].arr.stronghold.front().obj.zone.vec.center.x
	var y1 = diplomacys_[0].arr.stronghold.front().obj.zone.vec.center.y
	var x2 = diplomacys_[0].arr.stronghold.back().obj.zone.vec.center.x
	var y2 = diplomacys_[0].arr.stronghold.back().obj.zone.vec.center.y
	var x3 = diplomacys_[1].arr.stronghold.front().obj.zone.vec.center.x
	var y3 = diplomacys_[1].arr.stronghold.front().obj.zone.vec.center.y
	var x4 = diplomacys_[1].arr.stronghold.back().obj.zone.vec.center.x
	var y4 = diplomacys_[1].arr.stronghold.back().obj.zone.vec.center.y
	
	if cross(x1,y1,x2,y2,x3,y3,x4,y4):
		diplomacys_[0].flag.cross = true
		diplomacys_[1].flag.cross = true
		return true
	else:
		return false

func cross(x1_,y1_,x2_,y2_,x3_,y3_,x4_,y4_):
	var n = -1
	
	if y2_-y1_ != 0:
		var q = (x2_-x1_)/(y1_-y2_)
		var sn = (x3_-x4_)+(y3_-y4_)*q
		if !sn:
			return false
		var fn = (x3_-x1_)+(y3_-y1_)*q
		n = fn/sn
	else:
		if !(y3_-y4_):
			return false
		n = (y3_-y1_)/(y3_-y4_)
		
	var x = x3_+(x4_-x3_)*n
	var y = y3_+(y4_-y3_)*n
	
	var first = min(x1_,x2_) <= x && x <= max(x1_,x2_) && min(y1_,y2_) <= y && y <= max(y1_,y2_)
	var second = min(x3_,x4_) <= x && x <= max(x3_,x4_) && min(y3_,y4_) <= y && y <= max(y3_,y4_)
	return first && second

func get_random_element(arr_):
	rng.randomize()
	var index_r = rng.randi_range(0, arr_.size()-1)
	return arr_[index_r]

func get_index_trigger_sequence(value_):
	var index = 0
	
	while arr.sequence["B000000"][index] < value_:
		index += 1
	
	return index

func spread(value_,n_):
	var arr_ = []
	
	for _i in n_:
		arr_.append(1)
	
	for _i in value_-n_:
		rng.randomize()
		var index_r = rng.randi_range(0, arr_.size()-1)
		arr_[index_r] += 1
	
	return arr_

func sumProp(nSum, sGender, sCase_):
	var result = ""
	var n = nSum
	var nums = []
	var strs = []
	var exponents = [
		[],
		["","тысяча","тысячи","тысяч"],
		["","миллион","миллиона","миллионов"],
		["","миллиард","миллиарда","миллиардов"]
	]
	
	var gender = {
		"Ж":
			{
				"один": "одна",
				"два": "две"
			},
		"М":
			{
				
			},
		"С":
			{
				
			}
	}
	
	var options = [
		[
			#число взависимости от позиции
			["ноль","один","два","три","четыре","пять","шесть","семь","восемь","девять"],
			#суффикс числа взависимости от позиции
			["","надцать","двенадцать","надцать","четырнадцать","надцать","надцать","надцать","надцать","надцать"]
		],
		[
			#суффикс числа взависимости от позиции
			["","десять","дцать","дцать","сорок","десят","десят","десят","десят","девяносто"]
		],
		[
			#суффикс числа взависимости от позиции
			["","сто","двести","ста","ста","сот","сот","сот","сот","сот"]
		]
	]
	#суффиксы/слова с уникальными правилами
	var exclusions = ["десять","двенадцать","четырнадцать","сорок","девяносто","сто","двести"]
	
	#разбиение числа на десятки
	while n > 0:
		var remainder = n%10
		nums.append(remainder)
		n = n/10
	
	if nums.size() > 12:
		result = "Превышен лимит размера"
		return
	
	var _i = nums.size()-1
	
	while _i > 0:
		var _j = (_i%3)
		var indexs = []
		
		while _j >= 0:
			indexs.append(_j)
			_j -= 1
		
		_i -= indexs.size()
		
		for _k in indexs.size():
			indexs[_k] += _i+1
		
		indexs.invert()
		
		#формирование слова в зависимсоти от значения числа и разряда позиции
		for _k in range(indexs.size()-1,-1,-1):
			var str_ = ""
			var flag_ = true 
			var index = nums[indexs[_k]]
			var options_ = options[_k][0]
			str_ = options[0][0][index]
			
			if _k == 0:
				if indexs.size() > 1:
					if nums[indexs[1]] == 1:
						options_ = options[_k][1]
						
						if exclusions.has(options_[index]):
							str_ = options_[index]
				
				if index == 0:
					str_ = ""
		
			if _k == 1:
				flag_ = nums[indexs[_k]] != 1
			
			if flag_:
				if _k > 0:
					if index == 0:
						str_ = ""
					
					if exclusions.has(options_[index]):
						str_ = options_[index]
					else:
						str_ += options_[index]
			
				if str_.length() > 0:
					#преобразование рода
					if gender[sGender].keys().has(str_):
						str_ = gender[sGender][str_]
					
					strs.append(str_)
				
				#добоваление степени десяти
				var exponent_index = 0
				
				if nums[indexs[0]] > 0:
					exponent_index = 1
				if nums[indexs[0]] > 1:
					exponent_index = 2
				if nums[indexs[0]] > 4:
					exponent_index = 3
				
				if indexs.size() > 1:
					if nums[indexs[1]] == 1:
						exponent_index = 3
					if nums[indexs[0]] == 0:
						exponent_index = 3
				
				var exponent = (_i+3)/3
				
				if exponent > 0:
					str_ = exponents[(_i+3)/3][exponent_index]
				
					if _k == 0 && str_.length() > 0:
						strs.append(str_)
	
	var directory = {
		"И": {
			"ноль": "",
			"один": "",
			"одна": "",
			"два": "",
			"две": "",
			"три": "",
			"четыре": "",
			"пять": "",
			"шесть": "",
			"семь": "",
			"восемь": "",
			"девять": "",
			"десять": "",
			"надцать": "",
			"дцать": "",
			"сорок": "",
			"десят": "",
			"сто": "",
			"двести": "",
			"ста": "",
			"сот": "",
			"тысяча": "",
			"тысячи": "",
			"тысяч": "",
			"миллион": "",
			"миллиона": "",
			"миллионов": "",
			"миллиард": "",
			"миллиарда": "",
			"миллиардов": ""
			},
		"Р": {
			"ноль": "нуля",
			"один": "одного",
			"одна": "одной",
			"два": "двух",
			"две": "двух",
			"три": "трёх",
			"четыре": "четырёх",
			"сорок": "сорока",
			"сто": "ста",
			"тысяча": "тысячи",
			"тысячи": "тысяч",
			"миллион": "миллиона",
			"миллиона": "миллионов",
			"миллиард": "миллиарда",
			"миллиарда": "миллиардов"
			},
		"Д": {
			"ноль": "нулю",
			"один": "одному",
			"одна": "одной",
			"два": "двум",
			"две": "двум",
			"три": "трём",
			"четыре": "четырём",
			"сорок": "сорока",
			"сто": "ста",
			"двести": "двумстам",
			"тысяча": "тысяче",
			"тысячи": "тысячам",
			"тысяч": "тысячам",
			"миллион": "миллиону",
			"миллиона": "миллионам",
			"миллионов": "миллионам",
			"миллиард": "миллиарду",
			"миллиарда": "миллиардам",
			"миллиардов": "миллиардам"
			},
		"В": {
			"ноль": "нуля",
			"один": "одного",
			"одна": "одной",
			"два": "двух",
			"две": "двух",
			"тысяча": "тысячу",
			"тысяч": "тысячи",
			"миллиона": "миллионов",
			"миллиарда": "миллиардов"
			},
		"Т": {
			"ноль": "нолём",
			"один": "одним",
			"одна": "одной",
			"два": "двумя",
			"две": "двумя",
			"три": "тремя",
			"четыре": "четырьмя",
			"надцать": "надцатью",
			"дцать": "дцатью",
			"сорок": "сорока",
			"десят": "десятью",
			"сто": "ста",
			"двести": "двумястами",
			"ста": "стами",
			"сот": "юстами",
			"тысяча": "тысячей",
			"тысячи": "тысячами",
			"тысяч": "тысячами",
			"миллион": "миллионом",
			"миллиона": "миллионами",
			"миллионов": "миллионами",
			"миллиард": "миллиардом",
			"миллиарда": "миллиардами",
			"миллиардов": "миллиардами"
			},
		"П": {
			"ноль": "ноле",
			"один": "одном",
			"одна": "одной",
			"два": "двух",
			"две": "двух",
			"три": "трех",
			"четыре": "четырех",
			"надцать": "надцати",
			"дцать": "дцати",
			"сорок": "сорока",
			"десят": "десяти",
			"сто": "ста",
			"двести": "двухстах",
			"ста": "стах",
			"сот": "стах",
			"тысяча": "тысяче",
			"тысячи": "тысячах",
			"тысяч": "тысячах",
			"миллион": "миллионе",
			"миллиона": "миллионах",
			"миллионов": "миллионах",
			"миллиард": "миллиарде",
			"миллиарда": "миллиардах",
			"миллиардов": "миллиардах"
			}
		}
	
	var total_directory = {
		"Р": "и",
		"Д": "и",
		"В": "",
		"Т": "ю",
		"П": "и",
	}
	
	if sCase_ != "И":
		for _j in strs.size():
			var prefix = ""
			var suffix = ""
			
			for _k in range(strs[_j].length()-1,-1,-1):
				if !directory["И"].keys().has(suffix):
					suffix = suffix.insert(0,strs[_j][_k])
				else:
					prefix = prefix.insert(0,strs[_j][_k])
			
			
			if directory[sCase_].keys().has(suffix):
				if directory[sCase_].keys().has(prefix) && suffix != "дцать":
					prefix = directory[sCase_][prefix]
				
				suffix = directory[sCase_][suffix]
			else:
				var l = strs[_j].length()-total_directory[sCase_].length()
				prefix = strs[_j].substr(0,l)
				
				if sCase_ == "Д" && strs[_j].count("десят") > 0:
					prefix = strs[_j]
					
				suffix = total_directory[sCase_]
				
				#print(prefix,total_directory[sCase_].length())
			strs[_j] = prefix + suffix
			
	for str_ in strs:
		result += str_ + " "
		
	print(nSum, " ", sGender, " ", sCase_, ": ", result)
	return result
	


#
#					if flag_:
#						match nums[value]:
#							0: 
#								str_ += "ноль"
#							1: 
#								str_ += "один"
#							2: 
#								str_ += "два"
#							3: 
#								str_ += "три"
#							4: 
#								str_ += "четыре"
#							5: 
#								str_ += "пять"
#							6: 
#								str_ += "шесть"
#							7: 
#								str_ += "семь"
#							8: 
#								str_ += "восемь"
#							9: 
#								str_ += "девять"
#
#						str_ += " " + exponents[(_i+3)/3]
#				1: 
#					if nums[indexs[1]] == 1:
#						match nums[indexs[0]]:
#							0: 
#								str_ += "десять"
#							1: 
#								str_ += "одинадцать"
#							2:
#								str_ += "двенадцать"
#							3: 
#								str_ += "тринадцать"
#							4: 
#								str_ += "четырнадцать"
#							5: 
#								str_ += "пятнадцать"
#							6: 
#								str_ += "шестнадцать"
#							7: 
#								str_ += "семнадцать"
#							8: 
#								str_ += "восемнадцать"
#							9: 
#								str_ += "девятнадцать"
#
#						str_ += " " + exponents[(_i+3)/3]
#					else:
#						match nums[value]:
#							2:
#								str_ += "двадцать"
#							3: 
#								str_ += "тридцать"
#							4: 
#								str_ += "сорок"
#							5: 
#								str_ += "пятьдесят"
#							6: 
#								str_ += "шестьдесят"
#							7: 
#								str_ += "семьдесят"
#							8: 
#								str_ += "восемньдесят"
#							9: 
#								str_ += "девяносто"
#				2: 
#					match nums[value]:
#						1: 
#							str_ += "сто"
#						2:
#							str_ += "двести"
#						3: 
#							str_ += "триста"
#						4: 
#							str_ += "четыреста"
#						5: 
#							str_ += "пятьсот"
#						6: 
#							str_ += "шестьсот"
#						7: 
#							str_ += "семьсот"
#						8: 
#							str_ += "восемьсот"
#						9: 
#							str_ += "девятьсот"
