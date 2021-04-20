extends VBoxContainer

export(String) var name_tag := "A"
var rgb := false
var current_color : Color

func _ready():
	$Label.set_text(name_tag)

func set_color(c : Color):
	current_color = c
	$ColorRect.color = current_color
	_set_line_text()

func _on_Hex_toggled(button_pressed):
	rgb = button_pressed
	_set_line_text()

func _set_line_text():
	if rgb:
		
		$LineEdit.text = "Color(" + str(current_color.r8) + ", " + str(current_color.g8) + ", " + str(current_color.b8) + ")"
	else:
		$LineEdit.text = current_color.to_html(false)

func _on_Copy_pressed():
	
	JavaScript.eval("""
function copyToClipboard(text) { 
 var textarea = document.createElement('textarea');
  textarea.textContent = text;
  document.body.appendChild(textarea);

  var selection = document.getSelection();
  var range = document.createRange();
  range.selectNode(textarea);
  selection.removeAllRanges();
  selection.addRange(range);

  document.execCommand('copy');
  selection.removeAllRanges();

  document.body.removeChild(textarea);
}
	copyToClipboard(''""" + $LineEdit.text + """');
	
	""")
	#uncommment this if working on desktop
	OS.set_clipboard($LineEdit.text)
