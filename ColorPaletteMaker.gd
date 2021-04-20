extends VBoxContainer

onready var picker = $HBoxContainer/VBoxContainer/ColorPicker
onready var CASat = $HBoxContainer2/Sliders/HBoxContainer/HSlider
onready var BCSat = $HBoxContainer2/Sliders/HBoxContainer2/HSlider
onready var BAngle = $HBoxContainer2/Sliders/HBoxContainer3/HSlider
onready var CAngle = $HBoxContainer2/Sliders/HBoxContainer4/HSlider
onready var console = $HBoxContainer2/VBoxContainer3/TextEdit

onready var contrastB = $HBoxContainer2/Sliders/HBoxContainer5/CheckBox
onready var contrastC = $HBoxContainer2/Sliders/HBoxContainer5/CheckBox2
onready var exactS = $HBoxContainer2/Sliders/HBoxContainer5/CheckBox3
onready var indieB = $HBoxContainer2/Sliders/HBoxContainer5/CheckBox4

onready var cs1 = $HBoxContainer/ColorCell
onready var cs2 = $HBoxContainer/ColorCell2
onready var cs3 = $HBoxContainer/ColorCell3
onready var cs4 = $HBoxContainer/ColorCell4
onready var cs5 = $HBoxContainer/ColorCell5
onready var cs6 = $HBoxContainer/ColorCell6

onready var gamut = $HBoxContainer2/VBoxContainer/Gamut/Control

var A : Color
var cas : float
var bcs : float
var brad : float
var crad : float
var contrastedB : bool
var contrastedC : bool
var exactSecondary : bool
var palette = []

func _ready():
	$FileDialog.current_dir = "user://"
	cas = CASat.value
	bcs = BCSat.value
	brad = BAngle.value
	crad = CAngle.value
	contrastedB = contrastB.pressed
	contrastedC = contrastC.pressed
	exactSecondary = exactS.pressed
	picker.set_hsv_mode(true)
	_on_RandomizeColor_pressed()
	#_on_Randomize_pressed()

func make_palette():
	
	var C = getC()
	var B = getB(C)
	
	var ab = get_secondary(A, B)
	var bc = get_secondary(B, C)
	var ca = get_secondary(C, A)
	
	palette = [A, ab, B, bc, C, ca]
	
	set_cells()
	make_console_output(palette)
	gamut.set_colors(palette)

func getC() -> Color:
	
	var ch = fposmod(A.h + crad, 1.0)
	var cs = A.s * cas
	var cv = A.v
	
	if contrastedC:
		return Color.from_hsv(ch, cs, cv).contrasted()
	return Color.from_hsv(ch, cs, cv)

func getB(C : Color):
	var bh
	var bs
	var bv
	if indieB.pressed:
		bh = fposmod(A.h + brad, 1.0)
		bs = A.s * bcs
		bv = A.v# + (A.v - cv) / 2
	else:
		bh = lerp(A.h, C.h, brad) if C.h > A.h else lerp(A.h, 1.0 + C.h, brad)
		bs = C.s * bcs
		bv = A.v + (A.v - C.v) / 2
	
	if contrastedB:
		return Color.from_hsv(bh, bs, bv).contrasted()
	return Color.from_hsv(bh, bs, bv)

func get_secondary(c1: Color, c2 : Color):
	if exactSecondary:
		var c1r = Vector2(c1.s, 0).rotated(c1.h * TAU)
		var c2r = Vector2(c2.s, 0).rotated(c2.h * TAU)
		var secV = c1r + c1r.direction_to(c2r) * c1r.distance_to(c2r)/2
		
		var sec = Color.from_hsv(secV.angle() / TAU, secV.length(), lerp(c1.v, c2.v, 0.5))
		
		return sec
		
	else:
		return lerp(c1, c2, 0.5)

func set_cells():
	var cells = [cs1, cs2, cs3, cs4, cs5, cs6]
	for i in palette.size():
		cells[i].set_color(palette[i])

