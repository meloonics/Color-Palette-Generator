extends HBoxContainer

func _ready():
	_on_HSlider_value_changed($HSlider.value)

func _on_HSlider_value_changed(value):
	$Label2.text = str(value)
