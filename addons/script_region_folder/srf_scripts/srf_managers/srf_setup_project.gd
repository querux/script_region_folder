@tool
class_name SRFSetupProject
extends Resource


const ADDON_PATH: String = "addons/script_region_folder/"

const SETTINGS_INIT_POS: String = "%s/container/set_position" % ADDON_PATH
const SETTINGS_DOCK_SIZE: String = "%s/container/dock_size" % ADDON_PATH
const SETTINGS_DOCK_BOT_SIZE: String = "%s/container/dock_bot_size" % ADDON_PATH
const SETTINGS_SC_LIST_SIZE: String = "%s/container/script_list_size" % ADDON_PATH
const SETTINGS_FONT_SIZE: String = "%s/font/font_size" % ADDON_PATH
const SETTINGS_FONT_BRIGHTNESS: String = "%s/font/font_brightness" % ADDON_PATH

const SETTINGS_USED_SELECT: String = "%s/color/used_select_color" % ADDON_PATH
const SETTINGS_CATEGORY_COLOR: String = "%s/color/custom_category_color" % ADDON_PATH
const SETTINGS_BG_COLOR: String = "%s/color/custom_bg_color" % ADDON_PATH
const SETTINGS_TEXT_COLOR: String = "%s/color/custom_text_color" % ADDON_PATH
const SETTINGS_LINE_PANEL: String = "%s/color/custom_line_panel_color" % ADDON_PATH
const SETTINGS_REG_NUMBER: String = "%s/color/custom_region_number_color" % ADDON_PATH
const SETTINGS_REG_ICON_COLOR: String = "%s/color/custom_region_icon_color" % ADDON_PATH

var _settings = ProjectSettings


var _font_size: int = 12


##:: process
################################################################################
#region _ps_ funcs

func _project_settings_save() -> void:
	_settings.save()

func _project_settings_add_parameter() -> void:
	_project_settings_dock_position()
	_project_settings_dock_size()
	_project_settings_dock_bot_size()
	_project_settings_sc_list_size()
	_project_settings_font_size()
	_project_settings_font_brightness()
	_project_settings_used_select()
	_project_settings_categ_color()
	_project_settings_bg_color()
	_project_settings_text_color()
	_project_settings_line_panel_color()
	_project_settings_region_num_color()
	_project_settings_region_icon_color()

#endregion
################################################################################

##:: container
################################################################################
#region _ps_dock_position

func _set_dock_position(_set_pos: int) -> void:
	if _settings.has_setting(SETTINGS_INIT_POS):
		_settings.set_setting(SETTINGS_INIT_POS, _set_pos)

func _project_settings_dock_position() -> int:
	if not _settings.has_setting(SETTINGS_INIT_POS):
		_settings.set_setting(SETTINGS_INIT_POS, _p_pos[0])

	_settings.add_property_info({
		"name": SETTINGS_INIT_POS,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": SET_POSITIONS
	})

	return _settings.get_setting(SETTINGS_INIT_POS) as int

#endregion
################################################################################
#region _ps_dock_size

func _set_project_settings_dock_size(_size_x: float) -> void:
	if _settings.has_setting(SETTINGS_DOCK_SIZE):
		_settings.set_setting(SETTINGS_DOCK_SIZE, _size_x)

func _get_project_settings_dock_size() -> float:
	if _settings.has_setting(SETTINGS_DOCK_SIZE):
		return _settings.get_setting(SETTINGS_DOCK_SIZE) as float
	return 200

func _project_settings_dock_size() -> float:
	if not _settings.has_setting(SETTINGS_DOCK_SIZE):
		_settings.set_setting(SETTINGS_DOCK_SIZE, 200)

	_settings.add_property_info({
		"name": SETTINGS_DOCK_SIZE,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "100,1000,1.0"
	})

	return _settings.get_setting(SETTINGS_DOCK_SIZE) as float

#endregion
################################################################################
#region _ps_dock_bot_size

func _set_project_settings_dock_bot_size(_size_y: float) -> void:
	if _settings.has_setting(SETTINGS_DOCK_BOT_SIZE):
		_settings.set_setting(SETTINGS_DOCK_BOT_SIZE, _size_y)

func _get_project_settings_dock_bot_size() -> float:
	if _settings.has_setting(SETTINGS_DOCK_BOT_SIZE):
		return _settings.get_setting(SETTINGS_DOCK_BOT_SIZE) as float
	return 850.0

