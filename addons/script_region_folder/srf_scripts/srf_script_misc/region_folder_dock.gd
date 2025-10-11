@tool
class_name ScriptRegionFolderDock
extends HSplitContainer


""" class """
var __c: SRFClassManager
var _plugin: ScriptRegionFolderPlugin

var _timer_refresh: SRFTimerUtility
var _timer_auto_refresh: SRFTimerUtility

var _region_node_arr: Array[SRFCustomNode]
var _reg_num_arr: Array[int]
var _categ_num_arr: Array[int]
var _colors: Dictionary

var _script_item_list: ItemList
var _script_editor: ScriptEditor

var _store_code_edit: CodeEdit
var _store_button: Button

""" focus """
var _store_region_dict: Dictionary

var _caret_changed_border: int = 50
var _scroll_counter: int = 0

var _is_saving: bool = false
var _is_editor_sc_change: bool = false


""" bg_panel """
@onready var _bg_menu_panel: Panel = %BGMenuPanel
@onready var _bg_panel_top: Panel = %BGPanel_top
@onready var _bg_panel_bot: Panel = %BGPanel_bot

""" container """
@onready var _vbox: VBoxContainer = %VBoxContainer
@onready var _vsplit: VSplitContainer = %VSplitContainer

@onready var _vcontainer_top: VBoxContainer = %VContainer_top
@onready var _vcontainer_bot: VBoxContainer = %VContainer_bot
@onready var _vbox_compo_top: VBoxContainer = %VBoxComponentTop
@onready var _vbox_compo_bot: VBoxContainer = %VBoxComponentBot

""" buttons """
@onready var _icon_warninng: SRFIconWarning = %IconWarninng
@onready var _focus_button: SRFFocusButton = %FocusButton
@onready var _auto_refresh_button: SRFAutoRefreshButton = %AutoRefreshButton
@onready var _manual_refresh_button: SRFManualRefreshButton = %ManualRefreshButton


##:: setup
################################################################################
#region setup_arr

func _setup_class(_arr: Array) -> void:
	for item in _arr:
		if item is SRFClassManager:
			__c = item
		elif item is ScriptRegionFolderPlugin:
			_plugin = item
		elif item is ItemList:
			_script_item_list = item

	_timer_refresh = SRFTimerUtility.new(self)
	_timer_auto_refresh = SRFTimerUtility.new(self)
	_script_editor = __c._setup_utility._get_sc_editor()
	_store_code_edit = _get_code_edit()

	_colors = {
		"symbol": __c._setup_settings._color_dict["symbol_color"],
		"trans" : __c._setup_settings._color_dict["transparent"],
	}

#endregion
################################################################################
#region _notification

func _notification(what: int) -> void:
	if what == NOTIFICATION_INTERNAL_PROCESS:
		_is_saving = false

		if _is_saving:
			return
		__c._setup_saveload._save_data_check_exists()
		set_process_internal(false)

#endregion
################################################################################


##:: set_status
################################################################################
#region _ready

func _ready() -> void:
	if _plugin != null:
		_setup_buttons()
		_set_initialize()
		_set_ready_signal()
		_set_default_color()
		_data_loading()
		__c._setup_arr.push_back(_focus_button)

func _set_ready_signal() -> void:
	__c._setup_signal.connect_button_toggled(_focus_button, _data_saving_on_button_toggled.bind(_focus_button))
	__c._setup_signal.connect_button_toggled(_auto_refresh_button, _data_saving_on_button_toggled.bind(_auto_refresh_button))
	__c._setup_signal.connect_item_selected(_script_item_list, _on_item_selected)
	__c._setup_signal.connect_button_pressed(_manual_refresh_button, _on_refresh_pressed)
	__c._setup_signal.connect_scene_saved(_plugin, _on_scene_saved)
	__c._setup_signal.connect_editor_sc_changed(_script_editor, _on_editor_sc_changed)
	__c._setup_signal.connect_settings_changed(__c._setup_project._settings, _on_settings_changed)

func _setup_buttons() -> void:
	_focus_button._setup_class(__c._setup_arr)
	_icon_warninng._setup_class(__c._setup_arr)
	_auto_refresh_button._setup_class(__c._setup_arr)
	_manual_refresh_button._setup_class(__c._setup_arr)

