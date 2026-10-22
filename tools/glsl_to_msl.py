#!/usr/bin/env python3
"""Translate bundled GLSL ES fragment shaders into Metal Shading Language.

The Xcode target compiles the generated .metal files. It does not run this
script. Regenerating requires glslangValidator and spirv-cross:

    python3 tools/glsl_to_msl.py

Each Shaders/*.fsh is compiled as GLSL 450 (the ES 1.00 text is rewritten just
enough for glslang), turned into SPIR-V, then emitted as iOS MSL 2.1.
ShaderCommon.h and Fullscreen.metal are hand-written and left untouched.
"""

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHADER_DIR = ROOT / "shadertoy" / "Shaders"
METAL_DIR = SHADER_DIR / "Metal"

UNIFORM_BLOCK = """\
struct Uniforms
{
    float time;
    float2 mouse;
    float2 resolution;
};
"""

HEADER = """\
#version 450
layout(location = 0) out vec4 fragColor;
layout(std140, set = 0, binding = 0) uniform Uniforms {
    float time;
    vec2 mouse;
    vec2 resolution;
};
"""

MOD_TEMPLATE = re.compile(
    r"// Implementation of the GLSL mod\(\) function, which is slightly different than Metal fmod\(\)\n"
    r"template<typename Tx, typename Ty>\n"
    r"inline Tx mod\(Tx x, Ty y\)\n"
    r"\{\n"
    r"    return x - y \* floor\(x / y\);\n"
    r"\}\n\n"
)


def preprocess(src: str) -> str:
    src = src.replace("\r\n", "\n").replace("\r", "\n")
    src = re.sub(r"\b(lowp|mediump|highp)\b", "", src)
    kept = []
    for line in src.splitlines():
        stripped = line.strip()
        if stripped.startswith("precision ") or stripped.startswith("varying "):
            continue
        if stripped.startswith("uniform "):
            continue
        kept.append(line)
    body = "\n".join(kept)
    body = re.sub(r"\bgl_FragColor\b", "fragColor", body)
    return HEADER + body + "\n"


def translate(stem: str, glsl: str) -> str:
    entry = "shader_" + stem
    with tempfile.TemporaryDirectory(prefix="glsl2msl-") as tmp:
        frag = Path(tmp) / (stem + ".frag")
        spv = Path(tmp) / (stem + ".spv")
        frag.write_text(preprocess(glsl), encoding="utf-8")
        compile_cmd = [
            "glslangValidator",
            "-V",
            "-S",
            "frag",
            "-o",
            str(spv),
            str(frag),
        ]
        compiled = subprocess.run(compile_cmd, capture_output=True, text=True)
        if compiled.returncode != 0:
            raise SystemExit(
                f"{stem}.fsh failed glslangValidator:\n{compiled.stdout}\n{compiled.stderr}"
            )
        cross_cmd = [
            "spirv-cross",
            "--msl",
            "--msl-ios",
            "--msl-version",
            "20100",
            "--force-zero-initialized-variables",
            "--rename-entry-point",
            "main",
            entry,
            "frag",
            str(spv),
        ]
        crossed = subprocess.run(cross_cmd, capture_output=True, text=True)
        if crossed.returncode != 0:
            raise SystemExit(f"{stem}.fsh failed spirv-cross:\n{crossed.stderr}")
        metal = crossed.stdout
    if UNIFORM_BLOCK not in metal:
        raise SystemExit(
            f"{stem}.metal lost the shared uniform layout. Refusing to emit a "
            "shader the app's ShaderUniforms struct would not match."
        )
    if "fragCoordMetal" in metal:
        raise SystemExit(f"{stem}.metal already uses the reserved name fragCoordMetal")
    metal = metal.replace("fast::", "")
    metal = MOD_TEMPLATE.sub(
        "// GLSL mod(), kept file-local so it does not collide across .metal files.\n"
        "template<typename Tx, typename Ty>\n"
        "static inline Tx mod(Tx x, Ty y)\n"
        "{\n"
        "    return x - y * floor(x / y);\n"
        "}\n\n",
        metal,
        count=1,
    )
    metal = metal.replace(UNIFORM_BLOCK, "")
    metal = metal.replace("Uniforms", "ShaderUniforms")
    include = '#include "ShaderCommon.h"\n'
    needle = "#include <simd/simd.h>\n"
    if needle not in metal:
        raise SystemExit(f"{stem}.metal has no simd include to anchor ShaderCommon.h")
    metal = metal.replace(needle, needle + "\n" + include, 1)
    metal = metal.replace(
        "float4 gl_FragCoord [[position]]",
        "float4 fragCoordMetal [[position]]",
        1,
    )
    match = re.search(r"constant ShaderUniforms& (\w+) \[\[buffer\(0\)\]\]", metal)
    if not match:
        raise SystemExit(f"{stem}.metal has no ShaderUniforms buffer(0)")
    uniform = match.group(1)
    out_match = re.search(r"(shader_\w+_out out = \{\};)", metal)
    if not out_match:
        raise SystemExit(f"{stem}.metal has no fragment output local")
    injection = (
        out_match.group(1)
        + "\n"
        + "    // [[position]] is top-left. GLSL gl_FragCoord is bottom-left.\n"
        + "    float4 gl_FragCoord = fragCoordMetal;\n"
        + f"    gl_FragCoord.y = {uniform}.resolution.y - fragCoordMetal.y;"
    )
    metal = metal.replace(out_match.group(1), injection, 1)
    banner = (
        "// Generated from Shaders/{stem}.fsh by tools/glsl_to_msl.py.\n"
        "// Regenerate with that script. glslangValidator compiles the GLSL;\n"
        "// spirv-cross emits MSL. Xcode compiles this file with metalc.\n"
        "// Entry point: {entry}\n\n"
    ).format(stem=stem, entry=entry)
    return banner + metal


def main() -> int:
    sources = sorted(SHADER_DIR.glob("*.fsh"))
    if not sources:
        raise SystemExit(f"No fragment shaders in {SHADER_DIR}")
    METAL_DIR.mkdir(parents=True, exist_ok=True)
    written = []
    for path in sources:
        metal = translate(path.stem, path.read_text(encoding="utf-8", errors="replace"))
        dest = METAL_DIR / (path.stem + ".metal")
        dest.write_text(metal, encoding="utf-8")
        written.append(dest.name)
        if f"shader_{path.stem}(" not in metal:
            raise SystemExit(f"Missing entry point in {dest.name}")
    print("wrote", len(written), "shaders:")
    for name in written:
        print(" ", name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
