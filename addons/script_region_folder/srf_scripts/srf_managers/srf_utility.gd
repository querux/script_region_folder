@tool
class_name SRFUtility


################################################################################
#region _getter

func _get_sc_editor() -> ScriptEditor:
	return EditorInterface.get_script_editor()


func _get_base_ctrl() -> Control:
	return EditorInterface.get_base_control()

#endregion
################################################################################
#region _find_utility

func _find_node(_node: Node, _find_name: String) -> Node:
	if _node.is_class(_find_name):
		return _node
	for child in _node.get_children():
		var _found := _find_node(child, _find_name)
		if _found is Node:
			return _found
	return null


func _find_get_button(_node: Node, _find_class: String) -> Node:
	if _node.is_class(_find_class):
		return _node
	for child in _node.get_children():
		if child is PanelContainer:
			return _find_get_button(child, "HBoxContainer")
		elif child is HBoxContainer:
			for f_child in child.get_children():
				if f_child is Button:
					return f_child
	return null


func _find_container(_node: Node, _find_class: String) -> Node:
	if _node.is_class(_find_class):
		return _node
	for child in _node.get_children():
		var _found := _find_container(child, _find_class)
		if _found is Control:
			return _found
	return null


func _get_container(_node: Node, _find_class: String) -> Node:
	for child in _node.get_children():
		if child.is_class(_find_class):
			return child
	return null


func _find_hsplit_container(_node: Node) -> Node:
	if _node is HSplitContainer:
		return _node
	for child in _node.get_children():
		var _found := _find_hsplit_container(child)
		if _found is VBoxContainer:
			return _found
		if _found is HSplitContainer:
			return _found
	return null


func _find_item_list(_node: Node) -> Node:
	if _node is ItemList:
		return _node
	for child in _node.get_children():
		var _found := _find_item_list(child)
		if _found is VBoxContainer:
			return _found
		if _found is ItemList:
			return _found
	return null


func _find_get_sc_list_button(_node: Node) -> Button:
	for child in _node.get_children():
		if child is HBoxContainer:
			for item in child.get_children():
				if item is Button:
					return item
	return null

#endregion
################################################################################

