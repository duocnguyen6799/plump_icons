import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plump_icons/plump_icons.dart';
import 'package:plump_icons_example/generated_icon_list.dart';

void main() {
  runApp(const ExampleApp());
}

enum StyleFilter { all, line, solid }

abstract final class _AppColors {
  static const blue = Color(0xFF2196F3);
  static const blueDark = Color(0xFF1976D2);
  static const blueLight = Color(0xFFE3F2FD);
  static const blueMuted = Color(0xFF64B5F6);
}

Future<void> _copyToClipboard(
  BuildContext context,
  ScaffoldMessengerState messenger,
  String text, {
  String message = 'Copied to clipboard',
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) {
    return;
  }

  final screenHeight = MediaQuery.sizeOf(context).height;
  final topInset = MediaQuery.paddingOf(context).top;

  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: screenHeight - topInset - 56,
        left: 16,
        right: 16,
      ),
      duration: const Duration(seconds: 2),
      dismissDirection: DismissDirection.up,
    ),
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plump Icons',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _AppColors.blue,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            elevation: const WidgetStatePropertyAll(0),
            shadowColor: const WidgetStatePropertyAll(Colors.transparent),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return _AppColors.blue;
              }
              return _AppColors.blueLight;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return _AppColors.blueDark;
            }),
            side: const WidgetStatePropertyAll(
              BorderSide(color: _AppColors.blue),
            ),
          ),
        ),
      ),
      home: const IconBrowserPage(),
    );
  }
}

class IconBrowserPage extends StatefulWidget {
  const IconBrowserPage({super.key});

  @override
  State<IconBrowserPage> createState() => _IconBrowserPageState();
}

class _IconBrowserPageState extends State<IconBrowserPage> {
  String _query = '';
  StyleFilter _styleFilter = StyleFilter.all;

  List<IconPreviewEntry> get _filteredEntries {
    final query = _query.trim().toLowerCase();
    var entries = iconPreviewEntries;

    if (query.isNotEmpty) {
      entries = entries
          .where((entry) => entry.name.toLowerCase().contains(query))
          .toList();
    }

    return entries.where((entry) {
      return switch (_styleFilter) {
        StyleFilter.all => entry.lineIcon != null || entry.solidIcon != null,
        StyleFilter.line => entry.lineIcon != null,
        StyleFilter.solid => entry.solidIcon != null,
      };
    }).toList();
  }

