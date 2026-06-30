# Contributing

## Source of Truth

Raw SVG files live in:

```txt
tool/svg_raw/<style>/
```

Generated runtime vector assets live in:

```txt
assets/vec/<style>/
```

Generated Dart constants live in:

```txt
lib/src/plump_icons_data.dart
example/lib/generated_icon_list.dart
```

Do not edit generated files manually.

## Add or Update Icons

1. Add or edit SVG files in `tool/svg_raw/<style>/`.
2. Use kebab-case file names, for example `calendar-star.svg`.
3. Run:

```bash
./tool/generate_all.sh
```

4. Run:

```bash
dart format .
flutter analyze
flutter test
```

5. Commit both the raw SVG changes and generated files.

## License Rule

- Package code contributions are licensed under MIT (see `LICENSE`).
- Only add icons that are part of Streamline Plump Free (CC BY 4.0).
- Do not submit Pro icons or icons from paid icon sets.
