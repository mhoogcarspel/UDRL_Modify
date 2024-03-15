extends Node2D

class_name Level

var gridSize = 64.0;
const boundLeft = 32;
const boundRight = 640 - 32;
const boundTop = 32;
const boundBottom = 640 - 32;

var prefabWall = preload("res://objects/Wall.tscn");
var prefabToken = preload("res://objects/Token.tscn");
var prefabPlayer = preload("res://objects/Player.tscn");
var prefabGoal = preload("res://objects/Goal.tscn");
var prefabFloor = preload("res://objects/Floor.tscn");

enum TYPE {NONE = 0, ONE = 1, TWO = 2, THREE = 3, SWAP = 4}
var typeUp = TYPE.NONE;
var typeDown = TYPE.NONE;
var typeLeft = TYPE.NONE;
var typeRight = TYPE.NONE;

var controllable = true;

var winQueued = false;
var winTimer = 0.0;

var undoStack = [];

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (controllable):
		var moveDir = Vector2(0,0);
		var type = null;
		var dirInt = -1;
		if Input.is_action_just_pressed("ui_up"):
			moveDir = Vector2(0,-1);
			type = typeUp;
			dirInt = 0;
		elif Input.is_action_just_pressed("ui_down"):
			moveDir = Vector2(0,1);
			type = typeDown;
			dirInt = 1;
		elif Input.is_action_just_pressed("ui_left"):
			moveDir = Vector2(-1,0);
			type = typeLeft;
			dirInt = 2;
		elif Input.is_action_just_pressed("ui_right"):
			moveDir = Vector2(1,0);
			type = typeRight;
			dirInt = 3;
		
		if type != null:
			if type == TYPE.TWO:
				moveDir *= 2;
			elif type == TYPE.THREE:
				moveDir *= 3;
			
			#print(moveDir);
			
			var player = FindPlayer();
			if player == null:
				print("No player found! Can't move!");
			else:
				var targetPosition = player.boardPosition + moveDir;
				var targetObj = FindObjAt(targetPosition);
				#print(targetPosition);
				#if space is empty, move player
				if targetObj == null:
					if IsBoardPositionInBounds(targetPosition):
						player.boardPosition = targetPosition;
						player.targetPosition = targetPosition * gridSize;
						PlaySound("Walk");
						AddToUndoStack();
					else:
						player.Shake();
						PlaySound("Bonk");
				#if space is taken by a token,
				elif targetObj.objType == BoardObject.OBJTYPE.Token:
					var swap = GetSwapper();
					#if our movement direction is NONE or the target token is a NONE token,
					if (swap == null and ((type == TYPE.NONE and targetObj.type != TYPE.NONE) or (type != TYPE.NONE and targetObj.type == TYPE.NONE))) or (swap != null and targetObj.type != TYPE.SWAP):
						#move player
						player.boardPosition = targetPosition;
						player.targetPosition = targetPosition * gridSize;
						PlaySound("Walk");
						
						if swap == null:
							#set side of player to token type
							match dirInt:
								0: typeUp = targetObj.type;	
								1: typeDown = targetObj.type;
								2: typeLeft = targetObj.type;
								3: typeRight = targetObj.type;
									
						else:
							#jesse we need to swap
							match swap:
								0: typeUp = targetObj.type;
								1: typeDown = targetObj.type;
								2: typeLeft = targetObj.type;
								3: typeRight = targetObj.type;
						
						#update player object sides and sprite, then hide token
						player.typeUp = typeUp;
						player.typeDown = typeDown;
						player.typeLeft = typeLeft;
						player.typeRight = typeRight;
						
						player.SetSprite();
						targetObj.SetVisible(false);
						
						#play sounds
						if targetObj.type == BoardObject.TYPE.NONE:
							PlaySound("Eat_R");
						else:
							PlaySound("Eat");
							match targetObj.type:
								BoardObject.TYPE.ONE: PlaySound("One");
								BoardObject.TYPE.TWO: PlaySound("Two");
								BoardObject.TYPE.THREE: PlaySound("Three");
								BoardObject.TYPE.SWAP: PlaySound("Swap");
							
							if swap != null:
								PlaySound("Swapped");
						
						#player slice anim
						if (swap == null):
							player.Bump(dirInt);
						else:
							player.Bump(swap);
						
						AddToUndoStack();
						UpdateGoalStatus();
					else:
						var pushPosition = targetPosition + moveDir.normalized();
						var pushObj = FindObjAt(pushPosition);
						if pushObj == null or pushObj.visible == false:
							if IsBoardPositionInBounds(pushPosition):
								player.boardPosition = targetPosition;
								player.targetPosition = targetPosition * gridSize;
								PlaySound("Walk");
								
								targetObj.boardPosition = pushPosition;
								targetObj.targetPosition = pushPosition * gridSize;
								PlaySound("Push");
								AddToUndoStack();
							else:
								player.Shake();
								targetObj.Shake();
								PlaySound("Bonk");
						else:
							player.Shake();
							targetObj.Shake();
							pushObj.Shake();
							PlaySound("Bonk");
				elif targetObj.objType == BoardObject.OBJTYPE.Goal:
					player.boardPosition = targetPosition;
					player.targetPosition = targetPosition * gridSize;
					PlaySound("Walk");
					AddToUndoStack();
					
					if IsGoalActive():
						Win();
						PlaySound("Win");
				else:
					player.Shake();
					targetObj.Shake();
					PlaySound("Bonk");
		
		if Input.is_action_just_pressed("Undo"):
			if undoStack.size() > 1:
				undoStack.pop_back();
				SetBoardFromState(undoStack[undoStack.size() - 1]);
	elif winQueued:
		winTimer -= delta;
		if winTimer <= 0:
			Unload();
			get_parent().GotoNextLevel();
			winQueued = false;

