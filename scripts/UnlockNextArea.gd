extends StaticBody2D

export (String) var text_label : String
export (int) var price_amount : int

var player

onready var playerDetection : CollisionShape2D = $DetectPlayer/Collider
onready var price : Label = $PriceLabel
onready var pay : Label = $PayLabel
onready var animation : AnimationPlayer = $Animation
onready var platformMove : AnimationPlayer = $PlatformMove

func _process(_delta) -> void:
	if player != null and !player.dash and !player.stunned and Input.is_action_pressed("select"):
		if player.laxatives >= price_amount:
			player.laxatives -= price_amount
			platformMove.play("open")
			playerDetection.disabled = true
			player.stateMachine.state_logic_enabled = false
			player.unlocking = true
			player.animation.stop()
			player.animation.play("fall")

func _on_DetectPlayer_body_entered(body) -> void:
	if body.is_in_group("Player"):
		player = body
		animation.play("show_text")
		price.text = text_label

func _on_DetectPlayer_body_exited(body) -> void:
	if body.is_in_group("Player"):
		animation.play("remove_text")

func _on_PlatformMove_animation_started(anim_name : String) -> void:
	if anim_name == "open":
		yield(get_tree().create_timer(0.6), "timeout")
		player.stateMachine.state_logic_enabled = true
		player.unlocking = false
		player = null
