# player.gd
extends CharacterBody3D

const SPEED = 3.0
@onready var anim_sprite = $AnimatedSprite3D # 确保你的节点叫这个名字

func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		update_animation(input_dir, true)
	else:
		# 停止时平滑减速
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		update_animation(input_dir, false) # 传递 false 表示不移动

	move_and_slide()

func update_animation(input_dir: Vector2, is_moving: bool):
	var state_prefix = "run" if is_moving else "idle"
	var dir_suffix = "down" # 默认朝下动画
	
	if input_dir.y < 0: # 向上
		dir_suffix = "up"
	elif input_dir.y > 0: # 向下
		dir_suffix = "down"
	elif input_dir.x < 0: # 向左
		dir_suffix = "left"
	elif input_dir.x > 0: # 向右
		dir_suffix = "right"
		
	var anim_name = state_prefix + "_" + dir_suffix
	
	# 只有在动画名称发生改变时才调用 play，避免重复调用导致性能开销
	if anim_sprite.animation != anim_name:
		anim_sprite.play(anim_name)