func Win():
	controllable = false;
	winQueued = true;
	winTimer = 2.0;
	get_parent().LevelComplete();

func AddToUndoStack():
	var boardState = [];
	for obj in get_children():
		if obj is BoardObject:
			var state = obj.GetState();
			boardState.append(state);
	
	undoStack.append(boardState);

func SetBoardFromState(boardState):
	for objState in boardState:
		#find BoardObject that matches id with state
		var searchID = objState.id;
		var targetObj = null;
		for obj in get_children():
			if obj is BoardObject:
				if obj.id == searchID:
					targetObj = obj;
		
		if targetObj != null:
			targetObj.boardPosition = objState.boardPosition;
			targetObj.targetPosition = targetObj.boardPosition * gridSize;
			targetObj.SetVisible(!objState.hidden);
			if objState is Player.StatePlayer:
				typeUp = objState.typeUp;
				typeDown = objState.typeDown;
				typeLeft = objState.typeLeft;
				typeRight = objState.typeRight;
				var player = FindPlayer();
				player.typeUp = typeUp;
				player.typeDown = typeDown;
				player.typeLeft = typeLeft;
				player.typeRight = typeRight;
				targetObj.SetSprite();
	
	UpdateGoalStatus();

func FindObjAt(position):
	for obj in get_children():
		if position == obj.boardPosition:
			if obj.visible or obj.objType == BoardObject.OBJTYPE.Wall:
				return obj;
	return null;

func FindPlayer():
	for obj in get_children():
		if obj.objType == BoardObject.OBJTYPE.Player:
			return obj;
	return null;

func IsGoalActive():
	var hasTokens = false;
	for obj in get_children():
		if obj.objType == BoardObject.OBJTYPE.Token:
			if obj.visible:
				hasTokens = true;
	return !hasTokens;

func IsBoardPositionInBounds(position):
	if position.x < 0 or position.y < 0:
		return false;
	var maxcoord = Vector2(0,0);
	
	for obj in get_children():
		if obj.boardPosition.x > maxcoord.x:
			maxcoord.x = obj.boardPosition.x;
		if obj.boardPosition.y > maxcoord.y:
			maxcoord.y = obj.boardPosition.y;
	
	if position.x > maxcoord.x or position.y > maxcoord.y:
		return false;
	
	return true;

