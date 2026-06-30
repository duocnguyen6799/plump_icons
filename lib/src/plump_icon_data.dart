import 'package:flutter/foundation.dart';

@immutable
class PlumpIconData {
  const PlumpIconData(
    this.assetName, {
    required this.style,
    required this.name,
  });

  /// Asset path inside the package.
  ///
  /// Example:
  /// assets/vec/line/home-1.svg.vec
  final String assetName;

  /// Icon style, for example: line, solid.
  final String style;

  /// Normalized icon name, for example: home-1, search-visual.
  final String name;

  @override
  String toString() {
    return 'PlumpIconData(name: $name, style: $style, assetName: $assetName)';
  }
}
