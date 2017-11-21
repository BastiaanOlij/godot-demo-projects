extends Spatial

var current_navpoint = null

func _on_navpoint_selected(p_navpoint):
	if (current_navpoint):
		if (current_navpoint == p_navpoint):
			return
			
			# show our current navpoint again
			current_navpoint.visible = true
	
	# select our new navpoint
	current_navpoint = p_navpoint
	
	# hide our navpoint
	current_navpoint.visible = false
	
	# center our camera on our ARVR Origin, we ignore tilt and height
	ARVRServer.center_on_hmd(true, false)
	
	# TODO we should implement a fade in/fade out.
	
	# now we can set our ARVROrigin position to our navpoint position.
	# Note that this includes the orientation so you can rotate navpoints to determine the direction the player will face.
	$ARVROrigin.global_transform = current_navpoint.global_transform

func _ready():
	var arvr_interface = ARVRServer.find_interface("Native mobile")
	if arvr_interface and arvr_interface.initialize():
		get_viewport().arvr = true
		
		# Turn off a few things that cost performance
		get_viewport().hdr = false
		get_viewport().usage = Viewport.USAGE_3D_NO_EFFECTS
		
		# Also for mobiles I've turned off shading on the materials. The PBR shader asks a little much
		
		# These settings are specific to the native mobile driver as it is unaware of the details of your phone
		# The settings presented below are tested on a Samsung Galaxy Note 4 and a first generation Gear VR
		# They may need to be different for your hardware
		arvr_interface.oversample = 1.4 # this increases the size of the render buffer, higher = better quality but at the expense of performance
		arvr_interface.iod = 6.0 # distance between the pupils of your eyes, when lenses can't be moved, distance between the lenses
		arvr_interface.display_width = 12 # width of our LCD screen
		arvr_interface.k1 = 0.215 # our two lens distortion factors
		arvr_interface.k2 = 0.215

	# hook all our navpoints
	for navpoint in get_node("NavPoints").get_children():
		navpoint.connect("navpoint_selected", self, "_on_navpoint_selected")

func _process(delta):
	# Note, this is not properly displayed in 3D. 
	$FPS.text = 'FPS ' + str(Performance.get_monitor(Performance.TIME_FPS))