@tool
class_name SRFCustomFuncNode
extends MarginContainer


""" class """
var __c: SRFClassManager


var _region_node_arr: Array[SRFCustomNode]:
	set(_value):
		_region_node_arr = _value

var _store_code_edit: CodeEdit:
	set(_value):
		_store_code_edit = _value
	get:
		return _store_code_edit

var _region_type: String
var _store_region_all: Array[int]

var _pressed_data: Array


""" onready """
@onready var _name_label: Label = %NameLabel
@onready var _name_button: Button = %NameButton
@onready var _arrow_texrect: TextureRect = %ArrowTextureRect
@onready var _icon_texrect: TextureRect = %IconTextureRect


################################################################################
#region _init_setup

func _setup_class(_class_arr: Array) -> void:
	for item in _class_arr:
		if item is SRFClassManager:
			__c = item

func _get_owner() -> ScriptRegionFolderDock:
	return get_parent().owner

func _ready() -> void:
	if __c._setup_settings != null:
		_set_init_font_size()
		_set_default_color()
		__c._setup_signal.connect_button_pressed(_name_button, _on_button_pressed)
		__c._setup_signal.connect_settings_changed(__c._setup_project._settings, _on_settings_changed)

#endregion
################################################################################
#region _set_status

func _set_label_name(_name: String) -> void:
	_name_label.text = _name
	_name_button.tooltip_text = _name

func _set_init_font_size() -> void:
	var _font_size: int = __c._setup_project._get_project_settings_font_size()
	__c._setup_settings._set_add_theme_override_font_size("font_size", _name_label, _font_size)

#endregion
################################################################################
#region _set_color

func _get_custom_color(_node: Node, _color_name: String) -> Color:
	var _color: Color

	match _color_name:
		"reg_name":
			_color = __c._setup_project._get_project_settings_text_color()
		"func_difini":
			_color = __c._setup_project._get_project_settings_line_panel_color()
		"line_name":
			_color = __c._setup_project._get_project_settings_region_num_color()
		"comment":
			_color = __c._setup_project._get_project_settings_categ_color()
	return _color

func _set_init_color(_node: Node, _color_name: String, _multiply: float = 1.0) -> void:
	var _color: Color
	var _select: int = __c._setup_project._get_project_settings_used_select()
	var _brightness := __c._setup_project._get_project_settings_font_brightness()
	_color = __c._setup_settings._color_dict[_color_name]

	if _select != 0:
		_color = _get_custom_color(_node, _color_name)
		_multiply = 1.0

	_node.self_modulate = _color * _multiply * _brightness
	__c._setup_settings._set_add_theme_override_font_outline(_node, _color)

func _set_init_color_texture(_node: Node, _color_name: String, _multiply: float = 1.0) -> void:
	var _brightness := __c._setup_project._get_project_settings_font_brightness()
	var _color := __c._setup_settings._color_dict[_color_name]
	_node.self_modulate = _color * _multiply * _brightness

func _set_default_color() -> void:
	_set_init_color(_name_label, "reg_name", 1.3)
	_set_init_color_texture(_icon_texrect, "line_name", 1.12)

func _color_select(_type: String) -> void:
	match _type:
		"":
			_set_init_color(_name_label, "reg_name", 1.3)
		"categ":
			_set_init_color(_name_label, "comment", 1.2)
	_region_type = _type

#endregion
################################################################################
#region _set_add_remove

func _set_child_adding(_node: VBoxContainer, _node_type: String, _data_arr: Array = []) -> void:
	var _scene: MarginContainer = __c._setup_settings._custom_node_dict[_node_type].instantiate()
	_scene._setup_class(__c._setup_arr)

	match _node_type:
		"node_func":
			_scene._store_code_edit = _data_arr[0]
			_node.add_child(_scene)
			_scene._set_init_status(_data_arr)


func _init_child_remove(_node: Node) -> void:
	for child in _node.get_children():
		child.queue_free()

#endregion
################################################################################


##:: signal
################################################################################
#region sig_On_connect

func _on_is_pressed(_data_arr: Array) -> void:
	var _region_num: int = _data_arr[0]
	var _endregion_num: int = _data_arr[1]
	var _name: String = _data_arr[2]

	_pressed_data = _data_arr

	var _dock_main := _get_owner()
	var _vbox_bot: VBoxContainer = _dock_main._vbox_compo_bot
	_init_child_remove(_vbox_bot)

	_set_label_name(_name)
	_color_select(_data_arr[3])

	var _store_data: Array = []

	for num in range(_region_num, _endregion_num):
		var _line_text: String = _store_code_edit.get_line(num)

		if _line_text.begins_with("func"):
			var _line_index: int = 0

			if not _line_text.ends_with(":"):
				while true:
					_line_index += 1

					if _line_text.ends_with(":") or _line_text.contains("#"):
						break
					_line_text += _store_code_edit.get_line(num + _line_index)
					_line_text = _line_text.replace("\t", " ")

			_store_data = [_store_code_edit, num, _line_text]
			_set_child_adding(_vbox_bot, "node_func", _store_data)


func _on_button_pressed() -> void:
	match _region_type:
		"categ":
			_store_code_edit.set_caret_line(_pressed_data[0] + __c._setup_settings._categ_offset)
			_store_code_edit.center_viewport_to_caret()
		"":
			_store_code_edit.set_caret_line(_pressed_data[0] + round(__c._setup_settings._categ_offset * 0.5))
			_store_code_edit.center_viewport_to_caret()

#endregion
################################################################################
#region sig_On_connect External_settings

func _set_init_signal() -> void:
	if not _region_node_arr.is_empty():
		for node in _region_node_arr:
			if not node.is_pressed.is_connected(_on_is_pressed):
				node.is_pressed.connect(_on_is_pressed)

#endregion
################################################################################
#region sig_sett_changed

func _on_settings_changed() -> void:
	var _select: int = __c._setup_project._get_project_settings_used_select()
	var _color_name_label := __c._setup_project._get_project_settings_text_color()

	if _select == 0:
		_set_default_color()
	else:
		_set_settings_changed_color(_color_name_label)

#endregion
################################################################################
#region _sett_changed_color

func _set_settings_changed_color(_color: Color) -> void:
	var _brightness := __c._setup_project._get_project_settings_font_brightness()
	_name_label.self_modulate = _color * _brightness
	__c._setup_settings._set_add_theme_override_font_outline(_name_label, _color)

#endregion
################################################################################