func _project_settings_dock_bot_size() -> float:
	if not _settings.has_setting(SETTINGS_DOCK_BOT_SIZE):
		_settings.set_setting(SETTINGS_DOCK_BOT_SIZE, 850.0)

	_settings.add_property_info({
		"name": SETTINGS_DOCK_BOT_SIZE,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "100,3000,1.0"
	})

	return _settings.get_setting(SETTINGS_DOCK_BOT_SIZE) as float

#endregion
################################################################################
#region _ps_script_list_size

func _set_project_settings_sc_list_size(_size_x: float) -> void:
	if _settings.has_setting(SETTINGS_SC_LIST_SIZE):
		_settings.set_setting(SETTINGS_SC_LIST_SIZE, _size_x)

func _get_project_settings_sc_list_size() -> float:
	if _settings.has_setting(SETTINGS_SC_LIST_SIZE):
		return _settings.get_setting(SETTINGS_SC_LIST_SIZE) as float
	return 100.0

func _project_settings_sc_list_size() -> float:
	if not _settings.has_setting(SETTINGS_SC_LIST_SIZE):
		_settings.set_setting(SETTINGS_SC_LIST_SIZE, 100.0)

	_settings.add_property_info({
		"name": SETTINGS_SC_LIST_SIZE,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "100,1000,1.0"
	})

	return _settings.get_setting(SETTINGS_SC_LIST_SIZE) as float

#endregion
################################################################################

##:: font
################################################################################
#region _ps_font_size

func _get_project_settings_font_size() -> int:
	if _settings.has_setting(SETTINGS_FONT_SIZE):
		return _settings.get_setting(SETTINGS_FONT_SIZE) as int
	return 12

func _project_settings_font_size() -> int:
	if not _settings.has_setting(SETTINGS_FONT_SIZE):
		_settings.set_setting(SETTINGS_FONT_SIZE, _font_size)

	_settings.add_property_info({
		"name": SETTINGS_FONT_SIZE,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_NONE,
	})

	return _settings.get_setting(SETTINGS_FONT_SIZE) as int

#endregion
################################################################################
#region _ps_font_brightness

func _get_project_settings_font_brightness() -> float:
	if _settings.has_setting(SETTINGS_FONT_BRIGHTNESS):
		return _settings.get_setting(SETTINGS_FONT_BRIGHTNESS) as float
	return 1.0

func _project_settings_font_brightness() -> float:
	if not _settings.has_setting(SETTINGS_FONT_BRIGHTNESS):
		_settings.set_setting(SETTINGS_FONT_BRIGHTNESS, 1.0)

	_settings.add_property_info({
		"name": SETTINGS_FONT_BRIGHTNESS,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.8,2.0,0.01",
	})

	return _settings.get_setting(SETTINGS_FONT_BRIGHTNESS) as float

#endregion
################################################################################

##:: color
################################################################################
#region _ps_used_select

func _get_project_settings_used_select() -> int:
	if _settings.has_setting(SETTINGS_USED_SELECT):
		return _settings.get_setting(SETTINGS_USED_SELECT) as int
	return 0

func _project_settings_used_select() -> int:
	if not _settings.has_setting(SETTINGS_USED_SELECT):
		_settings.set_setting(SETTINGS_USED_SELECT, " DEFAULT_COLOR")

	_settings.add_property_info({
		"name": SETTINGS_USED_SELECT,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": SET_USED
	})

	return _settings.get_setting(SETTINGS_USED_SELECT) as int

#endregion
################################################################################
#region _ps_categ_color

func _get_project_settings_categ_color() -> Color:
	if _settings.has_setting(SETTINGS_CATEGORY_COLOR):
		return _settings.get_setting(SETTINGS_CATEGORY_COLOR) as Color
	return Color(0.67, 0.79, 1.0)

func _project_settings_categ_color() -> Color:
	if not _settings.has_setting(SETTINGS_CATEGORY_COLOR):
		_settings.set_setting(SETTINGS_CATEGORY_COLOR, Color(0.67, 0.79, 1.0))

	_settings.add_property_info({
		"name": SETTINGS_CATEGORY_COLOR,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	})

	return _settings.get_setting(SETTINGS_CATEGORY_COLOR) as Color

#endregion
################################################################################
#region _ps_bg_color

func _get_project_settings_bg_color() -> Color:
	if _settings.has_setting(SETTINGS_BG_COLOR):
		return _settings.get_setting(SETTINGS_BG_COLOR) as Color
	return Color(0.114, 0.114, 0.117)

