extends Node2D

var levelList = [];
var levelNameList = [];
var levelCompletion = [];
var prefabLevel = preload("res://objects/Level.tscn");
var currentLevel = 0;
var currentLevelName = "";
var totalLevels = 0;

class LevelData:
	var filename = "";
	var printname = "";
	var completion = false;

func _ready():
	var file = File.new();
	file.open("res://levels/list.tres", File.READ);
	var content = file.get_as_text();
	for line in content.split("\n"):
		var s = line.split(":");
		
		var level = LevelData.new();
		level.filename = s[0];
		level.printname = s[1];
		level.completion = false;
		
		levelList.append(level);
		totalLevels += 1;
	
	LoadSave();
	
	for i in range(0,levelList.size() - 2):
		if levelList[i].completion:
			currentLevel += 1;
		else:
			break;
	
	LoadLevel(levelList[currentLevel].filename);
	pass # Replace with function body.

func LoadLevel(name):
	var obj = prefabLevel.instance();
	add_child(obj);
	obj.LoadLevel(name);
	
	currentLevelName = levelList[currentLevel].printname;
	
	$Progress.text = String(currentLevel + 1) + "/" + String(totalLevels - 1) + ": " + currentLevelName;
	$Star.SetSprite(levelList[currentLevel].completion);
	
	if currentLevel == levelList.size() - 1:
		$EndCompletion.visible = true;
		var levelsComplete = 0;
		for i in range(0, levelList.size() - 1):
			if levelList[i].completion:
				levelsComplete += 1;
			
		
		var congrats = "";
		if levelsComplete == levelList.size() - 1:
			congrats = "\nCongratulations!"
		
		$EndCompletion.text = String(levelsComplete) + "/" + String(totalLevels - 1) + " Levels Complete" + congrats;
	else:
		$EndCompletion.visible = false;

func GotoNextLevel():
	currentLevel += 1;
	if currentLevel == totalLevels:
		currentLevel -= 1;
	else:
		LoadCurrentLevel();

func GotoPrevLevel():
	currentLevel -= 1;
	if currentLevel == -1:
		currentLevel = 0;
	else:
		LoadCurrentLevel();

func Restart():
	LoadCurrentLevel();

func LoadCurrentLevel():
	for obj in get_children():
		if obj is Level:
			obj.Unload();
	
	LoadLevel(levelList[currentLevel].filename);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Restart"):
		Restart();
	if Input.is_action_just_pressed("SkipLevel"):
		GotoNextLevel();
	if Input.is_action_just_pressed("BackLevel"):
		GotoPrevLevel();

func LevelComplete():
	levelList[currentLevel].completion = true;
	UpdateSaveFile();
	UpdateStar();

func UpdateStar():
	$Star.StarEffect();

func UpdateSaveFile():
	var file = File.new();
	file.open("user://savefile.save", File.WRITE);
	var dict = {}
	for level in levelList:
		dict[level.filename] = level.completion;
	file.store_line(to_json(dict));
	file.close();

func LoadSave():
	var file = File.new();
	if !file.file_exists("user://savefile.save"):
		return;
	
	file.open("user://savefile.save", File.READ);
	var dict = parse_json(file.get_line());
	
	for savedata in dict.keys():
		for leveldata in levelList:
			if leveldata.filename == savedata:
				leveldata.completion = dict[savedata];
	
	file.close();
	pass
