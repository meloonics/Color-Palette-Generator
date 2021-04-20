extends Control

var colors = []

func set_colors(p: Array):
	colors = p
	update()

func _draw():
	if colors != []:
		var points : PoolVector2Array = []
		var names = ["A", "ab", "B", "bc", "C", "ca"]
		var center = rect_size/2
		var max_dist = min(rect_size.x / 2, rect_size.y / 2)
		for i in colors.size():
			
			points.append(center + Vector2(max_dist * colors[i].s, 0).rotated(TAU * colors[i].h))
		
		for i in points.size():
			if i % 2 == 0:
				draw_circle(points[i], 4.0, Color.black)
				draw_string(get_font("font"), points[i] + 15 * center.direction_to(points[i]), names[i], Color.black)
			else:
				draw_circle(points[i], 2.0, Color.black)
			
		
		draw_line(points[0], points[2], Color.black)
		draw_line(points[2], points[4], Color.black)
		draw_line(points[4], points[0], Color.black)
		#print("BREEE")
