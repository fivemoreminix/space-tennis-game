extends CollisionShape2D

const TURN_SPEED = 4
const MAX_SPEED = 1000.0
const INACCURACY_PER_BOUNCE = 30 # In pixels
const MARGINS = 75 # edges of the screen we will not allow target_pos to be

var speed = 500.0
var bounces = 0
var inaccuracy = 0


func move(target_pos, phys_delta):
	var m = get_parent()
	
	# Make a target position that stays within reach of players
	var pos = target_pos + Vector2(0, inaccuracy)
	# Clamp to within bounds player should be able to reach
	pos.y = clamp(pos.y, MARGINS, get_viewport().size.y - MARGINS)
	
	var target_rotation = m.get_angle_to(pos)
	m.rotation += lerp(0, target_rotation, TURN_SPEED) * phys_delta
	
	# Always fly forward
	m.position += m.transform.basis_xform(Vector2.RIGHT) * speed * phys_delta


# explode() returns a number between 0.0 and 1.0 determining how much
# damage the missile should do. It also performs an animation before freeing
# the parent node.
# NOTE: Was previously known as "get_damage()"
func explode() -> float:
	explosion_state()
	get_parent().exploision()
	
	return speed / MAX_SPEED


func can_deflect() -> bool:
	return true


# Let the missile know it got deflected, and with a force from 0.0 to 1.0.
func deflected(force: float) -> void:
	bounces += 1
	speed += 100.0 * force
	
	inaccuracy = (bounces * INACCURACY_PER_BOUNCE) * (1 if (randi() % 2 == 0) else -1)

func explosion_state():
	$Particles2D.emitting = false
	$Sprite.hide()
	set_deferred("disabled", true) # to stop any non needed collisions
	$SFX/MissileFire.stop()
	$SFX/MissileGas.stop()
