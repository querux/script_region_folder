@tool
class_name SRFAllFoldButton
extends Button


""" class """
var _setup_settings: SRFSetupSettings
var _setup_project: SRFSetupProject


################################################################################
#region _init_setup

func _setup_class(_class_arr: Array) -> void:
	for item in _class_arr:
		if item is SRFSetupSettings:
			_setup_settings = item
		elif item is SRFSetupProject:
			_setup_project = item
	_set_init()

#endregion
################################################################################
#region _set_status

func _set_init() -> void:
	tooltip_text = _setup_settings._tooltip_dict["all_fold"]
	_set_icon_color("all_unfold")

func _set_icon_color(_color_str: String) -> void:
	var _brightness := _setup_project._get_project_settings_font_brightness()
	var _color := _setup_settings._color_dict[_color_str]
	self_modulate = _color * (_brightness *1.1)

func _set_loading_status(_toggled: bool) -> void:
	button_pressed = _toggled
	_change_icon_color(_toggled)

func _change_icon_color(_toggled: bool) -> void:
	if button_pressed:
		_set_icon_color("all_fold")
	else:
		_set_icon_color("all_unfold")

#endregion
################################################################################




