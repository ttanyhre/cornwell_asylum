PSX Skyboxes Free
=================

6 PS1-style skies, taken from PSX Skyboxes (53 skies): https://heyheythere.itch.io/psx-skyboxes
A full moon, a sunset with clouds, grey fog, a green aurora, a gas giant over an alien sky and a
nebula. Each is a panorama and a cubemap, 32 colours, ordered-dithered like the PS1's textures, and
low-res on purpose: 1024 x 512 (cube faces of 256), and again at half that for the crunchier look.
Generated as a function of direction, so neither has a seam, and the panorama and cube of a sky are
the same sky.

What's in the zip
-----------------
panoramas/1024/  every sky by category, equirectangular, 1024 x 512
panoramas/512/   the same at 512 x 256
cubemaps/256/    each sky's six faces, <sky>_px, _nx, _py, _ny, _pz, _nz.png (+x, -x, +y,
                 -y, +z, -z, as OpenGL lays them out, y up), 256 x 256
cubemaps/128/    the same at 128 x 128
addons/          the Godot addon, psx_skyboxes/: this folder is a Godot 4.3+ project that opens
                 on its viewer (.gdignore keeps Godot out of the other folders)

Godot 4.3 and later
-------------------
Copy addons/psx_skyboxes/ into your project's addons/ folder. environments/ has an Environment
per sky: the sky, ambient light and reflections from it, and fog of its horizon's colour (that
leaves the sky alone). Put one on a WorldEnvironment and you're done. The skies alone are in
materials/: a PanoramaSkyMaterial on each panorama, unfiltered, and in materials/cube/ a
ShaderMaterial on each cubemap (psx_sky.gdshader: point filtered, with a rotation in degrees and
an energy). The environments use the cubemap ones, whose pixels stay square all the way up.
demo/viewer.tscn shows them over a plain with houses and poles on the horizon: left / right for
the sky, C for the cubemap or the panorama, G to hide the ground.
For the full PS1 look (vertex snap, affine textures, 240p, dither), our PSX Look shaders turn a
level's materials over in one line: https://heyheythere.itch.io/psx-look
With PSX Look in res://addons/psx_look/, the viewer shows through it (P toggles it).
PSX Skyboxes uses the same addon folder: it installs over this one.

Other engines and apps
----------------------
Use panoramas/ (an equirectangular sky, the middle column ahead) or cubemaps/ (six faces in
OpenGL's order and orientation, as three.js, Godot and most engines take them). Set the
filtering to nearest/point and turn mipmaps and compression off for the crisp PS1 pixels.

License: CC BY 4.0, see LICENSE.txt for the credit line. Made by heyheythere:
https://heyheythere.itch.io
