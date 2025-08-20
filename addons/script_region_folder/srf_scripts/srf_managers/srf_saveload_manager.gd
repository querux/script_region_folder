@tool
class_name SRFSaveLoadManager
extends Resource


""" project_settings """
const ADDON_PATH: String = "addons/script_region_folder/"

const SETTINGS_CONFIG = "%s/data/region_folder_file" % ADDON_PATH
const CONFIG_FILE_DATA: String = "RegionFolderData"
var _root_path: String = "res://"
var _extension: String = ".txt"

var _settings := ProjectSettings

""" save_data """
var _data: Dictionary
var _save_path: String
var _curr_region_names: Array[String]

var _class_name: String
var _is_loading_data: bool = true


var _saveload_error: Dictionary = {
	"not_found": "Not found RegionFolder save data.",
	"load_file": "Failed loading RegionFolder save data. Error loading file: %d.",
	"load_invalid": "Failed loading RegionFolder save data. File contains invalid data.",
	"save_file": "Failed saving RegionFolder save data. Error writing file: %d."
}


################################################################################
#region _color_rich
#print_rich("[color=deep_sky_blue][b]Hello world![/b][/color] aaa")

func _rpre(_color_str: String) -> String:
	return "[color=%s][b]" %_color_str

func _rend() -> String:
	return "[/b][/color]"

#endregion
################################################################################
#region _debug_options

func _get_script_name() -> String:
	return get_script().get_global_name()

func _debug_get_keyword_lines(_sc: GDScript, _keyword: String) -> int:
	var _code: String = _sc.source_code
	var _lines: PackedStringArray = _code.split("\n")
	var _keyword_lines: int = 0

	for i in range(_lines.size()):
		if _keyword in _lines[i]:
			_keyword_lines = i + 1
	return _keyword_lines

func _debug_print(_debug_type: String, _line_num: String, _error: String) -> void:
	var _line: int = _debug_get_keyword_lines(get_script(), _line_num)
	match _debug_type:
		"print":
			print("line::%s > [%s] %s" % [_line, _get_script_name(), _error])
		"warning":
			push_warning("line::%s > [%s] %s" % [_line, _get_script_name(), _error])
		"error":
			push_error("line::%s > [%s] %s" % [_line, _get_script_name(), _error])

#endregion
################################################################################

##:: setup
################################################################################
#region _project_settings

func _saveload_config_file() -> void:
	if not _settings.has_setting(SETTINGS_CONFIG):
		_settings.set_setting(SETTINGS_CONFIG, CONFIG_FILE_DATA)
		save_data()
	else:
		_save_path = _settings.get_setting(SETTINGS_CONFIG)
		load_data()

	_settings.add_property_info({
		"name": SETTINGS_CONFIG,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_SAVE_FILE
	})

	_settings.save()

#endregion
################################################################################


##:: data
################################################################################
#region saveload_init_create

func _init_create_file() -> void:
	if not _is_exists_save_data():
		if not _settings.has_setting(SETTINGS_CONFIG):
			_settings.set_setting(SETTINGS_CONFIG, CONFIG_FILE_DATA)

		if _settings.get_setting(SETTINGS_CONFIG) == "":
			_settings.set_setting(SETTINGS_CONFIG, CONFIG_FILE_DATA)

		_save_path = _settings.get_setting(SETTINGS_CONFIG)

		var _file_path: String = "%s%s%s" % [_root_path, _save_path, _extension]

		var _file := FileAccess.open(_file_path, FileAccess.WRITE)
		if not _file:
			push_error(_saveload_error["save_file"] % FileAccess.get_open_error())
			return
		_file.store_string(var_to_str({}))

#endregion
################################################################################
#region _saveload_process

func load_data() -> void:
	_save_path = _get_saved_file_name()

	var _file_path: String = "%s%s%s" % [_root_path, _save_path, _extension]

	if not _is_exists_save_data():
		_debug_print("warning", "line_94", _saveload_error["not_found"])
	else:
		var _file := FileAccess.open(_file_path, FileAccess.READ)
		if not _file:
			_debug_print("error", "line_98", _saveload_error["load_file"] % FileAccess.get_open_error())
			return

		var loaded := str_to_var(_file.get_as_text())
		if not loaded is Dictionary:
			_debug_print("error", "line_104", _saveload_error["load_invalid"])
			return

		_data = loaded

func save_data() -> void:
	if not _settings.has_setting(SETTINGS_CONFIG):
		_settings.set_setting(SETTINGS_CONFIG, CONFIG_FILE_DATA)

	if _settings.get_setting(SETTINGS_CONFIG) == "":
		_settings.set_setting(SETTINGS_CONFIG, CONFIG_FILE_DATA)

	if not _save_path.is_empty():
		_save_path = _settings.get_setting(SETTINGS_CONFIG)

	_save_path = _get_saved_file_name()

	var _file_path: String = "%s%s%s" % [_root_path, _save_path, _extension]

	var _file := FileAccess.open(_file_path, FileAccess.WRITE)
	if not _file:
		push_error(_saveload_error["save_file"] % FileAccess.get_open_error())
		return
	_file.store_string(var_to_str(_data))

#endregion
################################################################################
#region _get_save_file_name

func _get_saved_file_name() -> String:
	var _temp_name: Variant
	if _save_path.is_empty():
		_temp_name = _settings.get_setting(SETTINGS_CONFIG) as String

		if _temp_name.contains("res://") or _temp_name.contains("."):
			var _temp: String = _temp_name.get_file().get_basename()
			return _temp
		return _temp_name

	else:
		if _save_path.contains("res://") or _save_path.contains("."):
			_temp_name = _save_path.get_file().get_basename()
			return _temp_name
		return _save_path
	return ""

#endregion
################################################################################


##:: saving
################################################################################
#region _saving dictionary

func _save_config_data(_save_data: Dictionary) -> void:
	_save_data.erase("")
	_data = _save_data
	save_data()

#endregion
################################################################################
#region _save_data struct

func _save_data_struct(_data_values: Dictionary) -> Dictionary:
	if _data_values.has("key_name"):
		_class_name = _data_values["key_name"]

	if not _data.has(_class_name):
		_data[_class_name] = {}

	if _data_values.has("reg_name"):
		_data[_class_name][_data_values["reg_name"]] = _data_values["reg_togg"]
		_curr_region_names.push_back(_data_values["reg_name"])

	if _data_values.has("button_name"):
		_data[_data_values["button_name"]] = _data_values["toggled"]

	return _data

#endregion
################################################################################
#region _delete_extra_keys

func _save_data_check_exists() -> void:
	if _data.get(_class_name):
		var _count_true: int = 0

		for key in _data[_class_name].keys():
			if not _curr_region_names.has(key):
				_data[_class_name].erase(key)

		for key in _data[_class_name].keys():
			if _data[_class_name][key] == true:
				_count_true += 1
			else:
				_data[_class_name].erase(key)
		if _count_true == 0:
			_data.erase(_class_name)
	_curr_region_names.clear()

	save_data()

#endregion
################################################################################


##:: utility
################################################################################
#region _is_loaded

func _get_is_loaded(_active: bool) -> bool:
	_is_loading_data = _active
	return _is_loading_data

#endregion
################################################################################
#region _is_exists

func _is_exists_save_data() -> bool:
	_save_path = _get_saved_file_name()
	var _file_path: String = "%s%s%s" % [_root_path, _save_path, _extension]
	if FileAccess.file_exists(_file_path):
		return true
	return false

#endregion
################################################################################