func make_console_output(p: Array):
	var s = "PoolColorArray ( \n\t[\n"
	for i in p:
		s += "\t\tColor(" + str(i) + ")"
		if i != p.back():
			s += ", \n"
	
	s += "\n\t]\n)"
	console.text = s

func _on_ColorPicker_color_changed(color):
	A = color
	#contrastB.set_pressed(A.v < 0.6 or A.s < 0.3)
	make_palette()


func _on_HSlider_value_changed(_value = null):
	cas = CASat.value
	bcs = BCSat.value
	brad = BAngle.value
	crad = CAngle.value
	make_palette()


func _on_CopyAll_pressed():
	
	
	#thx, nov
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
	copyToClipboard(''""" + console.text.strip_escapes() + """');
	
	""")
	
	#uncomment this if working on desktop
	OS.set_clipboard(console.text.strip_escapes())



func _on_CheckBox_toggled(button_pressed):
	contrastedB = button_pressed
	make_palette()


func _on_CheckBox2_toggled(button_pressed):
	contrastedC = button_pressed
	make_palette()

func _on_CheckBox3_toggled(button_pressed):
	exactSecondary = button_pressed
	make_palette()

func _on_Randomize_pressed():
	CASat.set_value(rand_range(0.3, 1.0))
	BCSat.set_value(rand_range(0.5, 1.0))
	BAngle.set_value(rand_range(0.1, 0.9))
	CAngle.set_value(rand_range(0.1, 0.9))
	contrastB.set_pressed(randi()%3 == 0)
	contrastC.set_pressed(randi()%3 == 0)
	indieB.set_pressed(randi()%3 == 0)
	
	make_palette()





func _on_RandomizeColor_pressed():
	var rcol 
	if randi()%3 == 0:
		rcol = Color.from_hsv(randf(), rand_range(0.5, 1.0), rand_range(0.5, 1.0))
	else:
		rcol = Constants.get_random_color()
	picker.color = rcol
	A = rcol
	contrastB.set_pressed(A.v < 0.6 or A.s < 0.3)
	make_palette()



func _on_FileDialog_file_selected(path):
	if path.ends_with(".png"):
		save_png(path)
	elif path.ends_with(".txt"):
		save_txt(path)
	else:
		printerr("Saving exception!")

func save_png(path):
	var img = Image.new()
	img.create(palette.size(), 1, false, Image.FORMAT_RGBAH)
	for i in palette.size():
		img.lock()
		img.set_pixel(i, 0, palette[i])
		img.unlock()
	
	img.save_png(path)

func save_txt(path):
	var file = File.new()
	var palette_as_text = "; Made with the Godot Color Palette Generator by meloonics.\n; https://meloonics.itch.io/godot-color-palette-generator\n"
	for i in palette:
		palette_as_text += "FF" + i.to_html(false).to_upper() + "\n"
	file.open(path, File.WRITE)
	assert(file.is_open())
	file.store_string(palette_as_text)
	file.close()


func _on_SavePNG_pressed():
	$FileDialog.set_filters(PoolStringArray(["*.png ; PNG Images"]))
	$FileDialog.popup_centered_ratio()


func _on_SaveTXT_pressed():
	$FileDialog.set_filters(PoolStringArray(["*.txt ; Paint.NET Palette File"]))
	$FileDialog.popup_centered_ratio()


func _on_CheckBox4_toggled(button_pressed):
	var labelhue = $HBoxContainer2/Sliders/HBoxContainer3/Label
	if button_pressed:
		labelhue.set_text("B Hue relative to A: ")
	else:
		labelhue.set_text("B Hue relative to A and C: ")
	
	var labelsat = $HBoxContainer2/Sliders/HBoxContainer2/Label
	if button_pressed:
		labelsat.set_text("B Saturation relative to A: ")
	else:
		labelsat.set_text("B Saturation relative to C: ")
	make_palette()
