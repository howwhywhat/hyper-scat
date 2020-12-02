extends Spatial

# ui variables
onready var ui = $PokemonUI
onready var playerChoice = $PokemonUI/BaseMenu/PlayerChoiceButtons
onready var playerAttack = $PokemonUI/BaseMenu/PlayerAttackChoices
onready var text = $PokemonUI/BaseMenu/Options/GeneralText
onready var textTween = $PokemonUI/ShowText

onready var transitionLayer = $TransitionLayer

# damage indicator
onready var light = $Light
onready var damageIndicatorTween = $DamageIndicatorTween

# animations
onready var attackAnimation = $AttackAnimation
onready var playerAnimation = $PlayerAnimation
onready var enemyAnimation = $EnemyAnimation

var garbageEntity
var player
var attack
var scene

# entity handling
var fightingEnabled = true
var fightTurn = "PLAYER"
var playerHealth = 25
var enemyHealth = 25

# health
onready var playerHPBar = $PokemonUI/BaseMenu/AssManHealthUI/Health
onready var playerHPText = $PokemonUI/BaseMenu/AssManHealthUI/HP
onready var enemyHPBar = $PokemonUI/BaseMenu/EnemyHealthUI/Health
onready var enemyHPText = $PokemonUI/BaseMenu/EnemyHealthUI/HP

onready var playerHPTween = $PokemonUI/PlayerHealthTween
onready var enemyHPTween = $PokemonUI/EnemyHealthTween

# attack information
onready var attackInformation = $PokemonUI/BaseMenu/AttackInformation
onready var attackName = $PokemonUI/BaseMenu/AttackInformation/AttackName
onready var attackDescription = $PokemonUI/BaseMenu/AttackInformation/AttackDescription
onready var attackUses = $PokemonUI/BaseMenu/AttackInformation/AttackUses
onready var attackMenuAnimation = $PokemonUI/MenuAnimation

onready var attackNameTween = $PokemonUI/AttackNameTween
onready var attackDescTween = $PokemonUI/AttackDescTween
onready var attackUsesTween = $PokemonUI/AttackUsesTween

# attack uses
var assClenchUses = 3
var rapidShitUses = 2

# enemy attacks
var enemyAttacks = ["SCAT", "REBUTTAL"]

# player handling
onready var player3D = $PlayerSprite
var damaged_1 = preload("res://assets/interface/player/spritesheet_no_left_arm.png")
var damaged_2 = preload("res://assets/interface/player/spritesheet_no_right_arm.png")

func _ready():
	scene = get_tree().current_scene
	get_tree().get_root().remove_child(scene)
	transitionLayer.shaderLayer.show_screen()
	if player.left_arm_attached == false:
		player3D.texture = damaged_1
	if player.right_arm_attached == false:
		player3D.texture = damaged_2

func _process(_delta):
	damage_indicator()
	
	if playerHPBar != null and enemyHPBar != null and playerHPText != null and enemyHPText != null:
		playerHPBar.value = playerHealth
		enemyHPBar.value = enemyHealth
		if playerHealth <= 0:
			playerHPText.text = "0/25"
		else:
			playerHPText.text = str(round(playerHealth)) + "/25"
		
		if enemyHealth <= 0:
			enemyHPText.text = "0/25"
		else:
			enemyHPText.text = str(round(enemyHealth)) + "/25"

func set_attack_information(attack_name : String, attack_description : String, attack_uses : int):
	attackName.bbcode_text = attack_name
	attackDescription.bbcode_text = attack_description
	attackUses.bbcode_text = "Uses: [shake]" + str(attack_uses) + "[/shake]"