func UpdateGoalStatus():
	if IsGoalActive():
		for obj in get_children():
			if obj.objType == BoardObject.OBJTYPE.Goal:
				obj.SetActive(true);
	else:
		for obj in get_children():
			if obj.objType == BoardObject.OBJTYPE.Goal:
				obj.SetActive(false);

func GetSwapper():
	if typeUp == TYPE.SWAP:
		return 0;
	if typeDown == TYPE.SWAP:
		return 1;
	if typeLeft == TYPE.SWAP:
		return 2;
	if typeRight == TYPE.SWAP:
		return 3;
	return null;

func Unload():
	controllable = false;
	for child in get_children():
		if child is BoardObject:
			child.Unload();

func PlaySound(name):
	var audioManager = get_tree().get_root().get_node("Root/Audio");
	audioManager.PlaySound(name);

func LoadLevel(name):
	var file = File.new();
	file.open("res://levels/" + name + ".tres", File.READ);
	var content = file.get_as_text();
	file.close();
	
	var lines = content.split("\n");
	var width = lines[0].length();
	var height = lines.size() - 1;
	
	var currentID = 0;
	
	for x in width:
		for y in height:
			if x >= lines[y].length(): break
			var letter = lines[y][x];
			var obj = null;
			match letter:
				'#':
					obj = prefabWall.instance();
					obj.objType = BoardObject.OBJTYPE.Wall;
				'-':
					obj = prefabWall.instance();
					obj.SetVisible(false);
					obj.objType = BoardObject.OBJTYPE.Wall;
				'0':
					obj = prefabToken.instance();
					obj.type = obj.TYPE.NONE;
					obj.objType = BoardObject.OBJTYPE.Token;
				'1':
					obj = prefabToken.instance();
					obj.objType = BoardObject.OBJTYPE.Token;
				'2':
					obj = prefabToken.instance();
					obj.type = obj.TYPE.TWO;
					obj.objType = BoardObject.OBJTYPE.Token;
				'3':
					obj = prefabToken.instance();
					obj.type = obj.TYPE.THREE;
					obj.objType = BoardObject.OBJTYPE.Token;
				'S':
					obj = prefabToken.instance();
					obj.type = obj.TYPE.SWAP;
					obj.objType = BoardObject.OBJTYPE.Token;
				'@':
					obj = prefabPlayer.instance();
					obj.objType = BoardObject.OBJTYPE.Player;
				'$':
					obj = prefabGoal.instance();
					obj.objType = BoardObject.OBJTYPE.Goal;
			
			if obj != null:
				add_child(obj);
				obj.transform.origin = Vector2(x * gridSize, (y + 20) * gridSize);
				obj.boardPosition = Vector2(x,y);
				obj.targetPosition = Vector2(x * gridSize, y * gridSize);
				obj.id = currentID;
				currentID += 1;
	
	#center level on screen
	#there is probably a less insane way to do this
	var levelBoundLeft = -gridSize;
	var levelBoundRight = (width) * gridSize;
	var levelBoundTop = -gridSize;
	var levelBoundBottom = (height) * gridSize;
	
	var realWidth = levelBoundRight - levelBoundLeft;
	var realHeight = levelBoundBottom - levelBoundTop;
	
	var targetWidth = boundRight - boundLeft;
	var targetHeight = boundBottom - boundTop;
	
	var scaleX = targetWidth / realWidth;
	var scaleY = targetHeight / realHeight;
	
	var realScale = min(scaleX, scaleY);
	realScale = min(realScale, 1);
	
	scale = Vector2(realScale, realScale);
	
	var center = Vector2((boundRight + boundLeft)/2.0, (boundTop + boundBottom)/2.0);
	var levelOrigin = center;
	levelOrigin.x -= ((float(width) - 1.0)/2.0) * gridSize * realScale;
	levelOrigin.y -= ((float(height) - 1.0)/2.0) * gridSize * realScale;
	transform.origin = Vector2(levelOrigin);
	
	#set wall sprites
	for obj in get_children():
		if obj.objType == BoardObject.OBJTYPE.Wall:
			obj.SetSprite();
	
	AddToUndoStack();
