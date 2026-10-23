import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/article.dart';
import '../ui/app_palette.dart';
import '../ui/status_notice.dart';

enum _ShelfSort { recent, oldest, progress, title }

class ShelfView extends StatefulWidget {
  const ShelfView({
    super.key,
    required this.articles,
    required this.showPrivateArticles,
    required this.onPrivateModeChanged,
    required this.onOpen,
    required this.onDelete,
  });

  final List<Article> articles;
  final bool showPrivateArticles;
  final ValueChanged<bool> onPrivateModeChanged;
  final ValueChanged<Article> onOpen;
  final Future<void> Function(Article) onDelete;

  @override
  State<ShelfView> createState() => _ShelfViewState();
}

class _ShelfViewState extends State<ShelfView> {
  String _query = '';
  _ShelfSort _sort = _ShelfSort.recent;

  List<Article> get _visible {
    final articles = widget.articles
        .where(
          (article) =>
              (!article.isPrivate || widget.showPrivateArticles) &&
              article.title.toLowerCase().contains(_query.trim().toLowerCase()),
        )
        .toList();
    switch (_sort) {
      case _ShelfSort.recent:
        articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _ShelfSort.oldest:
        articles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _ShelfSort.progress:
        articles.sort((a, b) => b.progress.compareTo(a.progress));
      case _ShelfSort.title:
        articles.sort((a, b) => a.title.compareTo(b.title));
    }
    return articles;
  }

  String _sortLabel(AppLocalizations l10n, _ShelfSort sort) => switch (sort) {
    _ShelfSort.recent => l10n.shelfSortRecent,
    _ShelfSort.oldest => l10n.shelfSortOldest,
    _ShelfSort.progress => l10n.shelfSortProgress,
    _ShelfSort.title => l10n.shelfSortTitle,
  };

  Future<void> _confirmDelete(Article article) async {
    final l10n = AppLocalizations.of(context)!;
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppPalette.surface,
        title: Text(l10n.articleDeleteConfirm),
        content: Text(article.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.articleCancel),
          ),
          TextButton(
            key: const ValueKey('article_delete_confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.articleDelete),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    try {
      await widget.onDelete(article);
      if (mounted) {
        StatusNotice.show(context, success: true, message: l10n.articleDeleted);
      }
    } catch (_) {
      if (mounted) {
        StatusNotice.show(
          context,
          success: false,
          message: l10n.articleDeleteFailed,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final articles = _visible;
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.navShelf,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              FTextField(
                key: const Key('shelf_search'),
                hint: l10n.shelfSearchHint,
                control: FTextFieldControl.managed(
                  onChange: (value) => setState(() => _query = value.text),
                ),
                prefixBuilder: (_, _, _) => const Padding(
                  padding: EdgeInsetsDirectional.only(start: 12, end: 4),
                  child: Icon(FLucideIcons.search, size: 18),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  PopupMenuButton<_ShelfSort>(
                    key: const ValueKey('shelf_sort'),
                    color: AppPalette.surfaceRaised,
                    onSelected: (value) => setState(() => _sort = value),
                    itemBuilder: (_) => _ShelfSort.values
                        .map(
                          (value) => PopupMenuItem(
                            value: value,
                            child: Text(_sortLabel(l10n, value)),
                          ),
                        )
                        .toList(),
                    child: Row(
                      children: [
                        const Icon(
                          FLucideIcons.arrowDownUp,
                          size: 15,
                          color: AppPalette.muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _sortLabel(l10n, _sort),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppPalette.muted,
                          ),
                        ),
                        const Icon(
                          FLucideIcons.chevronDown,
                          size: 14,
                          color: AppPalette.muted,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.shelfShowPrivate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPalette.muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FSwitch(
                    key: const ValueKey('shelf_private_toggle'),
                    value: widget.showPrivateArticles,
                    onChange: widget.onPrivateModeChanged,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: articles.isEmpty
                    ? _empty(l10n, search: _query.trim().isNotEmpty)
                    : ListView.separated(
                        key: const ValueKey('shelf_article_list'),
                        itemCount: articles.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) =>
                            _articleCard(articles[index], l10n),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(AppLocalizations l10n, {required bool search}) => Container(
    key: const ValueKey('shelf_empty'),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      border: Border.all(color: AppPalette.border),
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(FLucideIcons.bookOpen, size: 34, color: AppPalette.blue),
        const SizedBox(height: 18),
        Text(
          search ? l10n.articleNoResults : l10n.shelfEmptyTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        if (!search) ...[
          const SizedBox(height: 8),
          Text(
            l10n.shelfEmptyDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppPalette.muted),
          ),
        ],
      ],
    ),
  );

  Widget _articleCard(Article article, AppLocalizations l10n) {
    final date = article.createdAt.toLocal();
    final dateLabel =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return Container(
      key: ValueKey('article_${article.id}'),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        border: Border.all(color: AppPalette.border),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => widget.onOpen(article),
              borderRadius: BorderRadius.circular(17),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            article.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (article.isPrivate) ...[
                          const SizedBox(width: 8),
                          Container(
                            key: ValueKey('article_private_tag_${article.id}'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x1A8AA9FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppPalette.blue.withValues(alpha: .28),
                              ),
                            ),
                            child: Semantics(
                              label: l10n.shelfPrivateTag,
                              child: const Icon(
                                FLucideIcons.lockKeyhole,
                                size: 13,
                                color: AppPalette.blue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      article.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppPalette.muted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$dateLabel  ·  ${l10n.articleReadPercent((article.progress * 100).round())}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppPalette.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: article.progress,
                      minHeight: 3,
                      backgroundColor: AppPalette.border,
                      color: AppPalette.purple,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            key: ValueKey('article_menu_${article.id}'),
            tooltip: l10n.articleDelete,
            color: AppPalette.surfaceRaised,
            onSelected: (_) => _confirmDelete(article),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'delete', child: Text(l10n.articleDelete)),
            ],
            icon: const Icon(
              FLucideIcons.ellipsis,
              size: 19,
              color: AppPalette.muted,
            ),
          ),
        ],
      ),
    );
  }
}