#endregion
################################################################################


##:: region_instance
################################################################################
#region _init_add_remove_container

func _set_initialize() -> void:
	_init_removed()
	_init_adding()

func _init_adding() -> void:
	_set_child_adding(_vcontainer_top, "root_class")
	_set_child_adding(_vcontainer_bot, "root_func")

func _init_removed() -> void:
	_init_child_remove(_vcontainer_top, "margin")
	_init_child_remove(_vbox_compo_top, "component")
	_init_child_remove(_vcontainer_bot, "margin")
	_init_child_remove(_vbox_compo_bot, "component")

func _init_child_remove(_node: Node, _remove_type: String) -> void:
	for child in _node.get_children():
		match _remove_type:
			"margin":
				if child is MarginContainer:
					child.queue_free()
					return
			"component":
				child.queue_free()
			_:
				push_warning("Not matching name: %s" % _remove_type)

#endregion
################################################################################
#region _init_add_remove

func _set_child_adding(_node: VBoxContainer, _node_type: String, _data_arr: Array = []) -> void:
	var _scene: MarginContainer = __c._setup_settings._custom_node_dict[_node_type].instantiate()
	_scene._setup_class(__c._setup_arr)

	match _node_type:
		"root_class", "root_func":
			_node.add_child(_scene)
			_scene._region_node_arr.clear()
			_scene.get_parent().move_child(_scene, 0)

			if _data_arr.is_empty():
				_scene._set_label_name(__c._setup_settings._label_dict[_node_type])
			else:
				_scene._region_node_arr.append_array(_region_node_arr)
				_scene._store_code_edit = _data_arr[0]
				_scene._store_region_all = _data_arr[3]
				_scene._set_label_name(_data_arr[2])
				_scene._set_init_signal()
				if _node_type == "root_class":
					_scene._has_loading_data()
					_scene._loading_data_region_toggle()

				elif _node_type == "root_func":
					_scene._set_label_name(__c._setup_settings._label_dict[_node_type])
		"node_child":
			if _data_arr.is_empty():
				push_warning("data is empty")
			else:
				_scene._store_code_edit = _data_arr[0]
				_node.add_child(_scene)
				_scene._set_init_status(_data_arr)
				_region_node_arr.push_back(_scene)

	var _prop: Variant = _scene.get("_region_line_num")
	if _prop != null:
		_store_region_dict[_scene._region_line_num] = _scene

#endregion
################################################################################


##:: region_
################################################################################
#region get_code_edit

func _get_code_edit() -> CodeEdit:
	var _sc_current: ScriptEditorBase = _script_editor.get_current_editor()
	if _sc_current != null:
		var _code_edit := _sc_current.get_base_editor() as CodeEdit
		return _code_edit
	return null

func _get_list_hide_button(_code_edit: CodeEdit) -> void:
	if _code_edit != null:
		var _parent := _code_edit.get_parent()
		if _parent != null:
			_store_button = __c._setup_utility._find_get_sc_list_button(_parent)
		if _store_button != null:
			_check_is_connect_button(_store_button, "connect")

#endregion
################################################################################
#region region_create

func _region_create() -> void:
	var _code_edit := _get_code_edit()
	if _is_selected_item():
		_check_is_connect(_code_edit, "connect")
		_get_list_hide_button(_code_edit)
		_store_region_dict.clear()

		if _code_edit != null:
			var _data_arr: Array = []
			var _class_name: String = ""
			var _class_data: Array = []
			var _region_nums: Array[int] = []
			var _has_class_name: bool = false

			var _line_count: int = _code_edit.get_line_count()

			for num in _line_count:
				var _line_text: String = _code_edit.get_line(num)

				if _line_text.begins_with("class_name"):
					_class_name = _line_text.substr(10).strip_edges()
					_class_data = [_code_edit, num, _class_name]
					_has_class_name = true

				if _line_text.begins_with("##::"):
					var _category_line_num: int = num
					var _region_name: String = _line_text.substr(4).strip_edges()
					_data_arr = [_code_edit, _category_line_num, _region_name, "categ"]
					_data_arr.push_back(_category_line_num)
					_set_child_adding(_vbox_compo_top, "node_child", _data_arr)
					_categ_num_arr.push_back(_category_line_num)
					continue

				if _line_text.begins_with("#region"):
					var _region_line_num: int = num
					var _region_name: String = _line_text.substr(7).strip_edges()
					_data_arr = [_code_edit, _region_line_num, _region_name]
					_region_nums.push_back(_region_line_num)
					_reg_num_arr.push_back(_region_line_num)

				if _line_text.begins_with("#endregion"):
					var _endregion_line_num: int = num
					_data_arr.push_back(_endregion_line_num)
					_set_child_adding(_vbox_compo_top, "node_child", _data_arr)

			if not _has_class_name:
				_class_data = [_code_edit, -1, ""]

			if not _class_data.is_empty():
				_class_data.push_back(_region_nums)
				_set_child_adding(_vcontainer_top, "root_class", _class_data)
				_set_child_adding(_vcontainer_bot, "root_func", _class_data)
				_region_node_arr.clear()

