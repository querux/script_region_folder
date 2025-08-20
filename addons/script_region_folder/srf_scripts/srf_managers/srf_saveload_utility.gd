@tool
class_name SRFSaveloadUtility
extends Node


""" class """
var __c: SRFClassManager
var _plugin: ScriptRegionFolderPlugin

var _godot_conf: ConfigFile


##:: setup
################################################################################
#region _init_setup

func _setup_class(_class_arr: Array) -> void:
	for item in _class_arr:
		if item is SRFClassManager:
			__c = item
		elif item is ScriptRegionFolderPlugin:
			_plugin = item
		elif item is ConfigFile:
			_godot_conf = item


func _get_editor_split_offset(_conf: ConfigFile) -> int:
	var _esection: String = __c._setup_settings._section_editor
	if _conf.has_section(_esection):
		for key in _conf.get_section_keys(_esection):
			var _value: Variant = _conf.get_value(_esection, key)
			if key == "script_split_offset":
				return _value
	return 0

#endregion
################################################################################
#region _conf_setget_save_data

func _has_conf_data(_section: String, _key: String) -> bool:
	if _godot_conf.has_section(_section):
		if _godot_conf.has_section_key(_section, _key):
			return true
	return false


func _get_conf_data_value(_section: String, _key_name: String) -> Variant:
	_section = _get_section(_section)
	if _godot_conf.has_section_key(_section, _key_name):
		return _godot_conf.get_value(_section, _key_name)
	return null


func _conf_save_data_value(_section: String, _key_name: String, _value) -> void:
	_section = _get_section(_section)
	_godot_conf.set_value(_section, _key_name, _value)
	_godot_conf.save(__c._gconf_path)


func _get_section(_section: String) -> String:
	match _section:
		"editor":
			_section = __c._setup_settings._section_editor
		"srf":
			_section = __c._setup_settings._section
	return _section

#endregion
################################################################################
#region saved_editor_layout.cfg

func _conf_saved_get_window_layout(_conf: ConfigFile) -> void:
	_godot_conf.clear()

	for sec in _conf.get_sections():
		for key in _conf.get_section_keys(sec):
			var _value: Variant = _conf.get_value(sec, key)

			_godot_conf.set_value(sec, key, _value)
			#prints("value: ", sec, key, _value)
	_godot_conf.save(__c._gconf_path)

#endregion
################################################################################

