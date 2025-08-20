@tool
class_name SRFSetupSettings
extends Resource


var _section: String = "srf_plugin"
var _section_editor: String = "ScriptEditor"

var _categ_offset: int = 16



################################################################################
#region _sett_color

func _set_color_value(_color_path: String) -> Color:
	var _color: Color = EditorInterface.get_editor_settings().get_setting(_color_path)
	return _color

var _color_dict: Dictionary[String, Color] = {
	"accent_color" : _set_color_value("interface/theme/accent_color"),
	"text_color"   : _set_color_value("text_editor/theme/highlighting/text_color"),
	"class_name"   : _set_color_value("text_editor/theme/highlighting/user_type_color"),
	"line_name"    : _set_color_value("text_editor/theme/highlighting/safe_line_number_color"),
	"symbol_color" : _set_color_value("text_editor/theme/highlighting/symbol_color"),
	"base_type"    : _set_color_value("text_editor/theme/highlighting/base_type_color"),
	"var_func"     : _set_color_value("text_editor/theme/highlighting/keyword_color"),
	"func_difini"  : _set_color_value("text_editor/theme/highlighting/gdscript/function_definition_color"),
	"comment"      : _set_color_value("text_editor/theme/highlighting/doc_comment_color"),
	"reg_name"     : Color(0.68, 0.46, 0.77, 1.0),
	"icon_fold"    : Color(0.58, 0.43, 0.64),
	"icon_unfold"  : Color(0.32, 0.24, 0.36),
	"all_fold"     : Color(0.86, 0.50, 0.88),
	"all_unfold"   : Color(0.61, 0.32, 0.61),
	"btn_focus"    : Color(0.373, 1.0, 0.592),
	"btn_m_refresh": Color(1.0, 0.95, 0.229),
	"btn_a_refresh": Color(0.286, 0.612, 0.91),
	"warning_label": Color(1.0, 0.95, 0.229),
	"bg_color_dock": Color(0.114, 0.114, 0.117),
	"bg_color_node": Color(0.137, 0.137, 0.141),
	"transparent"  : Color(0,0,0,0),
}

#endregion
################################################################################
#region _sett_labels

var _label_dict: Dictionary = {
	"root_class": "Select script...",
	"root_func": "Select region...",
	"warning_label": "Press the refresh button.",
}

var _tooltip_dict: Dictionary = {
	"all_fold": "All fold / All unfold:\nTip: Opens or closes the region of the selected class.",
	"btn_focus": "Focus Button:\nTip: If true, selecting a region name focuses the editor on that line.",
	"btn_m_refresh": "Refresh Button:\nTip: Refreshes regions of the selected class.",
	"btn_a_refresh": "Auto Refresh Button:\nTip: Automatically updates the region list on code changes. (May be slightly slower.)",
}

#endregion
################################################################################
#region _sett_res_icon

var _icon_dict: Dictionary = {
	"icon_fold": load("res://addons/script_region_folder/srf_icons/godot_CodeRegionFoldedRightArrow.svg"),
	"icon_unfold": load("res://addons/script_region_folder/srf_icons/godot_CodeRegionFoldDownArrow.svg"),
	"triple_bar": load("res://addons/script_region_folder/srf_icons/godot_TripleBar.svg"),
}

#endregion
################################################################################
#region _sett_res_scenes

var SRF_CUSTOM_NODE_CHILD = load("res://addons/script_region_folder/srf_scenes/srf_custom_node_child.tscn")
var SRF_CUSTOM_NODE_FUNC  = load("res://addons/script_region_folder/srf_scenes/srf_custom_node_func.tscn")
var SRF_CUSTOM_ROOT_FUNC  = load("res://addons/script_region_folder/srf_scenes/srf_custom_root_func.tscn")
var SRF_CUSTOM_ROOT_CLASS = load("res://addons/script_region_folder/srf_scenes/srf_custom_root_class.tscn")

var _custom_node_dict: Dictionary = {
	"node_child": SRF_CUSTOM_NODE_CHILD,
	"node_func": SRF_CUSTOM_NODE_FUNC,
	"root_func": SRF_CUSTOM_ROOT_FUNC,
	"root_class": SRF_CUSTOM_ROOT_CLASS,
}

#endregion
################################################################################
#region _sett_theme_override

func _set_add_theme_override_font_size(_name: String, _node: Node, _font_size: int) -> void:
	_node.add_theme_font_size_override(_name, _font_size)

func _set_add_theme_override_font_outline(_node: Node, _color: Color) -> void:
	_node.add_theme_constant_override("outline_size", 1)
	_node.add_theme_color_override("font_outline_color", _color * 0.7)

func _set_add_theme_override_panel(_node: Node, _color: Color, _alpha: float = 1.0) -> void:
	var _stylebox: StyleBoxFlat = _node.get_theme_stylebox("panel")
	_stylebox.bg_color = _color
	_stylebox.bg_color.a = _alpha
	_stylebox.anti_aliasing = false
	_node.add_theme_stylebox_override("panel", _stylebox)

func _set_add_theme_override_thickness(_node: SplitContainer, _tsize: int, _area_offset: int) -> void:
	_node.add_theme_constant_override("minimum_grab_thickness", _tsize)
	_node.drag_area_offset = _area_offset

#endregion
################################################################################






