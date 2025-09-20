class_name XRPinchDetector
extends Node3D

## Add this node to an XRController3D node to handle advanced pinch detection.
## This node will detect when the user performs a pinch gesture.

#region Signals
## Signal emitted when pinch was tapped.
signal pinch_tapped(controller)

## Signal emitted when there a pinch was held.
signal pinch_held(controller)

## Signal emitted when pinch is released.
signal pinch_released(controller, was_tapped, was_held)
#endregion


#region Properties
## If we pinch less than this duration, it's considered a tap.
@export_range(0.0, 2000, 10, "suffix:ms") var max_tap_duration : int = 300

## If we pinch longer than this duration, we get our pinch_held signal.
@export_range(0.0, 5.0, 0.1, "suffix:s") var held_duration : float = 0.2:
	set(value):
		held_duration = value
		if _timer:
			_timer.wait_time = held_duration

## Action in our action map for our pinch input.
@export var pinch_action : String = "pinch"
#endregion


#region Private variables
# Controller we're attached to.
var _xr_controller : XRController3D

# Timer object we use to detect pinch held.
var _timer : Timer

# True if we're pinching.
var _pinching : bool = false

# True if we held our pinch.
var _pinch_held : bool = false

# Start time of our pinch.
var _pinch_started : int = 0
#endregion


#region Private functions
# Our node was added to our scene tree.
func _enter_tree() -> void:
	var parent = get_parent()
	if not parent or not parent is XRController3D:
		push_error("Parent of our XRPinchDetector must be an XRController3D node!")
		return

	_xr_controller = parent
	_xr_controller.input_float_changed.connect(_on_input_float_changed)

	# Create our timer node and add it as an internal node.
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = held_duration
	add_child(_timer, false, Node.INTERNAL_MODE_BACK)
	_timer.timeout.connect(_on_timeout)


# Our node was removed from our scene tree.
func _exit_tree() -> void:
	# Cleanup our timer.
	if _timer:
		_timer.timeout.disconnect(_on_timeout)
		_timer.stop()
		remove_child(_timer)
		_timer.queue_free()
		_timer = null

	# Disconnect from our controller.
	if _xr_controller:
		_xr_controller = null


# Our pinch value has changed.
func _on_input_float_changed(action_name : String, value : float) -> void:
	if action_name == pinch_action:
		# Started pinching.
		if not _pinching and value > 0.9:
			_pinching = true
			_pinch_started = Time.get_ticks_msec()
			if _timer:
				_timer.start()

			return

		# Stopped pinching.
		if _pinching and value < 0.5:
			_pinching = false

			if _timer:
				_timer.stop()

			var was_tapped : bool = Time.get_ticks_msec() - _pinch_started < max_tap_duration
			var was_held : bool = _pinch_held

			if _pinch_held:
				_pinch_held = false
			elif was_tapped:
				pinch_tapped.emit(_xr_controller)

			# Always emit released.
			pinch_released.emit(_xr_controller, was_tapped, was_held)

			return


# Our timeout timed out, this is now a long press :)
func _on_timeout():
	_pinch_held = true
	pinch_held.emit(_xr_controller)
#endregion
