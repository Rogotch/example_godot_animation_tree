extends CharacterBody2D

enum conditions {idle = 0, move = 1, hit = 2, death = 3}
@onready var animation_tree = $animation_tree
@onready var sprite_2d = $Sprite2D

const SPEED = 150.0
var actual_condition = conditions.idle
var state_machine = null
var flipped = false

# Получаем машину состояний в переменную
func _ready():
	state_machine = animation_tree.get("parameters/playback")
	pass

func _physics_process(delta):
	# Игнорируем ввод и передвижение, если персонаж мёртв
	if actual_condition == conditions.death:
		return
	
	# Получаем вектор ввода
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = lerp(velocity, direction * SPEED, 0.1)
	
	# Проверяем, есть ли ввод на движение
	if direction.length() > 0:
		# Проверяем, есть ли движение по оси X, чтобы определить, нужно ли поворачивать персонажа
		if direction.x != 0:
			flipped = direction.x < 0
		# Если вектор движения не соответствует повороту персонажа, то говорим ему развернуться
		if flipped != sprite_2d.flip_h:
			state_machine.travel("turn_around")
		else:
			# Иначе говорим просто проигрывать анимацию движения
			set_condition(conditions.move)
	# Если ввода нет и не проигрывается анимация, то устанавливаем персонажа на айдл
	elif direction.length() == 0 && actual_condition != conditions.hit:
		set_condition(conditions.idle)
	
	move_and_slide()
	pass

func set_condition(new_condition : conditions):
	match new_condition:
		conditions.idle:
			state_machine.travel("idle")
		conditions.move:
			state_machine.travel("move")
		conditions.hit:
			state_machine.travel("hit")
		conditions.death:
			state_machine.travel("death")
	actual_condition = new_condition
	pass

func flip():
	sprite_2d.flip_h = flipped
	pass

func reset_condition():
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	set_condition(conditions.idle if direction.length() > 0 else conditions.move)
	pass

func _on_hit_pressed():
	set_condition(conditions.hit)
	pass # Replace with function body.

func _on_death_pressed():
	set_condition(conditions.death)
	pass # Replace with function body.

func _on_reset_pressed():
	reset_condition()
	pass # Replace with function body.