#endregion
################################################################################
#region region_util

func _get_current_region_num() -> Array[int]:
	var _current_num_arr: Array[int]
	var _code_edit := _get_code_edit()
	var _line_count := _code_edit.get_line_count()
	for num in _line_count:
		var _line_text: String = _code_edit.get_line(num)
		if _line_text.begins_with("#region"):
			_current_num_arr.push_back(num)
	return _current_num_arr

func _get_child_region_num() -> Array[int]:
	var _child_region_num_arr: Array[int]
	for child in _vbox_compo_top.get_children():
		var _num: int = child._region_line_num
		_child_region_num_arr.push_back(_num)
	return _child_region_num_arr

func _compare_region_num() -> bool:
	var _cur_num := _get_current_region_num()
	var _child_num := _get_child_region_num()
	if _cur_num == _child_num:
		return false
	return true

#endregion
################################################################################
#region category_color

func _set_categ_line_color() -> Array[Color]:
	var _select: int = __c._setup_project._get_project_settings_used_select()
	if _select == 0:
		return [
			_colors["symbol"],
			_colors["symbol"],
			]
	else:
		return [
			__c._setup_project._get_project_settings_categ_color(),
			__c._setup_project._get_project_settings_text_color(),
			]

func _change_categ_line_color(_arr: Array, _type: String) -> void:
	var _code_edit := _get_code_edit()
	if _code_edit != null:
		var _ccolor: Color = _set_categ_line_color()[0]
		var _rcolor: Color = _set_categ_line_color()[1]
		_ccolor.a = 0.12
		_rcolor.a = 0.2
		match _type:
			"categ":
				for i: int in _arr:
					if i < _code_edit.get_last_full_visible_line():
						if _code_edit.get_line_background_color(i) != _colors["trans"]:
							return
						var _text: String = _code_edit.get_line(i)
						if _text.begins_with("##::"):
							_code_edit.set_line_background_color(i, _ccolor)
			"reg":
				for i: int in _arr:
					if i < _code_edit.get_last_full_visible_line():
						var _text: String = _code_edit.get_line(i)
						if _code_edit.is_line_folded(i):
							if _text.begins_with("#region"):
								_code_edit.set_line_background_color(i, _rcolor)

#endregion
################################################################################



##:: signal
################################################################################
#region sig_ On_connect

func _on_scene_saved(_filepath: String) -> void:
	refreshed_region_item()
	#print("on_scene_saved")

func _on_code_text_changed() -> void:
	if _is_aute_refresh():
		_timer_auto_refresh._set_timer_start_increase(2.4, 6, 1, _on_timer_auto_refresh)
		return
	if not _icon_warninng._is_number_check:
		if _compare_region_num():
			_icon_warninng._is_visible_icon_warning(true)
	#print("on_code_text_changed")

func _on_editor_sc_changed(_script: GDScript) -> void:
	refreshed_region_item()
	_is_editor_sc_change = true
	#print("on_script_changed")

func _on_item_selected(_idx: int) -> void:
	if not _is_editor_sc_change:
		refreshed_region_item()
	_is_editor_sc_change = false
	#prints("item_selected: ", _idx)

func _on_refresh_pressed() -> void:
	if _is_selected_item():
		if _compare_region_num():
			refreshed_region_item()
		else:
			_icon_warninng._is_visible_icon_warning(false)
	#print("on_refresh_pressed")

