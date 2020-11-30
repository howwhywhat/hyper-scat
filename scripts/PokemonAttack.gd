extends Spatial

# ui variables
onready var ui = $PokemonUI
onready var playerChoice = $PokemonUI/BaseMenu/PlayerChoiceButtons
onready var playerAttack = $PokemonUI/BaseMenu/PlayerAttackChoices
onready var text = $PokemonUI/BaseMenu/Options/GeneralText
onready var textTween = $PokemonUI/ShowText

onready var transitionLayer = $TransitionLayer

# animations
onready var attackAnimation = $AttackAnimation
onready var playerAnimation = $PlayerAnimation
onready var enemyAnimation = $EnemyAnimation

var garbageEntity
var attack
var scene

# entity handling
var fightingEnabled = true
var fightTurn = "PLAYER"
var playerHealth = 25
var enemyHealth = 5

func _ready():
	scene = get_tree().current_scene
	get_tree().get_root().remove_child(scene)
	transitionLayer.shaderLayer.show_screen()

func damage(value : int, body : String):
	if body == "player":
		playerHealth -= value
	elif body == "enemy":
		enemyHealth -= value

func finish_turn():
	if fightingEnabled:
		if fightTurn == "PLAYER":
			print("Player attack over")
			text.bbcode_text = "Garbage used [shake]REBUTTAL[/shake]!"
			show_text()
			attackAnimation.play("enemy_attack")
			damage(5, "player")
			print(str(playerHealth))
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

func _on_FightButton_pressed():
	for node in playerChoice.get_children():
		node.disabled = true
	playerChoice.visible = false
	for node in playerAttack.get_children():
		node.disabled = false
	playerAttack.visible = true

func _on_AssClenchAttack_pressed():
	for node in playerAttack.get_children():
		node.disabled = true
	playerAttack.visible = false
	text.visible = true
	text.bbcode_text = "Ass Man used [shake]ASS CLENCH[/shake]!"
	show_text()
	attackAnimation.play("player_attack")
	damage(5, "enemy")
	print(str(enemyHealth))
	yield(get_tree().create_timer(3), "timeout")
	finish_turn()

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
		yield(get_tree().create_timer(3), "timeout")
		transitionLayer.shaderLayer.hide_screen()
		ui.queue_free()
		yield(get_tree().create_timer(1), "timeout")
		get_tree().get_root().add_child(scene)
		get_tree().current_scene = scene
		garbageEntity.damage(999)
		get_tree().current_scene.comeFromPokemonAttack()
		get_tree().get_root().remove_child(self)

func _on_PlayerAnimation_animation_finished(anim_name):
	if anim_name == "death":
		text.bbcode_text = "Garbage won! You lost."
		show_text()
		yield(get_tree().create_timer(3), "timeout")
		ui.queue_free()
		transitionLayer.shaderLayer.hide_screen()
