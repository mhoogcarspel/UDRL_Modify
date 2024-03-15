extends Node

var timerPad = 3;
var timerPiano = 10;
var timerBass = 7;
var timerArp = 5;
var timerNoise = 10;

var timerVoiceChange = 1;
var playPad = false;
var playPiano = false;
var playBass = false;
var playArp = false;
var playNoise = false;

var soundqueue = {};

var ensembles = ["11001","10101","01101","11100","00111","10011","10110","01011","01110","00110","11000","01010"];

enum MUTE {NONE, SOUND, MUSIC, ALL};
var mutemode = MUTE.NONE;

var busSound;
var busMusic;
var busDBMax = 0;
var busDBMin = -80;
var busDBRate = 40;

var muteAlertAlpha = 0;

# Called when the node enters the scene tree for the first time. 
func _ready():
	busSound = AudioServer.get_bus_index("Sound");
	busMusic = AudioServer.get_bus_index("Music");

func _process(delta):
	#mute
	if Input.is_action_just_pressed("Mute"):
		if mutemode == MUTE.NONE:
			mutemode = MUTE.MUSIC;
			MuteAlert("Mute music only");
		elif mutemode == MUTE.MUSIC:
			mutemode = MUTE.ALL;
			MuteAlert("Mute all");
		elif mutemode == MUTE.SOUND:
			mutemode = MUTE.ALL;
			MuteAlert("Mute all");
		elif mutemode == MUTE.ALL:
			mutemode = MUTE.NONE;
			MuteAlert("Unmute all");
	
	var DBSound = AudioServer.get_bus_volume_db(busSound);
	var DBMusic = AudioServer.get_bus_volume_db(busMusic);
	
	if mutemode == MUTE.SOUND or mutemode == MUTE.ALL:
		DBSound -= busDBRate * delta;
	else:
		DBSound += busDBRate * delta;
	
	if mutemode == MUTE.MUSIC or mutemode == MUTE.ALL:
		DBMusic -= busDBRate * delta;
	else:
		DBMusic += busDBRate * delta;
	
	DBSound = clamp(DBSound, busDBMin, busDBMax);
	DBMusic = clamp(DBMusic, busDBMin, busDBMax);
	AudioServer.set_bus_volume_db(busSound, DBSound);
	AudioServer.set_bus_volume_db(busMusic, DBMusic);
	
	#mute alert
	if muteAlertAlpha > 0:
		muteAlertAlpha -= delta;
		$MuteAlert.modulate.a = muteAlertAlpha;
	
	#music
	timerPad -= delta;
	timerPiano -= delta;
	timerBass -= delta;
	timerArp -= delta;
	timerNoise -= delta;
	timerVoiceChange -= delta;
	
	if timerPad <= 0:
		timerPad = 12.3;
		if playPad:
			PlaySound("Pad");
	
	if timerPiano <= 0:
		timerPiano = rand_range(14,21);
		if playPiano:
			PlaySound("Piano");
	
	if timerBass <= 0:
		timerBass = 10.7;
		if playBass:
			PlaySound("Bass");
	
	if timerArp <= 0:
		timerArp = rand_range(9,12);
		if playArp:
			PlaySound("Arp");
	
	if timerNoise <= 0:
		timerNoise = 14;
		if playNoise:
			PlaySound("Noise");
	
	if timerVoiceChange <= 0:
		timerVoiceChange = rand_range(50,80);
		var ensemble = floor(rand_range(0, ensembles.size()));
		var ensembleString = ensembles[ensemble];
		if ensembleString[0] == "1":
			playPad = true;
		else:
			playPad = false;
		
		if ensembleString[1] == "1":
			playPiano = true;
		else:
			playPiano = false;
		
		if ensembleString[2] == "1":
			playBass = true;
		else:
			playBass = false;
		
		if ensembleString[3] == "1":
			playArp = true;
		else:
			playArp = false;
		
		if ensembleString[4] == "1":
			playNoise = true;
		else:
			playNoise = false;
		
		print("ensemble picked: " + ensembleString);

func PlaySound(name):
	var node = get_node(name);
	if node != null:
		#soundqueue[name] is an array of sound objects
		if soundqueue.has(name):
			if soundqueue[name].size() == 0:
				CreateSoundQueue(name);
		else:
			CreateSoundQueue(name);
		
		#when playing a random sound from soundqueue, remove that sound from the array.
		#soundqueue is rebuilt above when it becomes empty
		var sounds = soundqueue[name];
		var index = floor(rand_range(0,sounds.size()));
		var player = soundqueue[name].pop_at(index);
		if player is AudioStreamPlayer:
			player.play();

func CreateSoundQueue(name):
	var node = get_node(name);
	if node != null:
		var sounds = node.get_children();
		soundqueue[name] = sounds;

func MuteAlert(message):
	$MuteAlert.text = message;
	muteAlertAlpha = 2.0;