func _on_code_mouse_exited() -> void:
	if _is_aute_refresh():
		refreshed_region_item()
		#print("on_code_mouse_exited")

func _on_timeout_refresh() -> void:
	_timer_refresh._init_timeout_auto()
	_change_categ_line_color.call_deferred(_categ_num_arr, "categ")
	#_change_categ_line_color.call_deferred(_reg_num_arr, "reg")
	#print("arr: ", 	_store_region_dict)

func _on_caret_changed() -> void:
	if _is_selected_item():
		_timer_refresh._set_timer_start_auto(0.6, _caret_changed_border, 1, _on_timeout_refresh)
		#print("on_caret_changed: ")

func _on_timer_auto_refresh() -> void:
	_timer_auto_refresh._init_timeout_increase()
	refreshed_region_item()
	#_change_categ_line_color.call_deferred(_categ_num_arr, "categ")
	#_change_categ_line_color.call_deferred(_reg_num_arr, "reg")

#endregion
################################################################################
#region sig_ options

func refreshed_region_item() -> void:
	if is_instance_valid(_store_code_edit):
		_check_is_connect(_store_code_edit, "disconnect")
		_check_is_connect_button(_store_button, "disconnect")
	_categ_num_arr.clear()
	_reg_num_arr.clear()
	_init_removed()
	_region_create()
	_icon_warninng._is_visible_icon_warning.call_deferred(false)
	if _is_selected_item():
		_timer_refresh._set_timer_start_auto(2.8, 30, 1, _on_timeout_refresh)

func _is_aute_refresh() -> bool:
	if _auto_refresh_button.button_pressed:
		if _is_selected_item():
			if _compare_region_num():
				return true
	return false

func _is_selected_item() -> bool:
	var _selected_item: PackedInt32Array = _script_item_list.get_selected_items()
	if not _selected_item.is_empty():
		var _item_name: String = _script_item_list.get_item_text(_selected_item[0])
		var _selected_ext: String = _item_name.get_extension()
		if _selected_ext.contains("gd"):
			return true
	return false

#endregion
################################################################################
#region sig_is_connect

func _check_is_connect(_code_edit: CodeEdit, _type: String) -> void:
	if _code_edit != null:
		_store_code_edit = _code_edit

		match _type:
			"disconnect":
				if _code_edit.text_changed.is_connected(_on_code_text_changed):
					_code_edit.text_changed.disconnect(_on_code_text_changed)

				if _code_edit.caret_changed.is_connected(_on_caret_changed):
					_code_edit.caret_changed.disconnect(_on_caret_changed)

				if _code_edit.gui_input.is_connected(_plugin._on_list_hide_gui_input):
					_code_edit.gui_input.disconnect(_plugin._on_list_hide_gui_input)

				if _code_edit.gui_input.is_connected(_on_gui_input):
					_code_edit.gui_input.disconnect(_on_gui_input)

			"connect":
				if not _code_edit.text_changed.is_connected(_on_code_text_changed):
					__c._setup_signal.connect_text_changed(_code_edit, _on_code_text_changed)

				if not _code_edit.caret_changed.is_connected(_on_caret_changed):
					__c._setup_signal.connect_caret_changed(_code_edit, _on_caret_changed)

				if not _code_edit.gui_input.is_connected(_plugin._on_list_hide_gui_input):
					__c._setup_signal.connect_gui_input(_code_edit, _plugin._on_list_hide_gui_input)

				if not _code_edit.gui_input.is_connected(_on_gui_input):
					__c._setup_signal.connect_gui_input(_code_edit, _on_gui_input)
	#prints("ce: ", _type, _store_code_edit)

func _check_is_connect_button(_button: Button, _type: String) -> void:
	if _store_button != null:
		match _type:
			"disconnect":
				if _store_button.pressed.is_connected(_plugin._on_list_hide_pressed):
					_store_button.pressed.disconnect(_plugin._on_list_hide_pressed)

			"connect":
				if not _store_button.pressed.is_connected(_plugin._on_list_hide_pressed):
					__c._setup_signal.connect_button_pressed(_store_button, _plugin._on_list_hide_pressed)

#endregion
################################################################################
#region sig_ change_color

