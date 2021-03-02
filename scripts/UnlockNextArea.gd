extends StaticBody2D

export (String) var text_label
export (int) var price_amount

var player

onready var playerDetection = $DetectPlayer/Collider
onready var price = $PriceLabel
onready var pay = $PayLabel
onready var animation = $Animation
onready var platformMove = $PlatformMove

func _process(_delta):
	if player != null and Input.is_action_pressed("select"):
		if player.laxatives >= price_amount:
			player.laxatives -= price_amount
			platformMove.play("open")
			playerDetection.disabled = true
			player.stateMachine.state_logic_enabled = false

func _on_DetectPlayer_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		animation.play("show_text")
		price.text = text_label

func _on_DetectPlayer_body_exited(body):
	if body.is_in_group("Player"):
		animation.play("remove_text")

func _on_PlatformMove_animation_finished(anim_name):
	if anim_name == "open":
		player.stateMachine.state_logic_enabled = true
		player = null
