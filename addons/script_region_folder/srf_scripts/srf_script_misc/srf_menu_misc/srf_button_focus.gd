@tool
class_name SRFFocusButton
extends Button


""" class """
var _setup_settings: SRFSetupSettings


################################################################################
#region _init_setup

func _setup_class(_arr: Array) -> void:
	for item in _arr:
		if item is SRFSetupSettings:
			_setup_settings = item
	_setup()

func _setup() -> void:
	_set_init()
	self.toggled.connect(_on_toggled)

#endregion
################################################################################
#region set_status

func _set_init() -> void:
	_set_icon_color("btn_focus")
	tooltip_text = _setup_settings._tooltip_dict["btn_focus"]

func _set_icon_color(_color_str: String) -> void:
	self_modulate = _setup_settings._color_dict[_color_str]

func _set_loading_status(_toggled: bool) -> void:
	button_pressed = _toggled
	_change_icon_color(_toggled)

func _change_icon_color(_toggled: bool) -> void:
	if button_pressed:
		_set_icon_color("btn_focus")
	else:
		self_modulate = Color.WHITE

#endregion
################################################################################
#region sig_On_connect

func _on_toggled(_toggled: bool) -> void:
	_change_icon_color(_toggled)

#endregion


