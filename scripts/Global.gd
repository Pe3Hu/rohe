extends Node


var rng = RandomNumberGenerator.new()
var dict = {}
var num = {}
var arr = {}
var obj = {}
var node = {}
var flag = {}
var vec = {}

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
	num.carte.l = min(dict.window_size.width,dict.window_size.height) * 0.9
	
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

func init_primary_key():
	num.primary_key = {}
	num.primary_key.secteur = 0

func init_dict():
	init_window_size()

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
	arr.point = [
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
	

func init_node():
	node.TimeBar = get_node("/root/Game/TimeBar") 
	node.Game = get_node("/root/Game") 

func init_flag():
	flag.click = false
	flag.stop = false

func init_vec():
	vec.carte = dict.window_size.center - Vector2(num.carte.cols,num.carte.rows)*num.zone.a/2

func _ready():
	init_dict()
	init_num()
	init_arr()
	init_node()
	init_flag()
	init_vec()

func custom_log(value_,base_): 
	return log(value_)/log(base_)
