# Plump Icons

Unofficial Flutter icon package for Streamline Plump Free icons.

This package provides high-fidelity vector icon widgets generated from the original Streamline Plump SVG files.

## Features

- Line and Solid styles
- High-fidelity SVG/vector rendering
- Bottom navigation selected/unselected state support
- Future-friendly structure for Duo, Flat, or Gradient styles

## Installation

```yaml
dependencies:
  plump_icons: ^0.0.1
```

Run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:plump_icons/plump_icons.dart';

PlumpIcon(PlumpIcons.home1Line, size: 24, color: Colors.black);
PlumpIcon(PlumpIcons.home1Solid, size: 24, color: Colors.black);
```

## Bottom Navigation

```dart
BottomNavigationBarItem(
  icon: PlumpIcon(PlumpIcons.home1Line, size: 24),
  activeIcon: PlumpIcon(PlumpIcons.home1Solid, size: 24),
  label: 'Home',
)
```

## Coloring

For Line and Solid icons:

```dart
PlumpIcon(
  PlumpIcons.home1Line,
  size: 24,
  color: Colors.blue,
)
```

For future multi-color icons, avoid overriding color if you want to preserve the original colors.

## Notes

This package does not ship the original SVG source files on pub.dev. It includes compiled vector assets (`.svg.vec`) and generated Dart constants.

## License

This repository contains two separate licenses:

| Component | License | File |
|-----------|---------|------|
| Package code (Dart, tooling, docs) | MIT | [LICENSE](LICENSE) |
| Icon artwork (Streamline Plump Free) | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) | [NOTICE](NOTICE) |

The Flutter package you install from pub.dev is MIT-licensed. The bundled icon assets remain under CC BY 4.0 and require attribution to Streamline when reused.

This package is unofficial and is not affiliated with or endorsed by Streamline.
