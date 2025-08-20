@tool
class_name SRFCustomNodeFunc
extends MarginContainer


""" class """
var __c: SRFClassManager


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
@onready var _name_button: Button = %NameButton
@onready var _name_label: RichTextLabel = %NameLabel

@onready var _bg_node_func_panel: Panel = %BGNodeFuncPanel


##:: setup
################################################################################
#region _init_setup

func _setup_class(_class_arr: Array) -> void:
	for item in _class_arr:
		if item is SRFClassManager:
			__c = item

#endregion
################################################################################
#region _set_ready

func _ready() -> void:
	if __c._setup_settings != null:
		_set_init_font_size()
		_set_default_color()
		__c._setup_signal.connect_button_pressed(_name_button, _on_button_pressed)
		__c._setup_signal.connect_settings_changed(__c._setup_project._settings, _on_settings_changed)

#endregion
################################################################################


##:: status
################################################################################
#region _set_status

func _set_init_status(_data_arr: Array) -> void:
	var _rich_names: Array[String] = _regex_bbc_name_string(_data_arr[2])
	var _name: String = _get_total_rich_name(_rich_names)
	_set_line_label(_data_arr[1])
	_set_label_name(_name)
	_name_button.tooltip_text = _data_arr[2]

func _set_line_label(_line: int) -> void:
	_line_label.text = str(_line + 1)
	_region_line_num = _line

func _set_label_name(_name: String) -> void:
	_name_label.text = _name
	_set_for_scroll_container()

func _set_init_font_size() -> void:
	var _font_size: int = __c._setup_project._get_project_settings_font_size()
	__c._setup_settings._set_add_theme_override_font_size("font_size", _line_label, _font_size)
	__c._setup_settings._set_add_theme_override_font_size("normal_font_size", _name_label, _font_size)

func _set_for_scroll_container() -> void:
	var _offset: int = 5
	var _content_width: int = _name_label.get_content_width()
	_name_label.custom_minimum_size.x = _content_width + _offset

#endregion
################################################################################
#region _set_color

func _get_custom_color(_node: Node, _color_name: String) -> Color:
	var _color: Color

	match _color_name:
		"var_func":
			_color = __c._setup_project._get_project_settings_line_panel_color()
		"line_name":
			_color = __c._setup_project._get_project_settings_region_num_color()
		"bg_color_node":
			_color = __c._setup_project._get_project_settings_bg_color()
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

func _set_init_color_bg(_node: Node, _color_name: String) -> void:
	var _color: Color
	var _select: int = __c._setup_project._get_project_settings_used_select()
	var _brightness := __c._setup_project._get_project_settings_font_brightness()
	_color = __c._setup_settings._color_dict[_color_name]

	if _select != 0:
		_color = _get_custom_color(_node, _color_name)
	_node.self_modulate = _color * _brightness

func _set_default_color() -> void:
	_set_init_color(_vline_panel, "var_func", 0.9)
	_set_init_color(_line_label, "line_name", 1.1)
	_set_init_color_bg(_bg_node_func_panel, "bg_color_node")

#endregion
################################################################################
#region sig_On_connect

func _on_button_pressed() -> void:
	var _offset_end: int = 34
	var _offset_start: int = 10
	_store_code_edit.set_caret_line(_region_line_num + _offset_end)
	_store_code_edit.set_caret_line(_region_line_num - _offset_start)

#endregion
################################################################################


##:: rich_text
################################################################################
#region _rich_text_process

func _regex_bbc_name_string(_text: String) -> Array[String]:
	var _regex := RegEx.new()
	var _line := _text.strip_edges().rstrip(":")

	_regex.compile(r"^func\s*(\w+)\s*\((.*?)\)\s*(?:->\s*([^\s:]+))?(?::)?(?:\s*#.*)?$")

	var _regex_result := _regex.search(_line)

	if _regex_result == null:
		return []

	var _method_str := _regex_result.get_string(1)
	var _output: Array[String] = []

# func_group
	var _func_name := _change_rich_text_color("var_func", "func ", 0.95)
	var _method_name := _change_rich_text_color_bold("func_difini", _method_str, 0.9)
	var _left_paren := _change_rich_text_color("symbol_color", " (")
	var _right_paren := _change_rich_text_color("symbol_color", ")")

	#_output.push_back(_func_name) # as_you_like
	_output.push_back(_method_name)
	_output.push_back(_left_paren)

