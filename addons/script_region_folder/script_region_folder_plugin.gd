@tool
class_name ScriptRegionFolderPlugin
extends EditorPlugin


var REGION_FOLDER_DOCK = load("res://addons/script_region_folder/srf_scenes/region_folder_dock.tscn")

var _dock_main: ScriptRegionFolderDock
var _dock_name: String = "RegionFolder"

## other_plugin
var _sc_multi_plus: MarginContainer

""" class """
var __c: SRFClassManager

var _timer_distruct: SRFTimerUtility
var _timer_hiding: SRFTimerUtility

""" nodes """
var _tab_container_parent: VBoxContainer
var _sc_editor_child_vbox: VBoxContainer

var _script_item_list: ItemList
var _sc_list_vsplit: VSplitContainer
var _sc_screen_hsplit: HSplitContainer

var _editor_scene_tabs: Node
var _editor_distruct_button: Button

""" store """
var _store_sc_split_offset: int
var _sc_list_index: int
var _dock_pos: int

var _time: float = 0.0

var _is_resized: bool = false
var _is_initial_load: bool = true
var _is_once_call: bool = false


##:: setup
################################################################################
#region _setup_lazy

func _get_class_all(_setup_class: SRFClassManager) -> SRFClassManager:
	if _setup_class == null:
		_setup_class = SRFClassManager.new()
	return _setup_class

func _set_init_classes() -> void:
	_timer_distruct = SRFTimerUtility.new(self)
	_timer_hiding = SRFTimerUtility.new(self)

	__c = _get_class_all(__c)
	__c._plugin = self
	__c._setup_init_lazy()
	__c._setup_arr.push_back(self)
	__c._saveload_utility._setup_class(__c._setup_arr)
	_store_sc_split_offset = __c._saveload_utility._get_editor_split_offset(__c._godot_conf)
	_get_editor_containers()
	_set_project_settings_parameters()

#endregion
################################################################################


##:: enter
################################################################################
#region _tree_enter_exit

func _enter_tree() -> void:
	_set_init_classes()

	if __c._godot_conf == null:
		push_error("Please restart addon Region Folder.")
		return
	_exist_plugin_handle()

	_add_dock_main()
	call_deferred("_move_plugin_menu")

func _exit_tree() -> void:
	if is_instance_valid(_dock_main):
		if _dock_pos < 8:
			remove_control_from_docks(_dock_main)

		match _dock_pos:
			8: ## LL
				_tab_container_parent.reparent(_sc_screen_hsplit)

			9: ## LR
				_sc_screen_hsplit.move_child(_sc_list_vsplit, 0)
				_tab_container_parent.reparent(_sc_screen_hsplit)

			10, 11: ## RL, RR
				_sc_list_vsplit.reparent(_sc_screen_hsplit)
				_sc_list_vsplit.get_parent().move_child(_sc_list_vsplit, 0)

		if _sc_multi_plus != null:
			_sc_multi_plus._is_plugin_actived = false

		_exited_position()
		_dock_main.queue_free()

func _process(_delta: float) -> void:
	_time += _delta

	if not _is_once_call and _time > 0.8:
		_is_once_call = true
		_loading_values()

	if _time > 3.0:
		set_process(false)
		_is_initial_load = false

		if _sc_multi_plus != null:
			_sc_multi_plus._is_plugin_actived = false

#endregion
################################################################################
#region _add_remove_dock_main

func _add_dock_main() -> void:
	var _scene = REGION_FOLDER_DOCK as PackedScene
	if _scene:
		_dock_main = _scene.instantiate()
		_setup_dock_main()

		if _dock_pos < 8:
			add_control_to_dock(__c._setup_project._project_settings_dock_position(), _dock_main)
		elif _dock_pos >= 8:
			_add_control_code_edit()
			_set_signal_resized.call_deferred()
	else:
		push_error("[levels_meaker_plugin]: PackedScene failed to load")

func _set_signal_resized() -> void:
	__c._setup_signal.connect_drag_started(_sc_screen_hsplit, _on_drag_started)
	__c._setup_signal.connect_drag_ended(_dock_main._vsplit, _on_drag_ended_dock_vsplit)
	__c._setup_signal.connect_drag_ended(_dock_main, _on_drag_ended)
	__c._setup_signal.connect_drag_ended(_sc_screen_hsplit, _on_drag_ended_sc_list)
	__c._setup_signal.connect_button_toggled(_editor_distruct_button, _on_distruction_button)

#endregion
################################################################################
#region _add_utility

