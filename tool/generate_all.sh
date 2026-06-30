#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SVG_RAW_DIR="$PACKAGE_ROOT/tool/svg_raw"
VEC_DIR="$PACKAGE_ROOT/assets/vec"
LINE_SVG_DIR="$SVG_RAW_DIR/line"
SOLID_SVG_DIR="$SVG_RAW_DIR/solid"
LINE_VEC_DIR="$VEC_DIR/line"
SOLID_VEC_DIR="$VEC_DIR/solid"

echo "Cleaning generated vector assets..."
rm -rf "$VEC_DIR"
mkdir -p "$LINE_VEC_DIR"
mkdir -p "$SOLID_VEC_DIR"

compile_dir() {
  local input_dir="$1"
  local output_dir="$2"

  if [ ! -d "$input_dir" ]; then
    echo "Missing input directory: $input_dir"
    exit 1
  fi

  find "$input_dir" -type f -name "*.svg" | sort | while read -r file; do
    relative="${file#$input_dir/}"
    basename="$(basename "$file" .svg)"
    output="$output_dir/${basename}.svg.vec"
    echo "Compiling $relative -> ${basename}.svg.vec"
    dart run vector_graphics_compiler \
      -i "$file" \
      -o "$output"
  done
}

cd "$PACKAGE_ROOT"

echo "Compiling Line SVGs..."
compile_dir "$LINE_SVG_DIR" "$LINE_VEC_DIR"

echo "Compiling Solid SVGs..."
compile_dir "$SOLID_SVG_DIR" "$SOLID_VEC_DIR"

echo "Generating Dart constants..."
dart run tool/generate_dart.dart

echo "Formatting Dart files..."
dart format lib tool example/lib

echo "Done."
