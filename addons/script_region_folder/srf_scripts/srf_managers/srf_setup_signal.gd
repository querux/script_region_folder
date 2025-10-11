@tool
class_name SRFSignalBus
extends Node


##:: system
#region _signal connect

""" editor_plugin """
func connect_scene_saved(_plugin: EditorPlugin, _on_scene_saved: Callable) -> void:
	_plugin.scene_saved.connect(_on_scene_saved)

""" project_settings """
func connect_settings_changed(_ps: ProjectSettings, _on_settings_changed: Callable) -> void:
	_ps.settings_changed.connect(_on_settings_changed)

""" script_editor """
func connect_editor_sc_changed(_sc_editor: ScriptEditor, _on_editor_sc_changed: Callable) -> void:
	_sc_editor.editor_script_changed.connect(_on_editor_sc_changed)

""" focus_entered_exited """
func connect_focus_entered(_control: Control, _on_focus_entered: Callable) -> void:
	_control.focus_entered.connect(_on_focus_entered)

func connect_focus_exited(_control: Control, _on_focus_exited: Callable) -> void:
	_control.focus_exited.connect(_on_focus_exited)

""" mouse_entered_exited """
func connect_mouse_entered(_control: Control, _on_mouse_entered: Callable) -> void:
	_control.mouse_entered.connect(_on_mouse_entered)

func connect_mouse_exited(_control: Control, _on_mouse_exited: Callable) -> void:
	_control.mouse_exited.connect(_on_mouse_exited)


""" code_edit """
func connect_gui_input(_control: Control, _on_gui_input: Callable) -> void:
	_control.gui_input.connect(_on_gui_input)

func connect_caret_changed(_text_edit: TextEdit, _on_caret_changed: Callable) -> void:
	_text_edit.caret_changed.connect(_on_caret_changed)

""" resized """
func connect_resized(_control: Control, _on_resized: Callable) -> void:
	_control.resized.connect(_on_resized)

""" button """
func connect_button_pressed(_button: Button, _on_button_pressed: Callable) -> void:
	_button.pressed.connect(_on_button_pressed)

func connect_button_toggled(_button: Button, _on_button_toggled: Callable) -> void:
	_button.toggled.connect(_on_button_toggled)

""" item_list """
func connect_item_selected(_item_list: ItemList, _on_item_selected: Callable) -> void:
	_item_list.item_selected.connect(_on_item_selected)

func connect_text_changed(_code_edit: CodeEdit, _on_text_changed: Callable) -> void:
	_code_edit.text_changed.connect(_on_text_changed)

""" split_container """
func connect_drag_started(_split: SplitContainer, _on_drag_started: Callable) -> void:
	_split.drag_started.connect(_on_drag_started)

func connect_drag_ended(_split: SplitContainer, _on_drag_ended: Callable) -> void:
	_split.drag_ended.connect(_on_drag_ended)

#endregion





