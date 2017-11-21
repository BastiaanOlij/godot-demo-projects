extends StaticBody
signal navpoint_selected

var is_hitting = false
var value = 0
var duration = 2.0 # number of seconds we need to look at the navpoint before its selected

func set_colliding(ray_is_hitting_this):
	is_hitting = ray_is_hitting_this
	if is_hitting:
		value = 0;
		set_process(true)
	else:
		set_process(false)
		
		# reset our animation

func _process(delta):
	if is_hitting:
		value = value + delta;
		if (value > duration):
			# stop our process, we've selected this navpoint
			set_process(false)
			
			# reset our animation
			
			# and signal..
			emit_signal("navpoint_selected", self)
		else:
			pass
			# update our animation...
	else:
		set_process(false)
		
		# reset our animation

func _ready():
	# set billboard mode on our material
	$LookatShape.mesh.material.params_billboard_mode = SpatialMaterial.BILLBOARD_ENABLED
	
	# godot now autostarts this
	set_process(false)