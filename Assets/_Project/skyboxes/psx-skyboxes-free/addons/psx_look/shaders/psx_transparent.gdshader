shader_type spatial;
render_mode vertex_lighting, specular_disabled, blend_mix, depth_draw_opaque, cull_disabled;

#define PSX_TRANSPARENT
#include "res://addons/psx_look/shaders/psx.gdshaderinc"
