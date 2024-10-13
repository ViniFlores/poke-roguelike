extends Button

func _ready():
	grab_focus()
	visibility_changed.connect(func(): if visible: grab_focus())
