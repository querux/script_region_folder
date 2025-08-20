@tool
class_name SRFManualRefreshButton
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

#endregion
################################################################################
#region _set_status

func _set_init() -> void:
	_set_icon_color("btn_m_refresh")
	tooltip_text = _setup_settings._tooltip_dict["btn_m_refresh"]

func _set_icon_color(_color_str: String) -> void:
	self_modulate = _setup_settings._color_dict[_color_str]

#endregion
################################################################################



