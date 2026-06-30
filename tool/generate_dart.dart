import 'dart:io';

const nameOverrides = <String, String>{
  '3d-coordinate-axis': 'coordinateAxis3d',
};

const _dartKeywords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'type',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};

void main() {
  final packageRoot = _findProjectRoot();
  final rawRoot = Directory('${packageRoot.path}/tool/svg_raw');
  final styles = <String, String>{
    'line': 'Line',
    'solid': 'Solid',
  };

  final entries = <_IconEntry>[];

  for (final style in styles.entries) {
    final styleName = style.key;
    final suffix = style.value;
    final dir = Directory('${rawRoot.path}/$styleName');

    if (!dir.existsSync()) {
      stderr.writeln('Missing directory: ${dir.path}');
      exitCode = 1;
      return;
    }

    final filesByBasename = <String, File>{};
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.svg')) {
        continue;
      }

      final basename = _basenameWithoutExtension(entity.path);
      if (filesByBasename.containsKey(basename)) {
        stderr.writeln(
          'Duplicate SVG basename "$basename":\n'
          '  ${filesByBasename[basename]!.path}\n'
          '  ${entity.path}',
        );
        exitCode = 1;
        return;
      }
      filesByBasename[basename] = entity;
    }

    final sortedBasenames = filesByBasename.keys.toList()..sort();

    for (final basename in sortedBasenames) {
      final dartBaseName = _toDartBaseName(basename);
      final dartName = '$dartBaseName$suffix';
      final assetName = 'assets/vec/$styleName/$basename.svg.vec';

      entries.add(
        _IconEntry(
          dartName: dartName,
          style: styleName,
          name: basename,
          assetName: assetName,
          displayName: dartBaseName,
        ),
      );
    }
  }

  entries.sort((a, b) => a.dartName.compareTo(b.dartName));

  final duplicateNames = <String>{};
  final seenNames = <String>{};
  for (final entry in entries) {
    if (!seenNames.add(entry.dartName)) {
      duplicateNames.add(entry.dartName);
    }
  }

  if (duplicateNames.isNotEmpty) {
    stderr.writeln('Duplicate generated Dart names:');
    for (final name in duplicateNames) {
      stderr.writeln('- $name');
    }
    exitCode = 1;
    return;
  }

  _writePlumpIconsData(packageRoot, entries);
  _writePreviewList(packageRoot, entries);

  stdout.writeln('Generated ${entries.length} icon constants.');
}

Directory _findProjectRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}/pubspec.yaml').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      return Directory.current;
    }
    dir = parent;
  }
  return dir;
}

String _basenameWithoutExtension(String path) {
  final name = path.split(Platform.pathSeparator).last;
  return name.replaceAll(RegExp(r'\.svg$'), '');
}

String _toDartBaseName(String basename) {
  if (nameOverrides.containsKey(basename)) {
    return nameOverrides[basename]!;
  }

  var result = _toLowerCamelCase(basename);
  if (RegExp(r'^[0-9]').hasMatch(result)) {
    result = 'icon$result';
  }
  if (_dartKeywords.contains(result)) {
    result = '${result}Icon';
  }
  return result;
}

String _toLowerCamelCase(String input) {
  final parts = input
      .split(RegExp(r'[-_\s/]+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return input;
  }

  final first = _safeDartIdentifierPart(parts.first.toLowerCase());
  final rest = parts.skip(1).map((part) {
    final lower = part.toLowerCase();
    if (lower.isEmpty) {
      return '';
    }
    return lower[0].toUpperCase() + lower.substring(1);
  }).join();

  return '$first$rest';
}

String _safeDartIdentifierPart(String input) {
  final sanitized = input.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
  if (sanitized.isEmpty) {
    return 'icon';
  }
  return sanitized;
}

void _writePlumpIconsData(Directory packageRoot, List<_IconEntry> entries) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('//')
    ..writeln('// To regenerate, run: ./tool/generate_all.sh')
    ..writeln()
    ..writeln("import 'plump_icon_data.dart';")
    ..writeln()
    ..writeln('abstract final class PlumpIcons {');

  for (final entry in entries) {
    buffer
      ..writeln('  static const ${entry.dartName} = PlumpIconData(')
      ..writeln("    '${entry.assetName}',")
      ..writeln("    style: '${entry.style}',")
      ..writeln("    name: '${entry.name}',")
      ..writeln('  );')
      ..writeln();
  }

  buffer.writeln('}');

  final output = File('${packageRoot.path}/lib/src/plump_icons_data.dart');
  output.createSync(recursive: true);
  output.writeAsStringSync(buffer.toString());
}

void _writePreviewList(Directory packageRoot, List<_IconEntry> entries) {
  final byDisplayName = <String, Map<String, _IconEntry>>{};
  for (final entry in entries) {
    byDisplayName.putIfAbsent(entry.displayName, () => {})[entry.style] =
        entry;
  }

  final sortedNames = byDisplayName.keys.toList()..sort();

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('//')
    ..writeln('// To regenerate, run: ./tool/generate_all.sh')
    ..writeln()
    ..writeln("import 'package:plump_icons/plump_icons.dart';")
    ..writeln()
    ..writeln('typedef IconPreviewEntry = ({')
    ..writeln('  String name,')
    ..writeln('  PlumpIconData? lineIcon,')
    ..writeln('  PlumpIconData? solidIcon,')
    ..writeln('});')
    ..writeln()
    ..writeln('const List<IconPreviewEntry> iconPreviewEntries = [');

  for (final name in sortedNames) {
    final styles = byDisplayName[name]!;
    final line = styles['line'];
    final solid = styles['solid'];
    buffer.writeln('  (');
    buffer.writeln("    name: '$name',");
    buffer.writeln(
      line == null
          ? '    lineIcon: null,'
          : '    lineIcon: PlumpIcons.${line.dartName},',
    );
    buffer.writeln(
      solid == null
          ? '    solidIcon: null,'
          : '    solidIcon: PlumpIcons.${solid.dartName},',
    );
    buffer.writeln('  ),');
  }

  buffer.writeln('];');

  final output =
      File('${packageRoot.path}/example/lib/generated_icon_list.dart');
  output.createSync(recursive: true);
  output.writeAsStringSync(buffer.toString());
}

class _IconEntry {
  const _IconEntry({
    required this.dartName,
    required this.style,
    required this.name,
    required this.assetName,
    required this.displayName,
  });

  final String dartName;
  final String style;
  final String name;
  final String assetName;
  final String displayName;
}