func _on_settings_changed() -> void:
	var _select: int = __c._setup_project._get_project_settings_used_select()
	var _color_background := __c._setup_project._get_project_settings_bg_color()

	if _select == 0:
		_set_default_color()
	else:
		_set_settings_changed_color(_color_background)

func _set_default_color() -> void:
	var _color := __c._setup_settings._color_dict["bg_color_dock"]
	_bg_menu_panel.self_modulate = _color
	_bg_panel_top.self_modulate = _color
	_bg_panel_bot.self_modulate = _color

func _set_settings_changed_color(_color: Color) -> void:
	_bg_menu_panel.self_modulate = _color
	_bg_panel_top.self_modulate = _color
	_bg_panel_bot.self_modulate = _color

func _init_bg_color(_color: Color) -> void:
	__c._setup_settings._set_add_theme_override_panel(_bg_menu_panel, _color)
	__c._setup_settings._set_add_theme_override_panel(_bg_panel_top, _color)
	__c._setup_settings._set_add_theme_override_panel(_bg_panel_bot, _color)

#endregion
################################################################################
#region sig_gui_input

func _on_gui_input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed and _event.button_index == MOUSE_BUTTON_WHEEL_DOWN or \
			_event.pressed and _event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_scroll_counter += 1
			if _scroll_counter % 2 == 0:
				_focus_handel()

	elif _event is InputEventKey:
		if _event.pressed and _event.keycode == KEY_UP or \
			_event.pressed and _event.keycode == KEY_DOWN:
			_scroll_counter += 1
			if _scroll_counter % 4 == 0:
				_focus_handel()

		if _event.pressed and _event.ctrl_pressed and _event.keycode == KEY_S:
			if _is_selected_item():
				_timer_refresh._set_timer_start_auto(1.2, 1, 1, _on_timeout_refresh)

	if _store_code_edit.is_dragging_cursor():
		_scroll_counter += 1
		if _scroll_counter % 3 == 0:
			_focus_handel()


func _focus_handel() -> void:
	if _store_code_edit != null:
		var _offset: int = 5
		var _offset_2: int = 8
		var _vis_first_line: int = _store_code_edit.get_first_visible_line()
		var _vis_last_line: int = _store_code_edit.get_last_full_visible_line()
		for i: int in _store_region_dict:

			if i > _vis_first_line - _offset and i < _vis_last_line + _offset:
				var _n: Node = _store_region_dict.get(i, null)
				if _n != null:
					_store_region_dict[i]._is_visible_focus_panel(true)
					_set_panel_color(i, 0.1)

					if i > _vis_first_line + _offset and i < _vis_last_line - _offset:
						_set_panel_color(i, 0.22)

					if i > _vis_first_line + _offset_2 and i < _vis_last_line - _offset_2:
						_set_panel_color(i, 0.3)

			else:
				var _n: Node = _store_region_dict.get(i, null)
				if _n != null:
					_store_region_dict[i]._is_visible_focus_panel(false)

	_scroll_counter = 0


func _set_panel_color(num: int, _alpha: float) -> void:
	var _color: Color = __c._setup_settings._color_dict["accent_color"]
	var _fnode: Node = _store_region_dict[num]._focus_panel
	__c._setup_settings._set_add_theme_override_panel(_fnode, _color, _alpha)

#endregion
################################################################################


##:: saveload
################################################################################
#region _saving_loading

func _data_saving(_data: Dictionary) -> void:
	var _temp_data := __c._setup_saveload._save_data_struct(_data)
	__c._setup_saveload._save_config_data(_temp_data)
	set_process_internal(true)
	_is_saving = true

func _data_loading() -> void:
	var _save_data: Dictionary = __c._setup_saveload._data
	for key in _save_data:
		if key == "FocusButton":
			var _toggled: bool = _save_data[key]
			_focus_button._set_loading_status(_toggled)
		elif key == "AutoRefreshButton":
			var _toggled: bool = _save_data[key]
			_auto_refresh_button._set_loading_status(_toggled)

func _data_saving_on_button_toggled(_toggled: bool, _button: Button) -> void:
	var _button_data: Dictionary = {
		"button_name": _button.name as String,
		"toggled": _toggled,
	}
	_data_saving(_button_data)

#endregion
################################################################################