  void _showIconDetails(IconPreviewEntry entry) {
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final lineCode =
            entry.lineIcon == null ? null : 'PlumpIcons.${entry.name}Line';
        final solidCode =
            entry.solidIcon == null ? null : 'PlumpIcons.${entry.name}Solid';

        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                entry.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (entry.lineIcon != null)
                    _PreviewTile(
                      label: 'Line',
                      icon: entry.lineIcon!,
                      filled: false,
                    ),
                  if (entry.lineIcon != null && entry.solidIcon != null)
                    const SizedBox(width: 24),
                  if (entry.solidIcon != null)
                    _PreviewTile(
                      label: 'Solid',
                      icon: entry.solidIcon!,
                      filled: true,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (lineCode != null) ...[
                _CodeBlock(
                  label: 'Line',
                  code: 'PlumpIcon($lineCode)',
                  messenger: messenger,
                ),
                const SizedBox(height: 12),
              ],
              if (solidCode != null)
                _CodeBlock(
                  label: 'Solid',
                  code: 'PlumpIcon($solidCode)',
                  messenger: messenger,
                ),
              if (lineCode != null && solidCode != null) ...[
                const SizedBox(height: 16),
                _BottomNavCodeBlock(
                  messenger: messenger,
                  code: 'BottomNavigationBarItem(\n'
                      '  icon: PlumpIcon($lineCode),\n'
                      '  activeIcon: PlumpIcon($solidCode),\n'
                      "  label: 'Home',\n"
                      ')',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plump Icons',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Streamline Plump · Line & Solid',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            SegmentedButton<StyleFilter>(
                              segments: const [
                                ButtonSegment(
                                  value: StyleFilter.all,
                                  label: Text('All'),
                                ),
                                ButtonSegment(
                                  value: StyleFilter.line,
                                  label: Text('Line'),
                                ),
                                ButtonSegment(
                                  value: StyleFilter.solid,
                                  label: Text('Solid'),
                                ),
                              ],
                              selected: {_styleFilter},
                              onSelectionChanged: (selection) {
                                setState(
                                  () => _styleFilter = selection.first,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SearchBar(
                          hintText: 'Search 500 icons...',
                          leading: const Icon(
                            Icons.search,
                            color: _AppColors.blueDark,
                          ),
                          elevation: const WidgetStatePropertyAll(0),
                          shadowColor:
                              const WidgetStatePropertyAll(Colors.transparent),
                          backgroundColor: const WidgetStatePropertyAll(
                            _AppColors.blueLight,
                          ),
                          side: const WidgetStatePropertyAll(
                            BorderSide(color: _AppColors.blue),
                          ),
                          hintStyle: WidgetStatePropertyAll(
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _AppColors.blueMuted,
                                ),
                          ),
                          onChanged: (value) => setState(() => _query = value),
                          trailing: _query.isEmpty
                              ? null
                              : [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: _AppColors.blueDark,
                                    ),
                                    onPressed: () =>
                                        setState(() => _query = ''),
                                  ),
                                ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${entries.length} result${entries.length == 1 ? '' : 's'}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                  ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (entries.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.black26),
                          SizedBox(height: 12),
                          Text('No icons match your search.'),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final crossAxisCount = width >= 900
                            ? 5
                            : width >= 700
                                ? 4
                                : width >= 480
                                    ? 3
                                    : 2;

                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.92,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entry = entries[index];
                              return _IconCard(
                                entry: entry,
                                styleFilter: _styleFilter,
                                onTap: () => _showIconDetails(entry),
                              );
                            },
                            childCount: entries.length,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconCard extends StatelessWidget {
  const _IconCard({
    required this.entry,
    required this.styleFilter,
    required this.onTap,
  });

  final IconPreviewEntry entry;
  final StyleFilter styleFilter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showLine = styleFilter != StyleFilter.solid && entry.lineIcon != null;
    final showSolid =
        styleFilter != StyleFilter.line && entry.solidIcon != null;
    final singleMode = styleFilter != StyleFilter.all;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showLine)
                        Expanded(
                          child: _MiniIcon(
                            icon: entry.lineIcon!,
                            size: singleMode ? 36 : 28,
                          ),
                        ),
                      if (showLine && showSolid && !singleMode)
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFFEEEEEE),
                        ),
                      if (showSolid)
                        Expanded(
                          child: _MiniIcon(
                            icon: entry.solidIcon!,
                            size: singleMode ? 36 : 28,
                            bold: true,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  entry.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (!singleMode && showLine && showSolid) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StyleBadge(label: 'Line', filled: false),
                      const SizedBox(width: 6),
                      _StyleBadge(label: 'Solid', filled: true),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon({
    required this.icon,
    required this.size,
    this.bold = false,
  });

  final PlumpIconData icon;
  final double size;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return PlumpIcon(
      icon,
      size: size,
      color: bold ? const Color(0xFF111111) : const Color(0xFF444444),
    );
  }
}

class _StyleBadge extends StatelessWidget {
  const _StyleBadge({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF1A1A1A) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: filled ? const Color(0xFF1A1A1A) : const Color(0xFFCCCCCC),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: filled ? Colors.white : const Color(0xFF666666),
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.label,
    required this.icon,
    required this.filled,
  });

  final String label;
  final PlumpIconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Center(
            child: PlumpIcon(
              icon,
              size: 48,
              color: filled ? const Color(0xFF111111) : const Color(0xFF444444),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _StyleBadge(label: label, filled: filled),
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({
    required this.label,
    required this.code,
    required this.messenger,
  });

  final String label;
  final String code;
  final ScaffoldMessengerState messenger;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
        ),
        Expanded(
          child: _CopyableCodeFrame(
            code: code,
            messenger: messenger,
          ),
        ),
      ],
    );
  }
}

class _BottomNavCodeBlock extends StatelessWidget {
  const _BottomNavCodeBlock({
    required this.code,
    required this.messenger,
  });

  final String code;
  final ScaffoldMessengerState messenger;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bottom bar',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        _CopyableCodeFrame(
          code: code,
          messenger: messenger,
          copyMessage: 'Bottom bar snippet copied',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                height: 1.5,
              ),
        ),
      ],
    );
  }
}

class _CopyableCodeFrame extends StatelessWidget {
  const _CopyableCodeFrame({
    required this.code,
    required this.messenger,
    this.copyMessage,
    this.style,
  });

  final String code;
  final ScaffoldMessengerState messenger;
  final String? copyMessage;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              code,
              style: style ??
                  const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
            ),
          ),
          IconButton(
            tooltip: 'Copy',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () => _copyToClipboard(
              context,
              messenger,
              code,
              message: copyMessage ?? 'Copied to clipboard',
            ),
          ),
        ],
      ),
    );
  }
}