func _setup_dock_main() -> void:
	_dock_main.set_name(_dock_name)
	_dock_main._setup_class(__c._setup_arr)

func _move_plugin_menu() -> void:
	__c._setup_project._set_dock_position(_dock_pos)
	__c._setup_project._project_settings_save()

func _set_project_settings_parameters() -> void:
	_dock_pos = __c._setup_project._project_settings_dock_position()
	__c._setup_project._project_settings_add_parameter()

#endregion
################################################################################

##:: getter
################################################################################
#region _get_node_parts

func _get_editor_containers() -> void:
	var _script_editor := __c._setup_utility._get_sc_editor()
	_sc_screen_hsplit = __c._setup_utility._find_container(_script_editor, &"HSplitContainer") # @12348
	_script_item_list = __c._setup_utility._find_item_list(_sc_screen_hsplit) # 12355
	_sc_list_vsplit = __c._setup_utility._get_container(_sc_screen_hsplit, &"VSplitContainer") # 12350

	_tab_container_parent = __c._setup_utility._get_container(_sc_screen_hsplit, &"VBoxContainer") # 12373
	_sc_editor_child_vbox = _sc_screen_hsplit.get_parent()
	_sc_list_index = _sc_list_vsplit.get_index()

	_get_distruction_button()
	__c._setup_arr.push_back(_script_item_list)
	__c._setup_settings._set_add_theme_override_thickness(_sc_screen_hsplit, 8, 2)


func _get_distruction_button() -> void:
	var _base_control := __c._setup_utility._get_base_ctrl()
	_editor_scene_tabs = __c._setup_utility._find_node(_base_control, &"EditorSceneTabs")
	_editor_distruct_button = __c._setup_utility._find_get_button(_editor_scene_tabs, &"Button")

#endregion
################################################################################


##:: movable
################################################################################
#region movable_handle

func _add_control_code_edit() -> void:
	match _dock_pos:
		8: ## LL
			_movable_node_ab()
		9: ## LR
			_movable_node_ab(1)
		10: ## RL
			_movable_node_cd(0)
		11: ## RR
			_movable_node_cd(-1)

	_change_split_container_offset()

func _change_split_container_offset() -> void:
	await get_tree().process_frame
	_movable_split_size()

#endregion
################################################################################
#region movable_reparent

func _movable_node_ab(_index: int = 0) -> void:
	_sc_screen_hsplit.add_child(_dock_main)
	_tab_container_parent.reparent(_dock_main)

	if _index != 0:
		_sc_list_vsplit.get_parent().move_child(_sc_list_vsplit, -1)

func _movable_node_cd(_index: int) -> void:
	_sc_screen_hsplit.add_child(_dock_main)
	_sc_list_vsplit.reparent(_dock_main)
	_sc_list_vsplit.get_parent().move_child(_sc_list_vsplit, _index)

func _movable_split_size() -> void:
	var _movable_size: float
	var _offset: float = 4
	var _dock_size_x: float = __c._setup_project._get_project_settings_dock_size()

	match _dock_pos:
		8:  ## sc_list_L, region_folder_L
			## Code_LL
			_dock_main.split_offset = _dock_size_x

		9:  ## region_folder_L, sc_list_R
			## Code_LR
			_movable_size = _sc_editor_child_vbox.size.x - _store_sc_split_offset - _offset
			_sc_screen_hsplit.split_offset = _movable_size
			_dock_main.split_offset = _dock_size_x

		10, 11:	## sc_list_R, region_folder_R = 10_RL
				## region_folder_R, sc_list_R = 11_RR
			_movable_size = _sc_editor_child_vbox.size.x - _store_sc_split_offset - _dock_size_x
			_sc_screen_hsplit.split_offset = _movable_size
			_dock_main.split_offset = _dock_size_x

#endregion
################################################################################


##:: signal
################################################################################
#region sig_plugin

func _enable_plugin() -> void:
	_exist_plugin_handle()
	set_process(true)
	#print("enabled_plugin")

func _disable_plugin() -> void:
	_exist_plugin_handle()
	#print("disabled")


func _get_window_layout(_conf: ConfigFile) -> void:
	if _is_resized:
		return
	_timer_distruct._set_timer_start_auto(0.1, 1, 1, _on_timeout_window_layout)
	#print("get_window_lauout")

	if _is_initial_load:
		return
	__c._saveload_utility._conf_saved_get_window_layout(_conf)

