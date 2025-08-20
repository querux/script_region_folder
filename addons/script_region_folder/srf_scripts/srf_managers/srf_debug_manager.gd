@tool
class_name SRFDebugManager
extends Resource


var _debug_dict: Dictionary = {
	"fold": 1,
}


####################################################################################################
#region _debug_options

func _get_script_name(_node: Node) -> String:
	return _node.get_script().get_global_name()

func _get_code_edit() -> CodeEdit:
	var _script_editor := EditorInterface.get_script_editor()
	var _sc_current := _script_editor.get_current_editor()
	if _sc_current != null:
		var _code_edit := _sc_current.get_base_editor() as CodeEdit
		return _code_edit
	return null

func _get_keywords_line(_line: String) -> int:
	var _code_edit := _get_code_edit()
	var _line_count := _code_edit.get_line_count()
	for num in _line_count:
		var _line_text: String = _code_edit.get_line(num)

		if _line_text.contains(_line):
			return num + 1
	return -1

#endregion
####################################################################################################
#region _debug_process

func _debug_manager_fold_line(
	_debug_type: String, _self: Node, _log: String, _variant: Variant, _line: String
	) -> void:
	if _debug_dict["fold"] == 1:
		var _class_name: String = _get_script_name(_self)
		var _line_num: int = _get_keywords_line(_line)
		match _debug_type:
			"print":
				print("line::> %s [%s]: %s: %s" % [_line_num, _class_name, _log, _variant])
			"warning":
				push_warning("line::> %s [%s]: %s: %s" % [_line_num, _class_name, _log, _variant])
			"error":
				push_error("line::> %s [%s]: %s: %s" % [_line_num, _class_name, _log, _variant])

#endregion
####################################################################################################















