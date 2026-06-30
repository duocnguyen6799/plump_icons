import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:plump_icons/plump_icons.dart';

void main() {
  test('home1 line and solid metadata', () {
    expect(PlumpIcons.home1Line, isA<PlumpIconData>());
    expect(PlumpIcons.home1Line.style, 'line');
    expect(PlumpIcons.home1Line.name, 'home-1');
    expect(
      PlumpIcons.home1Line.assetName,
      'assets/vec/line/home-1.svg.vec',
    );

    expect(PlumpIcons.home1Solid.style, 'solid');
    expect(PlumpIcons.home1Solid.name, 'home-1');
    expect(
      PlumpIcons.home1Solid.assetName,
      'assets/vec/solid/home-1.svg.vec',
    );
  });

  test('coordinateAxis3d override', () {
    expect(PlumpIcons.coordinateAxis3dLine.name, '3d-coordinate-axis');
    expect(PlumpIcons.coordinateAxis3dSolid.name, '3d-coordinate-axis');
  });

  test('compiled vector assets exist for sample icons', () {
    for (final icon in [
      PlumpIcons.home1Line,
      PlumpIcons.home1Solid,
      PlumpIcons.coordinateAxis3dLine,
    ]) {
      expect(
        File(icon.assetName).existsSync(),
        isTrue,
        reason: 'Missing asset: ${icon.assetName}',
      );
    }
  });
}
