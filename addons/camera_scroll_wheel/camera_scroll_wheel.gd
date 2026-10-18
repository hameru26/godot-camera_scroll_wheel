@tool
extends EditorPlugin

var viewports     : Array[SubViewport]
var activeViewport: SubViewport
var cameras       : Array[Camera3D]
var points        : Dictionary[Camera3D, Dictionary]
var activeCamera  : Camera3D
var Workspace3D: Node = EditorInterface.get_editor_main_screen().get_children()[1]
var enabled    : bool = true


func _enter_tree() -> void:
	for vp in range(4):
		viewports.append(EditorInterface.get_editor_viewport_3d(vp).get_viewport())
		cameras.append(viewports[vp].get_camera_3d())
		points[cameras[vp]] = Dictionary()

		# creates points in front and behind the camera
		# this is so it can easily move in the direction i want (toward the point) instead of having to calculate
		for pointZPos in [-1, 1]:
			var point = Node3D.new()
			# gives unique names so it can queue_free the points when disabling the plugin
			point.name = "hameruPoint" + str(pointZPos)
			point.position = Vector3(0, 0, pointZPos)
			cameras[vp].add_child(point)
			points[cameras[vp]][pointZPos] = point


func _exit_tree() -> void:
	# gets rid of the camera points
	for camera in cameras:
		for child in camera.get_children():
			if child.name.begins_with("hameruPoint"):
				child.queue_free()


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
			# turns mouse keys 4 and 5 into -1 and 1
			var goalPoint = points[activeCamera][int((event.button_index - 4.5) * 2)]
			# finally, moves toward the goal point
			activeCamera.position = activeCamera.global_position.move_toward(goalPoint.global_position, 0.5)
			# makes Godot not process the input after this (i.e. disables the zoom from the scroll wheel)
			activeViewport.set_input_as_handled()

	# toggles the script with shift+P
	elif (event is InputEventKey and
		event.shift_pressed and
		event.as_text_keycode() == "Shift+P" and
		event.is_pressed()):
		enabled = !enabled
		print_debug(["Scroll to move is OFF", "Scroll to move is ON"][int(enabled)])
