#!/usr/bin/env python3
"""
Pre-process LaTeX source for Pandoc HTML conversion.

Handles:
  - TikZ diagrams to SVG (via latex + dvisvgm)
  - Flattens \\input{} commands (Pandoc drops \\includegraphics in \\input files)
  - Replaces tikzpicture environments with \\includegraphics

Usage:
  preprocess-tex.py <subject-dir> <output-dir> <build-dir>
"""

import hashlib
import os
import re
import subprocess
import sys
import shutil


TIKZ_PREAMBLE = (
    r"\documentclass[tikz]{standalone}" + "\n"
    r"\usepackage{circuitikz}" + "\n"
    r"\usepackage[T1]{fontenc}" + "\n"
    r"\usepackage{lmodern}" + "\n"
    r"\usepackage{amsmath,amssymb}" + "\n"
    r"\usetikzlibrary{arrows.meta}" + "\n"
    r"\begin{document}" + "\n"
)


def sha256(content):
    return hashlib.sha256(content.encode("utf-8")).hexdigest()[:16]


build_dir = None  # set in main, used in closure


def resolve_inputs(content, subject_dir, base_dir, seen=None):
    if seen is None:
        seen = set()

    def repl(m):
        name = (m.group(1) or m.group(2)).strip()
        if not name:
            return m.group(0)
        tex_path = name + ".tex" if not name.endswith(".tex") else name
        full = os.path.normpath(os.path.join(subject_dir, base_dir, tex_path))
        if not os.path.isfile(full):
            return m.group(0)
        full_key = os.path.normpath(full)
        if full_key in seen:
            return ""
        seen.add(full_key)
        with open(full, "r", encoding="utf-8") as fh:
            inner = fh.read()
        inner_dir = os.path.dirname(tex_path)
        return resolve_inputs(inner, subject_dir, inner_dir, seen)

    content = re.sub(
        r'\\input\{([^}]+)\}',
        repl,
        content,
    )
    content = re.sub(
        r'\\include\{([^}]+)\}',
        repl,
        content,
    )
    return content


def extract_tikzpictures(content, output_dir):
    pattern = re.compile(
        r'\\begin\{(tikzpicture|circuitikz)\}(.*?)\\end\{\1\}',
        re.DOTALL,
    )

    def convert(match):
        full_block = match.group(0)
        h = sha256(full_block.strip())
        svg_name = f"diagram_{h}.svg"
        svg_path = os.path.join(output_dir, "resources", svg_name)
        build_svg = os.path.join(build_dir, "resources", svg_name)

        if os.path.isfile(svg_path):
            if not os.path.isfile(build_svg):
                os.makedirs(os.path.dirname(build_svg), exist_ok=True)
                shutil.copy2(svg_path, build_svg)
            return "\\includegraphics[width=\\textwidth]{resources/" + svg_name + "}"

        tmpdir = os.path.join(build_dir, ".tikz_build")
        os.makedirs(tmpdir, exist_ok=True)

        tex_content = TIKZ_PREAMBLE + full_block + "\n\\end{document}\n"
        tex_file = os.path.join(tmpdir, f"diagram_{h}.tex")
        with open(tex_file, "w", encoding="utf-8") as f:
            f.write(tex_content)

        try:
            subprocess.run(
                ["latex", f"diagram_{h}.tex"],
                cwd=tmpdir,
                capture_output=True,
                timeout=60,
                check=True,
            )
            subprocess.run(
                ["dvisvgm", "--no-fonts", "--scale=1", f"diagram_{h}.dvi"],
                cwd=tmpdir,
                capture_output=True,
                timeout=60,
                check=True,
            )
            svg_src = os.path.join(tmpdir, svg_name)
            if os.path.isfile(svg_src):
                os.makedirs(os.path.dirname(svg_path), exist_ok=True)
                shutil.copy2(svg_src, svg_path)
                os.makedirs(os.path.dirname(build_svg), exist_ok=True)
                shutil.copy2(svg_src, build_svg)
                print(f"  [Pre] {svg_name}", file=sys.stderr)
        except subprocess.CalledProcessError as e:
            err = (e.stderr or b"").decode()[:300]
            print(f"  [WARN] TikZ falhou para {svg_name}: {err}", file=sys.stderr)
            return match.group(0)
        except Exception as e:
            print(f"  [WARN] TikZ erro: {e}", file=sys.stderr)
            return match.group(0)
        finally:
            for ext in (".tex", ".dvi", ".aux", ".log"):
                p = os.path.join(tmpdir, f"diagram_{h}{ext}")
                if os.path.isfile(p):
                    os.remove(p)

        return "\\includegraphics[width=\\textwidth]{resources/" + svg_name + "}"

    return pattern.sub(convert, content)


def main():
    global build_dir

    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <subject-dir> <output-dir> <build-dir>",
              file=sys.stderr)
        sys.exit(1)

    subject_dir = os.path.abspath(sys.argv[1])
    output_dir = os.path.abspath(sys.argv[2])
    build_dir = os.path.abspath(sys.argv[3])

    os.makedirs(build_dir, exist_ok=True)
    os.makedirs(os.path.join(output_dir, "resources"), exist_ok=True)

    src_main = os.path.join(subject_dir, "main.tex")
    if not os.path.isfile(src_main):
        print(f"  [ERRO] main.tex nao encontrado em {subject_dir}",
              file=sys.stderr)
        sys.exit(1)

    # Copy resources for the build
    src_res = os.path.join(subject_dir, "resources")
    if os.path.isdir(src_res):
        dst_res = os.path.join(build_dir, "resources")
        shutil.copytree(src_res, dst_res, dirs_exist_ok=True)

    with open(src_main, "r", encoding="utf-8") as f:
        content = f.read()

    content = resolve_inputs(content, subject_dir, ".")
    content = extract_tikzpictures(content, output_dir)

    dst_main = os.path.join(build_dir, "main.tex")
    with open(dst_main, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"  [Pre] pre-processamento concluido", file=sys.stderr)


if __name__ == "__main__":
    main()
