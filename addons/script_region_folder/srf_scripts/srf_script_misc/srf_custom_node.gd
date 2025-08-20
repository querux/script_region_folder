@tool
class_name SRFCustomNode
extends MarginContainer

signal is_toggled(num: int, _active: bool, _name: String)
signal is_pressed(_data_arr: Array)


""" class """
var __c: SRFClassManager
var _focus_button: SRFFocusButton


var _region_type: String
var _region_line_num: int
var _endregion_line_num: int

var _store_code_edit: CodeEdit:
	set(_value):
		_store_code_edit = _value
	get:
		return _store_code_edit


""" onready """
@onready var _vline_panel: Panel = %VLinePanel
@onready var _line_label: Label = %LineLabel
@onready var _name_label: Label = %NameLabel
@onready var _fold_button: Button = %FoldButton
@onready var _name_button: Button = %NameButton
@onready var _fold_texrect: TextureRect = %FoldTextureRect

@onready var _bg_node_panel: Panel = %BGNodePanel
@onready var _focus_panel: Panel = %FocusPanel


##:: setup
################################################################################
#region _init_setup

func _setup_class(_class_arr: Array) -> void:
	for item in _class_arr:
		if item is SRFClassManager:
			__c = item
		elif item is SRFFocusButton:
			_focus_button = item

#endregion
################################################################################
#region _signal emit

func emit_is_toggled(_signal: Signal, _num: int, _active: bool, _name: String) -> void:
	_signal.emit(_num, _active, _name)

func emit_is_pressed(_signal: Signal, _data_arr: Array) -> void:
	_signal.emit(_data_arr)

#endregion
################################################################################


##:: status
################################################################################
#region _set_ready

func _ready() -> void:
	if __c._setup_settings != null:
		_set_init_font_size()
		_set_ready_signal()
		_is_visible_focus_panel(false)

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_pressed(_name_button, _on_button_pressed)
	__c._setup_signal.connect_mouse_exited(_fold_button, _on_mouse_exited)
	__c._setup_signal.connect_settings_changed(__c._setup_project._settings, _on_settings_changed)

#endregion
################################################################################
#region _set_status

func _set_init_status(_data_arr: Array) -> void:
	_set_line_label(_data_arr[1])
	_set_label_name(_data_arr[2])
	_type_select(_data_arr)
	#await get_tree().process_frame
	_set_default_color()

func _set_line_label(_line: int) -> void:
	_line_label.text = str(_line + 1)
	_region_line_num = _line

func _set_label_name(_name: String) -> void:
	_name_label.text = _name
	_name_button.tooltip_text = _name

func _set_init_font_size() -> void:
	var _font_size: int = __c._setup_project._get_project_settings_font_size()
	__c._setup_settings._set_add_theme_override_font_size("font_size", _line_label, _font_size)
	__c._setup_settings._set_add_theme_override_font_size("font_size", _name_label, _font_size)

func _is_button_pressed(_active: bool) -> void:
	_fold_button.button_pressed = _active

func _is_visible_focus_panel(_active: bool) -> void:
	_focus_panel.visible = _active

#not use
func _set_for_scroll_container() -> void:
	var _offset: int = 10
	var _font: Font = _name_label.get_theme_font("font")
	var _font_size: int = _name_label.get_theme_font_size("font_size")
	var _text_width: float = _font.get_string_size(_name_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1,_font_size).x
	_name_label.custom_minimum_size.x = _text_width + _offset

func _type_select(_arr: Array) -> void:
	if _arr[3] is int:
		_endregion_line_num = _arr[3]
		_region_type = ""
		__c._setup_signal.connect_button_toggled(_fold_button, _on_button_toggled)
	elif _arr[3] is String:
		_region_type = _arr[3]

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
		"bg_color_node":
			_color = __c._setup_project._get_project_settings_bg_color()
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

func _set_icon_button_toggled(_icon_name: String) -> void:
	var _color: Color
	var _select: int = __c._setup_project._get_project_settings_used_select()
	var _brightness := __c._setup_project._get_project_settings_font_brightness()
	_color = __c._setup_settings._color_dict[_icon_name]

	if _select != 0:
		_color = __c._setup_project._get_project_settings_region_icon_color()
		if _fold_button.button_pressed:
			_color
		else:
			_color = _color.darkened(0.6)

	_fold_texrect.texture = __c._setup_settings._icon_dict[_icon_name]
	_fold_texrect.self_modulate = _color * (_brightness *1.0)

func _set_init_color_bg(_node: Node, _color_name: String) -> void:
	var _color: Color
	var _select: int = __c._setup_project._get_project_settings_used_select()
	var _brightness := __c._setup_project._get_project_settings_font_brightness()
	_color = __c._setup_settings._color_dict[_color_name]

	if _select != 0:
		_color = _get_custom_color(_node, _color_name)
		#_color = _color.lightened(0.03)
	_node.self_modulate = _color * _brightness