func damage(value : int, body : String):
	if body == "player":
		if not playerHPTween.is_active():
			playerHPTween.interpolate_property(self, "playerHealth", playerHealth, playerHealth - value, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
			playerHPTween.start()
	elif body == "enemy":
		if not enemyHPTween.is_active():
			enemyHPTween.interpolate_property(self, "enemyHealth", enemyHealth, enemyHealth - value, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
			enemyHPTween.start()

func finish_turn():
	if fightingEnabled:
		if fightTurn == "PLAYER":
			print("Player attack over")
			randomize()
			var finalAttack = enemyAttacks[randi() % enemyAttacks.size()]
			
			if finalAttack == "REBUTTAL":
				text.bbcode_text = "Garbage used [shake]REBUTTAL[/shake]!"
				show_text()
				attackAnimation.play("enemy_attack")
				damage(8, "player")
				yield(get_tree().create_timer(3), "timeout")
				fightTurn = "ENEMY"
				finish_turn()
			elif finalAttack == "SCAT":
				text.bbcode_text = "Garbage used [shake]SCAT[/shake]!"
				show_text()
				attackAnimation.play("enemy_attack")
				damage(3, "player")
				yield(get_tree().create_timer(3), "timeout")
				fightTurn = "ENEMY"
				finish_turn()
		elif fightTurn == "ENEMY":
			print("Enemy attack over")
			text.visible = false
			for node in playerChoice.get_children():
				node.disabled = false
			playerChoice.visible = true
			for node in playerAttack.get_children():
				node.disabled = true
			playerAttack.visible = false
			fightTurn = "PLAYER"
		else:
			print("Unexpected error")

func show_text():
	if not textTween.is_active():
		textTween.interpolate_property(text, "percent_visible", 0.0, 1.0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		textTween.start()

func show_attack_info():
	print("show attack info called")
	attackNameTween.interpolate_property(attackName, "percent_visible", 0.0, 1.0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	attackNameTween.start()
	attackDescTween.interpolate_property(attackDescription, "percent_visible", 0.0, 1.0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	attackDescTween.start()
	attackUsesTween.interpolate_property(attackUses, "percent_visible", 0.0, 1.0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	attackUsesTween.start()

func _on_FightButton_pressed():
	for node in playerChoice.get_children():
		node.disabled = true
	playerChoice.visible = false
	for node in playerAttack.get_children():
		node.disabled = false
	playerAttack.visible = true

func _on_AssClenchAttack_pressed():
	attackInformation.visible = false
	if assClenchUses > 0:
		assClenchUses -= 1
		for node in playerAttack.get_children():
			node.disabled = true
		playerAttack.visible = false
		text.visible = true
		text.bbcode_text = "Ass Man used [shake]ASS CLENCH[/shake]!"
		show_text()
		attackAnimation.play("player_attack")
		damage(4, "enemy")
		yield(get_tree().create_timer(3), "timeout")
		finish_turn()
	else:
		for node in playerAttack.get_children():
			node.disabled = true
		playerAttack.visible = false
		text.visible = true
		text.bbcode_text = "[shake]You don't have any uses left.[/shake]"
		show_text()
		yield(get_tree().create_timer(3), "timeout")
		text.visible = false
		for node in playerChoice.get_children():
			node.disabled = false
		playerChoice.visible = true
		for node in playerAttack.get_children():
			node.disabled = true
		playerAttack.visible = false

func _on_FuckinRunButton_pressed():
	for node in playerChoice.get_children():
		node.disabled = true
	playerChoice.visible = false
	text.visible = true
	text.bbcode_text = "lol you thought"
	show_text()
	yield(get_tree().create_timer(3), "timeout")
	for node in playerChoice.get_children():
		node.disabled = false
	playerChoice.visible = true
	text.visible = false

func _on_AssMenButton_pressed():
	for node in playerChoice.get_children():
		node.disabled = true
	playerChoice.visible = false
	text.visible = true
	text.bbcode_text = "You don't have any other ASS MEN."
	show_text()
	yield(get_tree().create_timer(3), "timeout")
	for node in playerChoice.get_children():
		node.disabled = false
	playerChoice.visible = true
	text.visible = false

func _on_AttackAnimation_animation_finished(anim_name):
	if anim_name == "player_attack":
		if enemyHealth <= 0:
			fightingEnabled = false
			yield(get_tree().create_timer(2), "timeout")
			enemyAnimation.play("death")
	elif anim_name == "enemy_attack":
		if playerHealth <= 0:
			fightingEnabled = false
			yield(get_tree().create_timer(2), "timeout")
			playerAnimation.play("death")
	else:
		print("Error")

func _on_EnemyAnimation_animation_finished(anim_name):
	if anim_name == "death":
		text.bbcode_text = "You won!"
		show_text()
		transitionLayer.shaderLayer.hide_screen()
		yield(get_tree().create_timer(3), "timeout")
		attackMenuAnimation.play_backwards("pop_in")
		yield(get_tree().create_timer(1), "timeout")
		get_tree().get_root().add_child(scene)
		get_tree().current_scene = scene
		garbageEntity.damage(999)
		get_tree().current_scene.comeFromPokemonAttack()
		get_tree().get_root().remove_child(self)
		queue_free()

func _on_PlayerAnimation_animation_finished(anim_name):
	if anim_name == "death":
		text.bbcode_text = "Garbage won! You lost."
		show_text()
		transitionLayer.shaderLayer.hide_screen()
		yield(get_tree().create_timer(3), "timeout")
		attackMenuAnimation.play_backwards("pop_in")
		yield(get_tree().create_timer(1), "timeout")
		get_tree().get_root().add_child(scene)
		get_tree().current_scene = scene
		player.apply_damage(9999)
		get_tree().current_scene.comeFromPokemonAttack()
		get_tree().get_root().remove_child(self)
		queue_free()

func damage_indicator():
	if playerHealth < 12:
		if not damageIndicatorTween.is_active():
			damageIndicatorTween.interpolate_property(light, "light_color", light.light_color, Color(0.75, 0, 0), 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			damageIndicatorTween.start()

func _on_AssClenchAttack_mouse_entered():
	print("mouse entered")
	set_attack_information("ASS CLENCH", "Clench your ass on your enemy's face.\nDMG: [shake]4[/shake]", assClenchUses)
	attackInformation.visible = true
	show_attack_info()

func _on_AssClenchAttack_mouse_exited():
	attackInformation.visible = false

func _on_RapidShitAttack_pressed():
	attackInformation.visible = false
	if rapidShitUses > 0:
		rapidShitUses -= 1
		for node in playerAttack.get_children():
			node.disabled = true
		playerAttack.visible = false
		text.visible = true
		text.bbcode_text = "Ass Man used [shake]RAPID SHIT[/shake]!"
		show_text()
		attackAnimation.play("player_attack")
		damage(9, "enemy")
		yield(get_tree().create_timer(3), "timeout")
		finish_turn()
	else:
		for node in playerAttack.get_children():
			node.disabled = true
		playerAttack.visible = false
		text.visible = true
		text.bbcode_text = "[shake]You don't have any uses left.[/shake]"
		show_text()
		yield(get_tree().create_timer(3), "timeout")
		text.visible = false
		for node in playerChoice.get_children():
			node.disabled = false
		playerChoice.visible = true
		for node in playerAttack.get_children():
			node.disabled = true
		playerAttack.visible = false

func _on_RapidShitAttack_mouse_entered():
	set_attack_information("RAPID SHIT", "Rapidly shit on your enemies.\nDMG: [shake]9[/shake]", rapidShitUses)
	attackInformation.visible = true
	show_attack_info()

func _on_RapidShitAttack_mouse_exited():
	attackInformation.visible = false
