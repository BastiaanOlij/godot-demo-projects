extends RayCast

var current_collider = null

func _physics_process(delta):
	if (is_enabled()):
		if (is_colliding()):
			var colliding_with = get_collider()
			
			if (current_collider):
				if (current_collider == colliding_with):
					# still looking at the same thing
					return
				
				# tell our current collider we're no longer colliding
				current_collider.set_colliding(false)
			
			# tell our new collider we're colliding with it
			current_collider = colliding_with
			current_collider.set_colliding(true)
		elif (current_collider):
			# tell our current collider we're no longer colliding
			current_collider.set_colliding(false)
			current_collider = null 