func _set_default_color() -> void:
	_set_init_color(_vline_panel, "func_difini", 0.9)
	_set_init_color(_line_label, "line_name", 1.1)
	_set_init_color_bg(_bg_node_panel, "bg_color_node")
	_color_select(_region_type)

	if _fold_button.button_pressed:
		_set_icon_button_toggled("icon_fold")
		if _region_type == "categ":
			_set_icon_button_toggled("icon_unfold")
	else:
		_set_icon_button_toggled("icon_unfold")

func _color_select(_type: String) -> void:
	match _type:
		"":
			_set_init_color.call_deferred(_name_label, "reg_name", 1.3)
		"categ":
			_set_init_color(_name_label, "comment", 1.2)

#endregion
################################################################################


##:: signal
################################################################################
#region sig_On_connect

func _on_mouse_exited() -> void:
	_fold_button.release_focus()

func _on_button_pressed() -> void:
	if _focus_button.button_pressed:
		match _region_type:
			"categ":
				if is_instance_valid(_store_code_edit):
					_store_code_edit.set_caret_line(_region_line_num + __c._setup_settings._categ_offset)
					_store_code_edit.center_viewport_to_caret()
			"":
				if is_instance_valid(_store_code_edit):
					_store_code_edit.set_caret_line(_region_line_num + round(__c._setup_settings._categ_offset * 0.5))
					_store_code_edit.center_viewport_to_caret()
	__c._plugin._dock_main._focus_handel()
	_store_code_edit.deselect()
	var _data_arr: Array = [_region_line_num, _endregion_line_num, _name_label.text, _region_type]
	emit_is_pressed(is_pressed, _data_arr) ## to_SRFCustomFuncNode


func _on_button_toggled(_toggled: bool) -> void:
	if not _store_code_edit.is_line_code_region_start(_region_line_num):
		var _line: int = _region_line_num + 1
		__c._debug_manager._debug_manager_fold_line("warning", self, "line can't be folded", _line, "line_81")
	else:
		if not _toggled:
			_store_code_edit.unfold_line(_region_line_num)
			_set_icon_button_toggled("icon_unfold")
		else:
			_store_code_edit.fold_line(_region_line_num)
			_set_icon_button_toggled.call_deferred("icon_fold")

			## region_color_change
			#__c._plugin._dock_main._change_categ_line_color.call_deferred(
				#__c._plugin._dock_main._reg_num_arr, "reg"
				#)
		emit_is_toggled(is_toggled, _region_line_num, _toggled, _name_label.text) # -> class_node

#endregion
################################################################################
#region sig_sett_changed

func _on_settings_changed() -> void:
	var _select: int = __c._setup_project._get_project_settings_used_select()

	var _color_arr: Array[Color] = _get_settings_changed_color()

	if _select == 0:
		_set_default_color()
	else:
		_set_settings_changed_color(_color_arr)

#endregion
################################################################################
#region _setget_settings_changed_color

func _get_settings_changed_color() -> Array[Color]:
	var _color_bg := __c._setup_project._get_project_settings_bg_color()
	var _color_vline_panel := __c._setup_project._get_project_settings_line_panel_color()
	var _color_name_label := __c._setup_project._get_project_settings_text_color()
	var _color_reg_num := __c._setup_project._get_project_settings_region_num_color()
	var _color_reg_icon := __c._setup_project._get_project_settings_region_icon_color()
	var _color_category := __c._setup_project._get_project_settings_categ_color()
	#_color_bg = _color_bg.lightened(0.03)

	return [
			_color_vline_panel,
			_color_name_label,
			_color_reg_num,
			_color_reg_icon,
			_color_bg,
			_color_category,
			]

func _set_settings_changed_color(_color_arr: Array[Color]) -> void:
	var _brightness := __c._setup_project._get_project_settings_font_brightness()
	_vline_panel.self_modulate = _color_arr[0] * _brightness

	match _region_type:
		"":
			_name_label.self_modulate = _color_arr[1] * _brightness
		"categ":
			_name_label.self_modulate = _color_arr[5] * _brightness

	_line_label.self_modulate = _color_arr[2] * _brightness
	_bg_node_panel.self_modulate = _color_arr[4] * _brightness


	__c._setup_settings._set_add_theme_override_font_outline(_vline_panel, _color_arr[0])
	__c._setup_settings._set_add_theme_override_font_outline(_name_label, _color_arr[1])
	__c._setup_settings._set_add_theme_override_font_outline(_line_label, _color_arr[2])

	if _fold_button.button_pressed:
		_fold_texrect.self_modulate = _color_arr[3] * _brightness
	else:
		_fold_texrect.self_modulate = _color_arr[3].darkened(0.6) * _brightness

#endregion
################################################################################


