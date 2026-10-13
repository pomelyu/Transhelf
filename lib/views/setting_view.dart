import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../l10n/generated/app_localizations.dart';
import '../ui/app_palette.dart';

class SettingView extends StatelessWidget {
  const SettingView({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Text(
            l10n.navSettings,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Container(
            height: 76,
            decoration: BoxDecoration(
              color: AppPalette.surfaceRaised,
              border: Border.all(color: AppPalette.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Transhelf',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.settingsTagline,
                  style: const TextStyle(fontSize: 11, color: AppPalette.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _section(l10n.settingsTranslationSection),
          FTileGroup(
            intrinsicWidth: true,
            children: [
              FTile(
                title: Text(l10n.settingsTranslator),
                subtitle: Text(l10n.settingsTranslatorSubtitle),
                prefix: const Icon(FLucideIcons.cloud, color: AppPalette.blue),
                suffix: Text(
                  l10n.settingsComingSoon,
                  style: const TextStyle(fontSize: 11, color: AppPalette.muted),
                ),
              ),
              FTile(
                title: Text(l10n.settingsPresets),
                subtitle: Text(l10n.settingsPresetsSubtitle),
                prefix: const Icon(
                  FLucideIcons.slidersHorizontal,
                  color: AppPalette.blue,
                ),
                suffix: Text(
                  l10n.settingsComingSoon,
                  style: const TextStyle(fontSize: 11, color: AppPalette.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(l10n.settingsLanguageSection),
          FTileGroup(
            intrinsicWidth: true,
            children: [
              FTile(
                key: const Key('language_setting'),
                title: Text(l10n.settingsAppLanguage),
                prefix: const Icon(
                  FLucideIcons.languages,
                  color: AppPalette.blue,
                ),
                details: Text(
                  locale.languageCode == 'en'
                      ? l10n.languageEnglish
                      : l10n.languageTraditionalChinese,
                ),
                suffix: const Icon(FLucideIcons.chevronRight, size: 16),
                onPress: () => _showLanguagePicker(context, l10n),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(l10n.settingsPrivacySection),
          FTileGroup(
            intrinsicWidth: true,
            children: [
              FTile(
                title: Text(l10n.settingsAutosave),
                prefix: const Icon(FLucideIcons.save, color: AppPalette.blue),
                suffix: const FSwitch(value: true, enabled: false),
              ),
              FTile(
                title: Text(l10n.settingsPrivatePin),
                prefix: const Icon(
                  FLucideIcons.keyRound,
                  color: AppPalette.blue,
                ),
                suffix: Text(
                  l10n.settingsComingSoon,
                  style: const TextStyle(fontSize: 11, color: AppPalette.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(3, 0, 0, 7),
    child: Text(
      title,
      style: const TextStyle(fontSize: 11, color: AppPalette.muted),
    ),
  );

  Future<void> _showLanguagePicker(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final selected = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: AppPalette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.languageTraditionalChinese),
              trailing: locale.languageCode == 'zh'
                  ? const Icon(FLucideIcons.check, color: AppPalette.cyan)
                  : null,
              onTap: () => Navigator.pop(
                context,
                const Locale.fromSubtags(
                  languageCode: 'zh',
                  scriptCode: 'Hant',
                  countryCode: 'TW',
                ),
              ),
            ),
            ListTile(
              title: Text(l10n.languageEnglish),
              trailing: locale.languageCode == 'en'
                  ? const Icon(FLucideIcons.check, color: AppPalette.cyan)
                  : null,
              onTap: () => Navigator.pop(context, const Locale('en')),
            ),
          ],
        ),
      ),
    );
    if (selected != null) onLocaleChanged(selected);
  }
}
