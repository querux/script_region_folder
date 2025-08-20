@tool
class_name SRFClassManager
extends Node


""" config_file """
var _godot_conf: ConfigFile
var _gconf_path: String = "res://.godot/editor/editor_layout.cfg"

""" setup_class """
var _plugin: ScriptRegionFolderPlugin
var _debug_manager: SRFDebugManager

""" setup """
var _setup_lazy: SRFSetupLazy
var _setup_utility: SRFUtility
var _setup_signal: SRFSignalBus
var _setup_project: SRFSetupProject
var _setup_settings: SRFSetupSettings

""" saveload """
var _setup_saveload: SRFSaveLoadManager
var _saveload_utility: SRFSaveloadUtility

var _setup_arr: Array


################################################################################
#region _setup_lazy

func _get_setup_lazy(_setup_lazy: SRFSetupLazy) -> SRFSetupLazy:
	if _setup_lazy == null:
		_setup_lazy = SRFSetupLazy.new()
	return _setup_lazy

func _setup_init_lazy() -> void:
	_setup_lazy = _get_setup_lazy(_setup_lazy)
	_debug_manager = _setup_lazy._get_debug_maanger(_debug_manager)

	_setup_signal = _setup_lazy._get_setup_signal(_setup_signal)
	_setup_project = _setup_lazy._get_setup_project(_setup_project)
	_setup_settings = _setup_lazy._get_setup_settings(_setup_settings)
	_setup_utility = _setup_lazy._get_setup_utility(_setup_utility)

	_setup_saveload = _setup_lazy._get_setup_saveload(_setup_saveload)
	_saveload_utility = _setup_lazy._get_saveload_utility(_saveload_utility)

	_setup_saveload._saveload_config_file()
	_setup_init_project_settings()
	_godot_conf = _load_config()

	_setup_arr = [
		self, _setup_signal, _setup_project, _setup_settings, _setup_utility,
		_debug_manager, _godot_conf, _saveload_utility,
	]

func _setup_init_project_settings() -> void:
	_setup_saveload._init_create_file()

#endregion
################################################################################
#region create_conf_file

func _load_config() -> ConfigFile:
	var _conf = ConfigFile.new()
	var _error = _conf.load(_gconf_path)

	if _error != OK:
		push_error("[Region_Folder]: Not exists conf file::%s" % _gconf_path)
		return null

	return _conf

#endregion
################################################################################

