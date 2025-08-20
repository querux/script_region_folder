@tool
class_name SRFSetupLazy
extends Resource


################################################################################
#region _lazy_init

func _get_setup_lazy(_setup_lazy: SRFSetupLazy) -> SRFSetupLazy:
	if _setup_lazy == null:
		_setup_lazy = SRFSetupLazy.new()
	return _setup_lazy

func _get_setup_project(_setup_project: SRFSetupProject) -> SRFSetupProject:
	if _setup_project == null:
		_setup_project = SRFSetupProject.new()
	return _setup_project

func _get_setup_settings(_setup_settings: SRFSetupSettings) -> SRFSetupSettings:
	if _setup_settings == null:
		_setup_settings = SRFSetupSettings.new()
	return _setup_settings

func _get_setup_signal(_setup_signal: SRFSignalBus) -> SRFSignalBus:
	if _setup_signal == null:
		_setup_signal = SRFSignalBus.new()
	return _setup_signal

func _get_setup_utility(_setup_utility: SRFUtility) -> SRFUtility:
	if _setup_utility == null:
		_setup_utility = SRFUtility.new()
	return _setup_utility


func _get_debug_maanger(_debug_manager: SRFDebugManager) -> SRFDebugManager:
	if _debug_manager == null:
		_debug_manager = SRFDebugManager.new()
	return _debug_manager

func _get_setup_saveload(_setup_saveload: SRFSaveLoadManager) -> SRFSaveLoadManager:
	if _setup_saveload == null:
		_setup_saveload = SRFSaveLoadManager.new()
	return _setup_saveload

func _get_saveload_utility(_saveload_utility: SRFSaveloadUtility) -> SRFSaveloadUtility:
	if _saveload_utility == null:
		_saveload_utility = SRFSaveloadUtility.new()
	return _saveload_utility

#endregion
################################################################################









