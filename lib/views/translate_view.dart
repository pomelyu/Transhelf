import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../l10n/generated/app_localizations.dart';
import '../ui/app_palette.dart';

class TranslateView extends StatelessWidget {
  const TranslateView({super.key});

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
              l10n.navTranslate,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: _panelDecoration,
              child: Column(
                children: [
                  Row(
                    children: [
                      _choice(l10n.translateEngine, 'Gemini'),
                      const SizedBox(width: 8),
                      _choice(l10n.translatePreset, l10n.translatePresetName),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _choice('', l10n.translateFromLanguage),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          FLucideIcons.arrowLeftRight,
                          size: 18,
                          color: AppPalette.muted,
                        ),
                      ),
                      _choice('', l10n.translateToLanguage),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 42,
              decoration: _panelDecoration,
              child: Row(
                children: [
                  _tab(l10n.translateSource, false),
                  _tab(l10n.translateResult, true),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: _panelDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gemini · ${l10n.translateResult}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppPalette.muted,
                      ),
                    ),
                    const Divider(height: 22, color: AppPalette.border),
                    Text(
                      l10n.translateOutputHint,
                      style: const TextStyle(
                        color: AppPalette.muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _action(l10n.translateStart, true)),
                const SizedBox(width: 8),
                Expanded(child: _action(l10n.translateSave, false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static final _panelDecoration = BoxDecoration(
    color: AppPalette.surface,
    border: Border.all(color: AppPalette.border),
    borderRadius: BorderRadius.circular(17),
  );

  Widget _choice(String label, String value) => Expanded(
    child: Container(
      height: 49,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label.isNotEmpty)
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppPalette.muted,
                    ),
                  ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
  );

  Widget _tab(String label, bool selected) => Expanded(
    child: Container(
      margin: const EdgeInsets.all(3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppPalette.surfaceRaised : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? Colors.white : AppPalette.muted,
        ),
      ),
    ),
  );

  Widget _action(String label, bool primary) => Container(
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: primary ? AppPalette.accent : null,
      color: primary ? null : AppPalette.surfaceRaised,
      borderRadius: BorderRadius.circular(13),
      border: primary ? null : Border.all(color: AppPalette.border),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
  );
}