# arg_group
	var _args_str := _regex_result.get_string(2).strip_edges()
	if _args_str != "":
		var _args := _args_str.split(",", false)
		for i in _args.size():
			var _arg := _args[i].strip_edges()
			if _arg == "":
				continue
			var _parts := _arg.split(":", false)
			if _parts.size() >= 2:
				var _arg_str := _parts[0].strip_edges()
				var _type_and_default := _parts[1].strip_edges().split("=", false)
				var _arg_type_str := _type_and_default[0].strip_edges()

				var _arg_name := _change_rich_text_color("text_color", _arg_str + ": ", 0.9)

				if _arg_type_str.find("[") != -1 and _arg_type_str.find("]") != -1:
					_output.push_back(_arg_name)

					var _args_split: Array[String] = _check_find_args_text(_arg_type_str)
					for arg in _args_split:
						_output.push_back(arg)
				else:
					var _arg_type_name := _change_rich_text_color("base_type", _arg_type_str)
					_output.push_back(_arg_name)
					_output.push_back(_arg_type_name)
			else:
				_output.push_back(_arg)

			if i < _args.size() -1:
				_output.push_back(", ")

	_output.push_back(_right_paren)

# end_group
	var _return_type := _regex_result.get_string(3)
	if _return_type != "":
		_output.push_back(" -> ")

		if _return_type.find("[") != -1 and _return_type.find("]") != -1:
			var _args_split: Array[String] = _check_find_args_text(_return_type)
			for arg in _args_split:
				_output.push_back(arg)
		else:
			var _return_type_name := _change_rich_text_color("base_type", _return_type)
			_output.push_back(_return_type_name)

	return _output

#not use: simple regex
func _regex_compile_string(_text: String) -> void:
	var _regex := RegEx.new()
	var _line := _text.strip_edges().rstrip(":")

	_regex.compile(r"^func\s*(\w+)\s*(\([^\)]*\)\s*->)?\s*(\w+)?$")

	var _output: Array[String] = ["func"]
	var _regex_result := _regex.search(_line)

	for i in range(1, _regex_result.strings.size()):
		_output.push_back(_regex_result.get_string(i))
	#print("output: ", _output)

#endregion
################################################################################
#region _rich_text_bbc_options

func _change_rich_text_color(_color: String, _text: String, _multiply: float = 1.0) -> String:
	var _brightness := __c._setup_project._get_project_settings_font_brightness()
	var _load_color := __c._setup_settings._color_dict[_color] * _multiply * _brightness
	return "[color=%s]%s[/color]" % [_load_color.to_html(false), _text]

func _change_rich_text_color_bold(_color: String, _text: String, _multiply: float = 1.0) -> String:
	var _load_color := __c._setup_settings._color_dict[_color] * _multiply
	return "[b][color=%s]%s[/color][/b]" % [_load_color.to_html(false), _text]

func _get_total_rich_name(_bbc: Array[String]) -> String:
	var _name: String
	for i in _bbc:
		_name += i
	return _name

func _check_find_args_text(_args_text: String) -> Array[String]:
	var _left_bracket := _change_rich_text_color("symbol_color", " [")
	var _right_bracket := _change_rich_text_color("symbol_color", "]")

	var _base := _args_text.substr(0, _args_text.find("["))
	var _inner_text := _args_text.substr(
		_args_text.find("[") + 1, _args_text.find("]") - _args_text.find("[") - 1
		)

	var _base_color := _change_rich_text_color("base_type", _base)
	var _inner_color := _change_rich_text_color("base_type", _inner_text)

	return [_base_color, _left_bracket, _inner_color, _right_bracket]

#endregion
################################################################################


##:: sett_changed
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
#region _setget_sett_changed_color

func _get_settings_changed_color() -> Array[Color]:
	var _color_bg := __c._setup_project._get_project_settings_bg_color()
	var _color_vline_panel := __c._setup_project._get_project_settings_line_panel_color()
	var _color_reg_num := __c._setup_project._get_project_settings_region_num_color()

	return [_color_vline_panel, _color_reg_num, _color_bg]


func _set_settings_changed_color(_color_arr: Array[Color]) -> void:
	var _brightness := __c._setup_project._get_project_settings_font_brightness()

	_vline_panel.self_modulate = _color_arr[0] * _brightness
	_line_label.self_modulate = _color_arr[1] * _brightness
	_bg_node_func_panel.self_modulate = _color_arr[2] * _brightness

	__c._setup_settings._set_add_theme_override_font_outline(_vline_panel, _color_arr[0])
	__c._setup_settings._set_add_theme_override_font_outline(_line_label, _color_arr[1])

#endregion
################################################################################