func _project_settings_bg_color() -> Color:
	if not _settings.has_setting(SETTINGS_BG_COLOR):
		_settings.set_setting(SETTINGS_BG_COLOR, Color(0.114, 0.114, 0.117))

	_settings.add_property_info({
		"name": SETTINGS_BG_COLOR,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	})

	return _settings.get_setting(SETTINGS_BG_COLOR) as Color

#endregion
################################################################################
#region _ps_text_color

func _get_project_settings_text_color() -> Color:
	if _settings.has_setting(SETTINGS_TEXT_COLOR):
		return _settings.get_setting(SETTINGS_TEXT_COLOR) as Color
	return Color(0.68, 0.46, 0.77, 1.0)

func _project_settings_text_color() -> Color:
	if not _settings.has_setting(SETTINGS_TEXT_COLOR):
		_settings.set_setting(SETTINGS_TEXT_COLOR, Color(0.68, 0.46, 0.77, 1.0))

	_settings.add_property_info({
		"name": SETTINGS_TEXT_COLOR,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	})

	return _settings.get_setting(SETTINGS_TEXT_COLOR) as Color

#endregion
################################################################################
#region _ps_line_panel_color

func _get_project_settings_line_panel_color() -> Color:
	if _settings.has_setting(SETTINGS_LINE_PANEL):
		return _settings.get_setting(SETTINGS_LINE_PANEL) as Color
	return Color(0.4, 0.9, 1.0, 1.0)

func _project_settings_line_panel_color() -> Color:
	if not _settings.has_setting(SETTINGS_LINE_PANEL):
		_settings.set_setting(SETTINGS_LINE_PANEL, Color(0.4, 0.9, 1.0, 1.0))

	_settings.add_property_info({
		"name": SETTINGS_LINE_PANEL,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	})

	return _settings.get_setting(SETTINGS_LINE_PANEL) as Color

#endregion
################################################################################
#region _ps_region_num_color

func _get_project_settings_region_num_color() -> Color:
	if _settings.has_setting(SETTINGS_REG_NUMBER):
		return _settings.get_setting(SETTINGS_REG_NUMBER) as Color
	return Color(0.8, 0.9569, 0.8, 0.749)

func _project_settings_region_num_color() -> Color:
	if not _settings.has_setting(SETTINGS_REG_NUMBER):
		_settings.set_setting(SETTINGS_REG_NUMBER, Color(0.8, 0.9569, 0.8, 0.749))

	_settings.add_property_info({
		"name": SETTINGS_REG_NUMBER,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	})

	return _settings.get_setting(SETTINGS_REG_NUMBER) as Color

#endregion
################################################################################
#region _ps_region_icon_color

func _get_project_settings_region_icon_color() -> Color:
	if _settings.has_setting(SETTINGS_REG_ICON_COLOR):
		return _settings.get_setting(SETTINGS_REG_ICON_COLOR) as Color
	return Color.WHITE

func _project_settings_region_icon_color() -> Color:
	if not _settings.has_setting(SETTINGS_REG_ICON_COLOR):
		_settings.set_setting(SETTINGS_REG_ICON_COLOR, Color.WHITE)

	_settings.add_property_info({
		"name": SETTINGS_REG_ICON_COLOR,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	})

	return _settings.get_setting(SETTINGS_REG_ICON_COLOR) as Color

#endregion
################################################################################

##:: variables
################################################################################
#region _plugin_position_list

var _p_pos: Dictionary = {
	0 : " LEFT_UL",
	1 : " LEFT_BL",
	2 : " LEFT_UR",
	3 : " LEFT_BR",
	4 : " RIGHT_UL",
	5 : " RIGHT_BL",
	6 : " RIGHT_UR",
	7 : " RIGHT_BR",
	8 : " CODE_LL",
	9 : " CODE_LR",
	10: " CODE_RL",
	11: " CODE_RR",
}

var SET_POSITIONS: String = "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s" % [
	_p_pos[0],
	_p_pos[1],
	_p_pos[2],
	_p_pos[3],
	_p_pos[4],
	_p_pos[5],
	_p_pos[6],
	_p_pos[7],
	_p_pos[8],
	_p_pos[9],
	_p_pos[10],
	_p_pos[11],
	]

#endregion
################################################################################
#region _plugin_used_select

var _u_sel: Dictionary = {
	0: " default_color",
	1: " custom_color",
}

var SET_USED: String = "%s,%s" % [
	_u_sel[0],
	_u_sel[1],
	]

#endregion
################################################################################




