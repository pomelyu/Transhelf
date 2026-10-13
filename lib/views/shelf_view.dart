import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../l10n/generated/app_localizations.dart';
import '../ui/app_palette.dart';

class ShelfView extends StatelessWidget {
  const ShelfView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.navShelf,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            FTextField(
              key: const Key('shelf_search'),
              hint: l10n.shelfSearchHint,
              prefixBuilder: (_, _, _) =>
                  const Icon(FLucideIcons.search, size: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  FLucideIcons.arrowDownUp,
                  size: 15,
                  color: AppPalette.muted,
                ),
                const SizedBox(width: 5),
                Text(
                  l10n.shelfSortRecent,
                  style: const TextStyle(fontSize: 12, color: AppPalette.muted),
                ),
                const Spacer(),
                Text(
                  l10n.shelfShowPrivate,
                  style: const TextStyle(fontSize: 12, color: AppPalette.muted),
                ),
                const SizedBox(width: 8),
                const FSwitch(value: false, enabled: false),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  border: Border.all(color: AppPalette.border),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      FLucideIcons.bookOpen,
                      size: 34,
                      color: AppPalette.blue,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.shelfEmptyTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.shelfEmptyDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppPalette.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
