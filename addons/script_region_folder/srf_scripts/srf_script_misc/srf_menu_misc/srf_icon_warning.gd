@tool
class_name SRFIconWarning
extends HBoxContainer


""" class """
var _setup_settings: SRFSetupSettings
var _setup_project: SRFSetupProject

var _name: String
var _is_number_check: bool = false

""" label_timer """
var _time: float = 0
var _interval: float
var _str_index: int = 0

""" onready """
@onready var _warning_label: Label = %WarningLabel
@onready var _warning_texrect: TextureRect = %WarningTextureRect


################################################################################
#region _init_setup

func _setup_class(_arr: Array) -> void:
	for item in _arr:
		if item is SRFSetupProject:
			_setup_project = item
		if item is SRFSetupSettings:
			_setup_settings = item
	_setup()

#endregion
################################################################################
#region _nitification

func _notification(what: int) -> void:
	if what == NOTIFICATION_INTERNAL_PROCESS:
		_time += get_process_delta_time()
		if _time >= _interval:
			_time = 0

			if _str_index < _name.length():
				var char := _name[_str_index]
				_warning_label.text += char
				_str_index += 1
			else:
				self.custom_minimum_size.y = self.size.y
				set_process_internal(false)
				_str_index = 0
				_time = 0

#endregion
################################################################################
#region _setup

func _setup() -> void:
	if _setup_settings != null:
		_set_init_font_size()
		_set_name_label("")
		_set_icon_color(_warning_label, "warning_label")
		_name = _setup_settings._label_dict["warning_label"]
		_warning_label.tooltip_text = _setup_settings._label_dict["warning_label"]
		_is_visible_icon_warning(true)

#endregion
################################################################################
#region _set_status

func _set_name_label(_text: String) -> void:
	_warning_label.text = _text

func _set_icon_color(_node: Node, _color_name: String, _multiply: float = 1.0) -> void:
	var _color: Color = _setup_settings._color_dict[_color_name]
	_node.self_modulate = _color * _multiply
	if _node is Label:
		_setup_settings._set_add_theme_override_font_outline(_node, _color)

func _set_init_font_size() -> void:
	var _font_size: int = _setup_project._get_project_settings_font_size()
	_setup_settings._set_add_theme_override_font_size("font_size", _warning_label, _font_size)

#endregion
################################################################################
#region _is_visible

func _is_visible_icon_warning(_active: bool) -> void:
	_warning_label.set_visible(_active)
	_warning_texrect.set_visible(_active)
	_is_number_check = _active
	if _active:
		_interval = 0.022
		_set_name_label("")
		set_process_internal(true)
	else:
		set_process_internal(false)

#endregion
################################################################################