func _get_sc_multi_plus_plugin() -> MarginContainer:
	if EditorInterface.is_plugin_enabled("script_multi_plus"):
		for child in _tab_container_parent.get_children():
			var _sc := child.get_script()
			var _sc_gname: StringName = _sc.get_global_name()
			if _sc != null:
				if _sc_gname == &"ScriptMultiPlusDock":
					return child
	return null

func _exist_plugin_handle() -> void:
	_sc_multi_plus = _get_sc_multi_plus_plugin()
	if _sc_multi_plus != null:
		_sc_multi_plus._is_plugin_actived = true

#endregion
################################################################################
#region sig_drag_resized

func _on_drag_started() -> void:
	_is_resized = true


func _on_drag_ended_dock_vsplit() -> void:
	_saved_select("dock_vsplit_offset")


func _on_drag_ended() -> void:
	_saved_select("dock_size_split_offset")

	match _dock_pos:
		10:
			_gconf_saved_data_value("editor", "script_split_offset", _dock_main.split_offset)
			_saved_select("dock_size_x")
			_saved_select("sc_size_xe")
		11:
			_saved_select("sc_list_size_x")


func _on_drag_ended_sc_list() -> void:
	match _dock_pos:
		8, 9:
			_saved_select("sc_list_size_x")
		10:
			_gconf_saved_data_value("srf", "sc_split_offset", _sc_screen_hsplit.split_offset)
			_gconf_saved_data_value("srf", "sc_split_offset_RR", _dock_main.size.x)
			_saved_select("dock_size_x")
			_saved_select("sc_size_xe")

		11:
			_gconf_saved_data_value("srf", "sc_split_offset_RR", _dock_main.size.x)
			_saved_select("sc_list_size_x")
	_is_resized = false


func _on_distruction_button(_toggle: bool) -> void:
	_timer_distruct._set_timer_start_auto(0.1, 1, 1, _on_timeout_distruct.bind(_toggle))


func _on_timeout_distruct(_toggle: bool) -> void:
	_timer_distruct._init_timeout_auto()
	if _toggle:
		_changeable_resized()
	else:
		_sc_list_vsplit.size.x = __c._setup_project._get_project_settings_sc_list_size()

## from_SRF_Dock
func _on_list_hide_pressed() -> void:
	_hide_button_pressed()

## from_SRF_Dock
func _on_list_hide_gui_input(_event: InputEvent) -> void:
	if _event is InputEventKey:
		if (_event.pressed and _event.ctrl_pressed and not _event.shift_pressed and
			_event.keycode == KEY_BACKSLASH
			):
			_hide_button_pressed.call_deferred()

#endregion
################################################################################
#region sig_utility

func _changeable_resized() -> void:
	match _dock_pos:
		8, 9:
			var _offset: int = 4
			var _sc_list_size_x: float = __c._setup_project._get_project_settings_sc_list_size()
			var _distractions: float = _sc_editor_child_vbox.size.x - _sc_list_size_x

			_sc_screen_hsplit.split_offset = _distractions - _offset

		10, 11:
			await get_tree().process_frame
			_changeable_RR()


func _changeable_RR() -> void:
	var _offset: int = 3

	_dock_main.size.x = \
	__c._saveload_utility._get_conf_data_value("srf", "sc_split_offset_RR")

	var _calc: int = _sc_screen_hsplit.size.x - _dock_main.size.x - _offset
	_sc_screen_hsplit.split_offset = _calc


func _hide_button_pressed() -> void:
	match _dock_pos:
		10:
			_type_RL_RR(3)
		11:
			_type_RL_RR(0)


func _type_RL_RR(_offset: int) -> void:
	var _size_x: float = __c._setup_project._get_project_settings_sc_list_size()
	if not _sc_list_vsplit.is_visible():
		_sc_screen_hsplit.split_offset += _size_x + _offset
	else:
		_sc_screen_hsplit.split_offset -= _size_x + _offset

	_timer_hiding._set_timer_start_auto(0.1, 1, 1, _on_timeout_hiding)


func _on_timeout_hiding() -> void:
	_timer_hiding._init_timeout_auto()
	_gconf_saved_data_value("srf", "sc_split_offset_RR", _dock_main.size.x)
	_gconf_saved_data_value("srf", "sc_split_offset", _sc_screen_hsplit.split_offset)

#endregion
################################################################################
#region sig_select_save

