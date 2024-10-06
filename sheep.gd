extends CharacterBody2D


const SPEED = 10.0

const separation_weight = 1
const cohesion_weight = 1
const alignment_weight = 1

const desired_min_distance = 10
const escape_strength = 100


# Get the gravity from the project settings to be synced with RigidBody nodes.

var heading = Vector2.ZERO


var nearby_sheep = []

func _ready():
	print("Sheep position:", position)
	
	
func _physics_process(delta):
	#var area2d = $Area2D
	#var other_sheep = area2d.get_overlapping_bodies()
	var separation_force = calculate_separation()
	var alignment_force = calculate_alignment()
	var cohesion_force = calculate_cohesion()
	
	var total_force = separation_force + alignment_force + cohesion_force
	velocity += total_force * delta 
	velocity = velocity.normalized() * SPEED
	#velocity = velocity.normalized()
	print(velocity)
	#position = velocity * delta
	#move_and_collide(velocity)
	#apply_impulse(Vector2.ZERO, velocity * delta)  # Use this in KinematicBody2D
	move_and_slide()

func apply_evasion_logic():
	for sheep in nearby_sheep:
		var distance = position.distance_to(sheep.position)
		if distance < desired_min_distance:  # Define your desired minimum distance
			var offset = position - sheep.position
			var escape_force = offset.normalized() * escape_strength  # Define escape_strength
			velocity += escape_force


func calculate_cohesion():
	var force = Vector2.ZERO
	if(nearby_sheep.size() == 0):
		return force
	for sheep in nearby_sheep:
		force += sheep.position
	force /= nearby_sheep.size()
	var cohesion_force = (force - position).normalized()
	return cohesion_force * cohesion_weight  # Tune with a cohesion weight

func calculate_separation():
	var force = Vector2.ZERO
	for sheep in nearby_sheep:
		var offset = position - sheep.position
		force += offset.normalized() / offset.length_squared()
	return force * separation_weight  # Adjust weight for tuning


func calculate_alignment():
	var average_velocity = Vector2.ZERO
	for sheep in nearby_sheep:
		average_velocity += sheep.velocity #check velocity
	var force = average_velocity.normalized()
	return force * alignment_weight


func _on_area_2d_area_entered(area):
	if area.is_in_group("sheep"):
		nearby_sheep.append(area)
		#print("entered area")

func _on_area_2d_area_exited(area):
	nearby_sheep.erase(area)
	#print("exited area")
