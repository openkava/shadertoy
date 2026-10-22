# ShaderToy

An iOS app for learning fragment shaders. It draws each bundled GLSL sample on a full-screen triangle with Metal, and shows the original GLSL underneath.

The shaders are the 2013 OpenGL ES samples (`time`, `mouse`, and `resolution`). They are translated to Metal Shading Language ahead of time. The app no longer fetches shaders from glsl.heroku.com, which is no longer available.

This project is released under the [MIT License](LICENSE). Copyright (c) 2013-2026 openkava.

Several fragment shaders already in the tree carry comments crediting earlier shader-sandbox authors. Those notices stay in the GLSL sources.

## Requirements

- Xcode 15 or later
- iOS 16 or later, iPhone or iPad
- A Mac to compile. Metal shaders are compiled by Xcode's `metal` tool.

## Build

1. Open `shadertoy.xcodeproj`.
2. Select the `shadertoy` scheme.
3. For a device, pick your team under Signing & Capabilities. The bundle id is `com.openkava.shadertoy`. A simulator build can use Xcode's local signing.
4. Choose an iOS 16+ simulator or device and run.

The project file and shaders were checked with glslangValidator and SPIRV-Cross. They have not been compiled with Xcode or `metalc` from this environment, which has no Mac toolchain. Signing and an on-device run still need a Mac.

Previous and Next step through the samples. Drag on the image to update `mouse` (origin at the bottom left, in pixels). `apple` and `raytrace` render at point resolution because their ray marches are expensive.

The GLSL in the bottom panel is the file from `shadertoy/Shaders`. The renderer runs the matching `.metal` file, not the GLSL text.

## Regenerating the Metal shaders

The `.metal` fragment shaders are generated. From a machine with `glslangValidator` and `spirv-cross`:

```bash
python3 tools/glsl_to_msl.py
```

Then add any new `.metal` file to the shadertoy target's Compile Sources, and add a row in `ShaderCatalog.m`. The script only rewrites `shadertoy/Shaders/Metal/*.metal` for each `*.fsh`. It leaves `ShaderCommon.h` and `Fullscreen.metal` alone.

`tools/glsl_to_msl.py` is not part of the Xcode build.

## What you see

| Sample | File | Notes |
| --- | --- | --- |
| simple1, simple, Shader | plasma | The three bundled copies of the original live shader |
| julia | `julia.fsh` | Julia set |
| heart | `heart.fsh` | Animated heart |
| monjori | `monjori.fsh` | Monjori pattern |
| vision | `vision.fsh` | Grid |
| flower | `flower.fsh` | Kaleidoscope |
| ray_ball | `ray_ball.fsh` | Displaced sphere |
| test | `test.fsh` | Raymarched field |
| apple, raytrace | raymarched apples | Drawn at a lower resolution |

`Shader.vsh` and `simple1.vsh` remain in the tree as the old vertex shaders. The Metal path uses `fullscreen_vertex` in `Fullscreen.metal` instead.
