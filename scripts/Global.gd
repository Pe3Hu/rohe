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
	
	num.stronghold = {}
	num.stronghold.estrangement = 5
	
	num.diplomacy = {}
	num.diplomacy.zone = num.stronghold.estrangement*2+1
	num.diplomacy.width = 2

func init_primary_key():
	num.primary_key = {}
	num.primary_key.secteur = 0

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
	
	for _i in n:
		var key = dict.windrose.keys()[_i]
		var shifted_index = (_i+n+n/2)%n
		var drop = dict.windrose.keys()[shifted_index]
		dict.drop[key] = dict.windrose[drop]

func init_window_size():
	dict.window_size = {}
	dict.window_size.width = ProjectSettings.get_setting("display/window/size/width")
	dict.window_size.height = ProjectSettings.get_setting("display/window/size/height")
	dict.window_size.center = Vector2(dict.window_size.width/2, dict.window_size.height/2)

func init_arr():
	arr.sequence = {} 
	arr.sequence["A000040"] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
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
	init_num()
	init_arr()
	init_node()
	init_flag()
	init_vec()
	init_color()

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
