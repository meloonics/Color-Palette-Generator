shader_type canvas_item;

const float PI = 3.14159265359;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
    float sine = sin(rotation);
    float cosine = cos(rotation);

    uv -= pivot;
    uv.x = uv.x * cosine - uv.y * sine;
    uv.y = uv.x * sine + uv.y * cosine;
    uv += pivot;

    return uv;
}

void fragment(){
	if(distance(UV, vec2(0.5, 0.5)) > 0.5){
		COLOR.a = 0.0;
	}
	float fac = 1.9;
	vec2 center = vec2(0.5);
	vec2 red =   rotateUV(vec2(1.0, 0.5), center, 0);
	vec2 green = rotateUV(vec2(1.0, 0.5), center, (PI / 3.0) * 4.0);
	vec2 blue =  rotateUV(vec2(1.0, 0.5), center, (PI / 3.0) * 2.0);
	
	COLOR.r = 1.0 - distance(center, UV) * fac * distance(UV, red);
	COLOR.g = 1.0 - distance(center, UV) * fac * distance(UV, green);
	COLOR.b = 1.0 - distance(center, UV) * fac * distance(UV, blue);
}