func _saved_select(_select: String) -> void:
	match _select:
		"sc_size_xe":
			_sc_list_vsplit.size.x = \
			__c._saveload_utility._get_conf_data_value("editor", "script_split_offset")
			_saved_select("sc_list_size_x")

		"sc_list_size_x":
			_gconf_saved_data_value("srf", "sc_list_size_x", _sc_list_vsplit.size.x)
			__c._setup_project._set_project_settings_sc_list_size(_sc_list_vsplit.size.x)
			_store_sc_split_offset = _sc_list_vsplit.size.x

		"dock_size_x":
			_gconf_saved_data_value("srf", "dock_size_x", _dock_main._vbox.size.x)
			__c._setup_project._set_project_settings_dock_size(_dock_main._vbox.size.x)

		"dock_size_split_offset":
			_gconf_saved_data_value("srf", "dock_size_x", _dock_main.split_offset)
			__c._setup_project._set_project_settings_dock_size(_dock_main.split_offset)

		"dock_vsplit_offset":
			_gconf_saved_data_value("srf", "dock_vsplit_offset", _dock_main._vsplit.split_offset)
			__c._setup_project._set_project_settings_dock_bot_size(_dock_main._vsplit.split_offset)

		"sc_split_offset": ## boot
			if __c._godot_conf == null:
				return
			if not __c._godot_conf.has_section_key("srf_plugin", "sc_split_offset"):
				_gconf_saved_data_value("srf", "sc_split_offset", _sc_screen_hsplit.split_offset)

#endregion
################################################################################
#region sig_window_layout

func _on_timeout_window_layout() -> void:
	_timer_distruct._init_timeout_auto()

	if __c._godot_conf == null:
		return

	match _dock_pos:
		8: ## LL
			_sc_list_vsplit.size.x = __c._setup_project._get_project_settings_sc_list_size()
			_store_sc_split_offset = _sc_list_vsplit.size.x

		9, 10, 11: ## LR, RL, RR
			_changeable_resized()

	_gconf_saved_data_value("editor", "script_split_offset", _sc_list_vsplit.size.x)

#endregion
################################################################################


##:: data
################################################################################
#region _saveload_handle

func _loading_values() -> void:
	_saved_select("sc_split_offset")
	if _dock_main != null:
		_dock_main.split_offset = __c._setup_project._get_project_settings_dock_size()
		_dock_main._vsplit.split_offset = __c._setup_project._get_project_settings_dock_bot_size()

	match _dock_pos:
		9: ## LR
			if __c._saveload_utility._has_conf_data("srf_plugin", "sc_list_size_x"):
				_sc_list_vsplit.size.x = \
				__c._saveload_utility._get_conf_data_value("editor", "script_split_offset")

		10: ## RL
			if __c._saveload_utility._has_conf_data("srf_plugin", "sc_split_offset"):
				_dock_main.split_offset = \
				__c._saveload_utility._get_conf_data_value("editor", "script_split_offset")
				_sc_screen_hsplit.split_offset = \
				__c._saveload_utility._get_conf_data_value("srf", "sc_split_offset")
				var _dock_sx: float = __c._saveload_utility._get_conf_data_value("srf", "dock_size_x")
				var _calc: int = _dock_main.split_offset + _dock_sx + 3

				_gconf_saved_data_value("srf", "sc_split_offset_RR", _calc)
				_changeable_RR()

		11: ## RR
			var _calc: int
			if __c._saveload_utility._has_conf_data("srf_plugin", "dock_size_x"):
				_dock_main.split_offset = \
				__c._saveload_utility._get_conf_data_value("srf", "dock_size_x")
				_sc_list_vsplit.size.x = \
				__c._saveload_utility._get_conf_data_value("editor", "script_split_offset")

			if not _sc_list_vsplit.is_visible():
				_calc = _dock_main.split_offset + 3
			else:
				_calc = _dock_main.split_offset + _sc_list_vsplit.size.x + 3

			_gconf_saved_data_value("srf", "sc_split_offset_RR", _calc)
			_changeable_RR()
	await get_tree().process_frame
	_saved_select("sc_list_size_x")


func _exited_position() -> void:
	if __c._godot_conf:
		_sc_screen_hsplit.split_offset = __c._godot_conf.get_value("srf_plugin", "sc_list_size_x")
		_sc_list_vsplit.size.x = __c._setup_project._get_project_settings_sc_list_size()
		_gconf_saved_data_value("editor", "script_split_offset", _store_sc_split_offset)


func _gconf_saved_data_value(_section: String, _key_name: String, _value) -> void:
	if __c._godot_conf == null:
		return
	__c._saveload_utility._conf_save_data_value(_section, _key_name, _value)

#endregion
################################################################################

