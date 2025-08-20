@tool
class_name SRFTimerUtility
extends Node


var _counter: int = 0

var _node: Node
var _timer: Timer


################################################################################
#region timer_init

func _init(_root: Node) -> void:
	_node = _root

	if _timer == null:
		_timer = Timer.new()

#endregion
################################################################################
#region type_press

func _set_timer_start_pressed(_timeout: float, _border: int, _pressed: int) -> bool:
	if not _timer.is_connected("timeout", _on_timer_timeout):
		_timer.timeout.connect(_on_timer_timeout)

	_counter += _pressed
	if _counter >= _border:
		return true

	_timer.set_wait_time(_timeout)

	if not _timer.is_inside_tree():
		_node.add_child(_timer)

	if _timer.is_inside_tree():
		_timer.start()

	return false


func _on_timer_timeout() -> void:
	_counter = 0
	_timer.stop()
	_node.remove_child.call_deferred(_timer)

#endregion
################################################################################
#region type_auto

func _set_timer_start_auto(
	_timeout: float, _border: int, _pressed: int, _on_timeout_auto: Callable
	) -> void:
	if _node == null:
		return

	if not _timer.is_connected("timeout", _on_timeout_auto):
		_timer.timeout.connect(_on_timeout_auto)

	_timer.set_wait_time(_timeout)

	if not _timer.is_inside_tree():
		_node.add_child(_timer)

	if _timer.is_stopped():
		_counter += _pressed
		if _counter >= _border:
			if _timer.is_inside_tree():
				_timer.start()


func _init_timeout_auto() -> void:
	if not _timer.is_stopped():
		_counter = 0
		_timer.stop()
		_node.remove_child.call_deferred(_timer)

#endregion
################################################################################
#region type_increase

func _set_timer_start_increase(
	_timeout: float, _border: int, _pressed: int, _init_timeout_increase: Callable
	) -> void:
	if _node == null:
		return

	if not _timer.is_connected("timeout", _init_timeout_increase):
		_timer.timeout.connect(_init_timeout_increase)

	_timer.set_wait_time(_timeout)

	_counter += _pressed

	if _counter >= _border:
		if not _timer.is_inside_tree():
			_node.add_child(_timer)

		if _timer.is_inside_tree():
			_timer.stop()
			_timer.start()
			_counter = 0

	#prints("timer: ", _counter, _timer.time_left)

func _init_timeout_increase() -> void:
	if not _timer.is_stopped():
		_timer.stop()
		_node.remove_child.call_deferred(_timer)
	_counter = 0

#endregion
################################################################################

func _exit_tree() -> void:
	if _timer != null:
		_timer.queue_free()
