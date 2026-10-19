@tool
extends EditorPlugin

var viewports     : Array[SubViewport]
var activeViewport: SubViewport
var cameras       : Array[Camera3D]
var activeCamera  : Camera3D
var Workspace3D: Node = EditorInterface.get_editor_main_screen().get_children()[1]
var enabled    : bool = true


func _enter_tree() -> void:
	for vp in range(4):
		viewports.append(EditorInterface.get_editor_viewport_3d(vp).get_viewport())
		cameras.append(viewports[vp].get_camera_3d())


func _input(event: InputEvent) -> void:
	# if pressing scroll wheel up/down
	if (enabled and
		event is InputEventMouseButton and
		event.button_index in [4, 5] and
		event.is_pressed() and
		not event.shift_pressed
		):

		# selects the first viewport that the mouse is inside of
		for vp in range(4):
			if viewports[vp].get_visible_rect().has_point(viewports[vp].get_mouse_position()):
				activeViewport = viewports[vp]
				activeCamera = cameras[vp]
				break

			# if mouse is not inside of any viewport, return
			if vp == 3:
				return

		# if the 3D workspace tab is active
		if Workspace3D.visible:
			# creates a point at 0,0,-1 or 0,0,1 (ahead or behind camera)
			var pointPos = Vector3(0, 0, (event.button_index - 4.5) * 2)
			# rotates around camera (which means rotating around 0,0,0 and adding the activeCamera position later)
			pointPos = pointPos.rotated(Vector3(1, 0, 0), activeCamera.rotation.x)
			pointPos = pointPos.rotated(Vector3(0, 1, 0), activeCamera.rotation.y)
			pointPos = pointPos.rotated(Vector3(0, 0, 1), activeCamera.rotation.z)
			pointPos = activeCamera.global_position + pointPos

			# moves toward the goal point
			activeCamera.position = activeCamera.global_position.move_toward(pointPos, 0.5)

			# makes godot not process the input for other things after this (i.e. disables the zoom from the scroll wheel)
			activeViewport.set_input_as_handled()

	# toggles the script with shift+P
	elif (event is InputEventKey and
		event.shift_pressed and
		event.as_text_keycode() == "Shift+P" and
		event.is_pressed()):
		enabled = !enabled
		print_debug(["Scroll to move is OFF", "Scroll to move is ON"][int(enabled)])
