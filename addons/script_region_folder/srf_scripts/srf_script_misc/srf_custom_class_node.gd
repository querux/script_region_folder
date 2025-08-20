@tool
class_name SRFCustomClassNode
extends MarginContainer


""" class """
var __c: SRFClassManager
var _plugin: ScriptRegionFolderPlugin


var _region_node_arr: Array[SRFCustomNode]:
	set(_value):
		_region_node_arr = _value

var _store_code_edit: CodeEdit:
	set(_value):
		_store_code_edit = _value
	get:
		return _store_code_edit


var _fold_count: int = 0
var _store_region_all: Array[int]

var _is_fold_all_cancell: bool = false
var _is_loading_data: bool = false


""" onready """
@onready var _name_label: Label = %NameLabel
@onready var _name_button: Button = %NameButton
@onready var _all_fold_button: SRFAllFoldButton = %AllFoldButton

@onready var _arrow_texrect: TextureRect = %ArrowTextureRect
@onready var _script_texrect: TextureRect = %ScriptTextureRect


################################################################################
#region init_setup

func _setup_class(_class_arr: Array) -> void:
	for item in _class_arr:
		if item is SRFClassManager:
			__c = item
		elif item is ScriptRegionFolderPlugin:
			_plugin = item

func _get_owner() -> ScriptRegionFolderDock:
	return get_parent().owner

#endregion
################################################################################
#region set_ready

func _ready() -> void:
	if __c._setup_settings != null:
		_set_init_font_size()
		_set_init_color(_script_texrect, "func_difini", 0.9)
		_set_init_color(_name_label, "class_name", 1.07)
		_all_fold_button._setup_class(__c._setup_arr)
		__c._setup_signal.connect_button_toggled(_all_fold_button, _on_button_toggled)
		__c._setup_signal.connect_button_pressed(_name_button, _on_button_pressed)
		__c._setup_signal.connect_scene_saved(_plugin, _on_scene_saved)

#endregion
################################################################################
#region set_status

func _set_label_name(_name: String) -> void:
	_name_label.text = _name
	_name_button.tooltip_text = _name

func _set_init_font_size() -> void:
	var _font_size: int = __c._setup_project._get_project_settings_font_size()
	__c._setup_settings._set_add_theme_override_font_size("font_size", _name_label, _font_size)

func _set_init_color(_node: Node, _color_name: String, _multiply: float = 1.0) -> void:
	var _brightness := __c._setup_project._get_project_settings_font_brightness()
	var _color := __c._setup_settings._color_dict[_color_name]
	_node.self_modulate = _color * _multiply * _brightness
	if _node is Label:
		__c._setup_settings._set_add_theme_override_font_outline(_node, _color)

#endregion
################################################################################
#region _func_options

func _is_change_fold_all(_active: bool) -> void:
	_is_fold_all_cancell = _active

func _set_init_signal() -> void:
	if not _region_node_arr.is_empty():
		for node in _region_node_arr:
			if not node.is_toggled.is_connected(_on_is_toggled):
				node.is_toggled.connect(_on_is_toggled)
	__c._setup_signal.connect_gui_input(_store_code_edit, _on_gui_input)

func _check_fold_count(_num: int, _active: bool) -> void:
	var _count_size: int = _store_region_all.size()
	if _store_region_all.has(_num):
		_fold_count += 1 if _active else -1
		_fold_count = clampi(_fold_count, 0, 999)
	if _fold_count >= _count_size:
		_all_fold_button.button_pressed = true

func _has_loading_data() -> void:
	var _class_name: String = _name_label.text
	for key in __c._setup_saveload._data:
		if _class_name.match(key):
			_is_loading_data = true
			return
	_is_loading_data = false

#endregion
################################################################################


##:: signal
################################################################################
#region sig_On_connect

func _on_is_toggled(_region_num: int, _toggled: bool, _label_name: String) -> void:
	if not _toggled:
		_is_change_fold_all(true)
		_all_fold_button.button_pressed = false
	_check_fold_count(_region_num, _toggled)
	if not _is_loading_data:
		var _data_arr: Array = [_region_num, _label_name, _toggled]
		_saving_data_region_toggle(_data_arr, "toggle")

func _on_button_toggled(_toggled: bool) -> void:
	if not _toggled:
		if not _is_fold_all_cancell:
			for node in _region_node_arr:
				node._is_button_pressed(false)

			for num in _store_region_all:
				_store_code_edit.unfold_line(num)
		_is_change_fold_all(false)
	else:
		for node in _region_node_arr:
			node._is_button_pressed(true)

		for num in _store_region_all:
			_store_code_edit.fold_line(num)

		## Return to the top when all fold.
		if not _store_region_all.is_empty():
			pass
			#var _offset: int = 25
			#_store_code_edit.set_caret_line(_store_region_all[0] - _offset)
		_is_change_fold_all(false)
	_all_fold_button._change_icon_color(_toggled)

func _on_button_pressed() -> void:
	if _store_code_edit != null:
		_store_code_edit.set_caret_line(0)

func _on_scene_saved(_filepath: String) -> void:
	call_deferred("_saving_data_region_toggle", [], "save")

#endregion
################################################################################
#region sig_gui_input

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_is_folded.call_deferred()
			#print("click")

func _is_folded() -> void:
	var _arr := _store_code_edit.get_folded_lines()

	if _arr.is_empty():
		for node in _region_node_arr:
			node._fold_button.button_pressed = false
		return

	for line in _arr:
		if _store_code_edit.is_line_folded(line):
			for node in _region_node_arr:
				var _num: int = int(node._line_label.text) - 1
				if node != null:
					if _num == line:
						if node._focus_button.button_down:
							node._fold_button.button_pressed = true
					if not _arr.has(_num):
						node._fold_button.button_pressed = false

#endregion
################################################################################


##:: saveload
################################################################################
#region _data_save_region_toggle

func _saving_data_region_toggle(_data_arr: Array, _type: String) -> void:
	match _type:
		"toggle":
				var _data: Dictionary = {
					"key_name": _name_label.text,
					"reg_name": _data_arr[1],
					"reg_togg": _data_arr[2],
				}
				_pass_data(_data)
		"save":
			for node in _region_node_arr:
				var _reg_name: String = node._name_label.text
				var _reg_btn: bool = node._fold_button.button_pressed

				var _data: Dictionary = {
					"key_name": _name_label.text,
					"reg_name": _reg_name,
					"reg_togg": _reg_btn,
				}
				_pass_data(_data)

func _pass_data(_data_dict: Dictionary) -> void:
	var _dock_main := _get_owner()
	_dock_main._data_saving(_data_dict)

#endregion
################################################################################
#region _data_load_region_toggle

func _loading_data_region_toggle() -> void:
	var _save_data: Dictionary = __c._setup_saveload._data
	var _class_name: String = _name_label.text
	var _node_data: Dictionary = _get_region_nodes_data()

	if not _save_data.has(_class_name):
		_is_loading_data = false
		return

	var _saved_regions: Dictionary = _save_data[_class_name]

	for node in _region_node_arr:
		var _reg_name: String = node._name_label.text
		if _node_data.has(_reg_name) and _saved_regions.has(_reg_name):
			node._fold_button.button_pressed = _saved_regions[_reg_name]
	_is_loading_data = false

func _get_region_nodes_data() -> Dictionary:
	var _node_data: Dictionary
	for node in _region_node_arr:
		var _reg_name: String = node._name_label.text
		var _reg_btn: bool = node._fold_button.button_pressed
		if not _node_data.has(_reg_name):
			_node_data[_reg_name] = _reg_btn
	return _node_data

#endregion
################################################################################



