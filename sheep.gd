extends CharacterBody2D


const SPEED = 100.0

const separation_weight = 100
const cohesion_weight = 1
const alignment_weight = 1

#const desired_min_distance = 10
#const escape_strength = 100


# Get the gravity from the project settings to be synced with RigidBody nodes.

var max_velocity = 100
var max_acceleration = 1000
var rotationOffset = PI/2


const BOUNDARY_FORCE_SCALE = 10  # Adjust to tune how strongly they turn back to center
const TIME_OUTSIDE_SCALE = 1.5  # Adjust to control how quickly the force ramps up over time

var heading = Vector2.ZERO
var heading_acceleration = Vector2.ZERO


var time_outside_screen = 0.0  # Track time outside of bounds for each sheep

var nearby_sheep = []

func _ready():
	print("Sheep position:", position)
	
	
func _physics_process(delta):
	#var area2d = $Area2D
	#var other_sheep = area2d.get_overlapping_bodies()
	var overlapping_sheep = $Area2D.get_overlapping_bodies()
	#print("ITS THE SHEEP", overlapping_sheep)
	if(nearby_sheep.size() == 0):
		nearby_sheep = overlapping_sheep
	
	var separation_force = calculate_separation()
	var alignment_force = calculate_alignment()
	var cohesion_force = calculate_cohesion()
	
	var total_force: Vector2 = separation_force + alignment_force + cohesion_force
	total_force = total_force.limit_length(SPEED)
	total_force += calculate_boundary_force(delta)
	#velocity = velocity.normalized() * SPEED
	# Update velocity based on total force
	velocity += total_force * delta
	velocity = velocity.limit_length(SPEED)
	
	#if velocity.length() > 0:
		#rotation = velocity.angle() + PI
	
	if velocity.x < 0:
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true

	# Print for debugging
	print("Velocity:", velocity, " Total force:", total_force)

	# Move the sheep using move_and_slide
	move_and_slide()
	
	


func calculate_boundary_force(delta) -> Vector2:
	var screen = get_viewport_rect()
	
	# Shrink screen to 80% size (by reducing each side by 10%)
	var inner_screen = screen.grow(-0.1 * min(screen.size.x, screen.size.y))  # Shrinks by 10% on each side
	var screen_center = screen.get_center()
	var force = Vector2.ZERO
	if inner_screen.abs().has_point(position) == false:
		# Sheep is outside screen bounds
		time_outside_screen += delta
		var direction_to_center = (screen_center - position)
		
		# Increase force proportionally to time outside and scale it
		force = direction_to_center * BOUNDARY_FORCE_SCALE * pow(time_outside_screen, TIME_OUTSIDE_SCALE)
	else:
		# Reset time outside if sheep is inside bounds
		time_outside_screen = 0.0

	return force

func calculate_cohesion():
	var force = Vector2.ZERO
	if(nearby_sheep.size() == 0):
		return force
	for sheep in nearby_sheep:
		force += sheep.position
	force /= nearby_sheep.size()
	#var cohesion_force = (force - position).normalized()
	var cohesion_force = (force - position) / 100
	return cohesion_force * cohesion_weight  # Tune with a cohesion weight

func calculate_separation():
	var force = Vector2.ZERO
	if(nearby_sheep.size() == 0):
		return force

	for sheep in nearby_sheep:
		@warning_ignore("unused_variable")
		var offset = sheep.position - position
		#force += offset.normalized() / offset.length_squared()
		#if offset.length_squared() > 0:  # Prevent division by zero
			#force += offset / offset.length_squared()
	return force * separation_weight  # Adjust weight for tuning


func calculate_alignment():
	var average_velocity = Vector2.ZERO
	if(nearby_sheep.size() == 0):
		return average_velocity
	for sheep in nearby_sheep:
		average_velocity += sheep.velocity #check velocity
	#var force = average_velocity.normalized()
	var force = average_velocity / nearby_sheep.size()
	return force * alignment_weight


func _on_area_2d_area_entered(area):
	if area.is_in_group("sheep"):
		nearby_sheep.append(area)
		print("entered area")

func _on_area_2d_area_exited(area):
	nearby_sheep.erase(area)
	print("exited area")
