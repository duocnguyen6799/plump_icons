import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

import 'plump_icon_data.dart';

class PlumpIcon extends StatelessWidget {
  const PlumpIcon(
    this.icon, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
    this.colorFilter,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  });

  final PlumpIconData icon;

  /// Width and height fallback.
  ///
  /// If [width] or [height] are provided, they override [size].
  final double? size;
  final double? width;
  final double? height;

  /// Convenience color API for monochrome icons.
  ///
  /// For Line/Solid icons, this is usually safe.
  /// For future multi-color styles such as Duo/Flat/Gradient,
  /// prefer leaving this null to preserve original colors.
  final Color? color;

  /// Advanced color filter override.
  ///
  /// If provided, this takes priority over [color].
  final ColorFilter? colorFilter;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final bool matchTextDirection;
  final String? semanticsLabel;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final effectiveColorFilter = colorFilter ??
        (color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn));

    return SvgPicture(
      AssetBytesLoader(
        icon.assetName,
        packageName: 'plump_icons',
      ),
      width: width ?? size,
      height: height ?? size,
      fit: fit,
      alignment: alignment,
      matchTextDirection: matchTextDirection,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: effectiveColorFilter,
    );
  }
}
