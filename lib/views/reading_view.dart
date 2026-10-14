import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/article.dart';
import '../ui/app_palette.dart';

enum _ReadingMode { translation, source, both }

enum _ReaderSize { small, medium, large }

class ReadingView extends StatefulWidget {
  const ReadingView({
    super.key,
    required this.article,
    required this.onProgress,
  });

  final Article article;
  final Future<void> Function(double) onProgress;

  @override
  State<ReadingView> createState() => _ReadingViewState();
}

class _ReadingViewState extends State<ReadingView> with WidgetsBindingObserver {
  final ScrollController _scroll = ScrollController();
  _ReadingMode _mode = _ReadingMode.translation;
  _ReaderSize _size = _ReaderSize.medium;
  bool _relaxed = false;
  bool _showSettings = false;
  bool _allowPop = false;
  bool _closing = false;
  late double _progress = widget.article.progress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scroll.addListener(_updateProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent * _progress);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_saveOnPause());
    }
  }

  Future<void> _saveOnPause() async {
    try {
      await widget.onProgress(_progress);
    } catch (_) {
      // A later return to the shelf retries the progress write.
    }
  }

  void _updateProgress() {
    if (!_scroll.hasClients) return;
    final extent = _scroll.position.maxScrollExtent;
    final value = extent <= 0 ? 1.0 : (_scroll.offset / extent).clamp(0.0, 1.0);
    if ((value - _progress).abs() >= 0.001) setState(() => _progress = value);
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    try {
      await widget.onProgress(_progress);
    } catch (_) {
      // Keep navigation available if the device cannot write progress.
    }
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textSize = switch (_size) {
      _ReaderSize.small => 15.0,
      _ReaderSize.medium => 17.0,
      _ReaderSize.large => 20.0,
    };
    final textHeight = _relaxed ? 2.15 : 1.82;
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: AppPalette.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  children: [
                    IconButton(
                      key: const ValueKey('reader_back'),
                      tooltip: l10n.readerBack,
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(FLucideIcons.arrowLeft),
                    ),
                    Expanded(
                      child: Text(
                        widget.article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('reader_settings'),
                      tooltip: l10n.readerSettings,
                      onPressed: () =>
                          setState(() => _showSettings = !_showSettings),
                      icon: const Icon(FLucideIcons.slidersHorizontal),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _progressBar(),
              ),
              if (_showSettings)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _settings(l10n),
                ),
              Expanded(
                child: CustomScrollView(
                  key: const ValueKey('reader_content'),
                  controller: _scroll,
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _ReaderModeHeader(child: _modePicker(l10n)),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 60),
                      sliver: SliverList.builder(
                        itemCount: widget.article.segments.length,
                        itemBuilder: (_, index) => _paragraph(
                          widget.article.segments[index],
                          index,
                          textSize,
                          textHeight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar() => Container(
    key: const ValueKey('reader_progress'),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      border: Border.all(color: AppPalette.border),
      borderRadius: BorderRadius.circular(17),
    ),
    child: Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 4,
            backgroundColor: AppPalette.border,
            color: AppPalette.purple,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${(_progress * 100).round()}%',
          style: const TextStyle(
            color: AppPalette.blue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _settings(AppLocalizations l10n) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      border: Border.all(color: AppPalette.border),
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Text(
              l10n.readerTextSize,
              style: const TextStyle(fontSize: 13, color: AppPalette.muted),
            ),
            const Spacer(),
            SizedBox(
              width: 205,
              child: _segmented<_ReaderSize>(
                _size,
                [
                  (_ReaderSize.small, l10n.readerSmall),
                  (_ReaderSize.medium, l10n.readerMedium),
                  (_ReaderSize.large, l10n.readerLarge),
                ],
                (value) => setState(() => _size = value),
                'reader_size',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.readerRelaxedSpacing,
                style: const TextStyle(fontSize: 13, color: AppPalette.muted),
              ),
            ),
            FSwitch(
              key: const ValueKey('reader_spacing'),
              value: _relaxed,
              onChange: (value) => setState(() => _relaxed = value),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _modePicker(AppLocalizations l10n) => _segmented<_ReadingMode>(
    _mode,
    [
      (_ReadingMode.translation, l10n.readerTranslation),
      (_ReadingMode.source, l10n.readerSource),
      (_ReadingMode.both, l10n.readerBoth),
    ],
    (value) => setState(() => _mode = value),
    'reader_mode',
  );

  Widget _segmented<T>(
    T selected,
    List<(T, String)> options,
    ValueChanged<T> onSelect,
    String keyPrefix,
  ) => Container(
    height: 42,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      border: Border.all(color: AppPalette.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: options
          .map(
            (option) => Expanded(
              child: InkWell(
                key: ValueKey('${keyPrefix}_${option.$1}'),
                onTap: () => onSelect(option.$1),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == option.$1
                        ? AppPalette.surfaceRaised
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    option.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected == option.$1
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: selected == option.$1
                          ? Colors.white
                          : AppPalette.muted,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _paragraph(
    ArticleSegment segment,
    int index,
    double size,
    double height,
  ) => Padding(
    key: ValueKey('reader_segment_$index'),
    padding: const EdgeInsets.only(bottom: 27),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_mode != _ReadingMode.source)
          SelectableText(
            segment.translation,
            style: TextStyle(
              fontSize: size,
              height: height,
              color: Colors.white,
            ),
          ),
        if (_mode == _ReadingMode.both) ...[
          const SizedBox(height: 16),
          Container(
            width: 26,
            height: 2,
            decoration: const BoxDecoration(gradient: AppPalette.accent),
          ),
          const SizedBox(height: 16),
        ],
        if (_mode != _ReadingMode.translation)
          SelectableText(
            segment.source,
            style: TextStyle(
              fontSize: size,
              height: height,
              color: AppPalette.muted,
            ),
          ),
      ],
    ),
  );
}

class _ReaderModeHeader extends SliverPersistentHeaderDelegate {
  _ReaderModeHeader({required this.child});

  final Widget child;

  @override
  double get minExtent => 58;

  @override
  double get maxExtent => 58;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(
    color: AppPalette.background,
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
    child: child,
  );

  @override
  bool shouldRebuild(covariant _ReaderModeHeader oldDelegate) => true;
}
