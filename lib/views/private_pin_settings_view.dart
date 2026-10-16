import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/private_pin_store.dart';
import '../ui/app_palette.dart';

class PrivatePinSettingsView extends StatefulWidget {
  const PrivatePinSettingsView({
    super.key,
    required this.pinStore,
    required this.onPinSaved,
    required this.onLockout,
  });

  final PrivatePinStore pinStore;
  final VoidCallback onPinSaved;
  final Future<void> Function() onLockout;

  @override
  State<PrivatePinSettingsView> createState() => _PrivatePinSettingsViewState();
}

class _PrivatePinSettingsViewState extends State<PrivatePinSettingsView> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hasPin = false;
  bool _editing = false;
  bool _saving = false;
  String? _error;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _hasPin = widget.pinStore.isConfigured;
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
      _notice = null;
    });
    try {
      if (_hasPin) {
        if (_currentController.text.length != 4) {
          setState(() => _error = l10n.privatePinRequired);
          return;
        }
        final verification = await widget.pinStore.verify(
          _currentController.text,
        );
        if (verification == PinVerificationResult.incorrect) {
          setState(() => _error = l10n.privatePinIncorrect);
          return;
        }
        if (verification == PinVerificationResult.limitReached) {
          try {
            await widget.onLockout();
          } catch (_) {
            if (mounted) {
              setState(() => _error = l10n.privatePinLockoutDeleteFailed);
            }
            return;
          }
          if (!mounted) return;
          setState(() {
            _hasPin = false;
            _editing = false;
            _currentController.clear();
            _error = l10n.privatePinLockout;
          });
          return;
        }
        if (verification != PinVerificationResult.correct) {
          setState(() => _error = l10n.privatePinIncorrect);
          return;
        }
      }

      final newPin = _newController.text;
      if (!RegExp(r'^\d{4}$').hasMatch(newPin)) {
        setState(() => _error = l10n.privatePinRequired);
        return;
      }
      if (newPin != _confirmController.text) {
        setState(() => _error = l10n.privatePinMismatch);
        return;
      }
      await widget.pinStore.setPin(newPin);
      if (!mounted) return;
      widget.onPinSaved();
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      setState(() {
        _hasPin = true;
        _editing = false;
        _notice = l10n.privatePinSaved;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _cancelEditing() {
    _currentController.clear();
    _newController.clear();
    _confirmController.clear();
    setState(() {
      _editing = false;
      _error = null;
      _notice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      key: const ValueKey('private_pin_settings_view'),
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  key: const ValueKey('private_pin_settings_back'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.settingsPrivatePin,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (!_editing) ...[
              _statusCard(l10n),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('private_pin_edit'),
                onPressed: () => setState(() {
                  _editing = true;
                  _notice = null;
                  _error = null;
                }),
                icon: Icon(
                  _hasPin ? FLucideIcons.pencil : FLucideIcons.keyRound,
                  size: 18,
                ),
                label: Text(_hasPin ? l10n.privatePinChange : l10n.privatePinSet),
              ),
              if (_notice != null || _error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error ?? _notice!,
                  key: _error != null
                      ? const ValueKey('private_pin_error')
                      : const ValueKey('private_pin_saved_notice'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _error != null ? Colors.redAccent : AppPalette.cyan,
                  ),
                ),
                if (_error != null && _hasPin) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.privatePinAttempts(
                      widget.pinStore.failedAttempts,
                      PrivatePinStore.failedAttemptLimit,
                    ),
                    key: const ValueKey('private_pin_failed_attempts'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppPalette.muted),
                  ),
                ],
              ],
            ] else ...[
              _editForm(l10n),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('private_pin_cancel'),
                      onPressed: _saving ? null : _cancelEditing,
                      child: Text(l10n.privatePinCancel),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('private_pin_save'),
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.privatePinSave),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusCard(AppLocalizations l10n) => Container(
    key: const ValueKey('private_pin_status_card'),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      border: Border.all(color: AppPalette.border),
      borderRadius: BorderRadius.circular(18),
      gradient: const RadialGradient(
        center: Alignment.topCenter,
        radius: 1.45,
        colors: [Color(0xFF202444), AppPalette.surface],
      ),
    ),
    child: Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: _hasPin
                ? const Color(0x1A50C6E9)
                : AppPalette.surfaceRaised,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(
            _hasPin ? FLucideIcons.lockKeyhole : FLucideIcons.keyRound,
            color: _hasPin ? AppPalette.cyan : AppPalette.muted,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _hasPin ? l10n.privatePinStatusConfigured : l10n.privatePinStatusNotConfigured,
          key: const ValueKey('private_pin_status'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _editForm(AppLocalizations l10n) => Container(
    key: const ValueKey('private_pin_edit_form'),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      border: Border.all(color: AppPalette.border),
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      children: [
        if (_hasPin) ...[
          _pinField(
            key: const ValueKey('private_pin_current_input'),
            controller: _currentController,
            label: l10n.privatePinCurrent,
          ),
          const SizedBox(height: 15),
        ],
        _pinField(
          key: const ValueKey('private_pin_new_input'),
          controller: _newController,
          label: _hasPin ? l10n.privatePinNew : l10n.privatePinSet,
        ),
        const SizedBox(height: 15),
        _pinField(
          key: const ValueKey('private_pin_confirm_input'),
          controller: _confirmController,
          label: l10n.privatePinConfirm,
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            key: const ValueKey('private_pin_error'),
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
          if (_hasPin)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.privatePinAttempts(
                  widget.pinStore.failedAttempts,
                  PrivatePinStore.failedAttemptLimit,
                ),
                key: const ValueKey('private_pin_failed_attempts'),
                style: const TextStyle(color: AppPalette.muted, fontSize: 12),
              ),
            ),
        ],
      ],
    ),
  );

  Widget _pinField({
    required Key key,
    required TextEditingController controller,
    required String label,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      TextField(
        key: key,
        controller: controller,
        obscureText: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: (MediaQuery.sizeOf(context).width * .09)
              .clamp(34.0, 56.0),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        decoration: InputDecoration(
          hintText: '••••',
          hintStyle: const TextStyle(
            letterSpacing: 3,
            color: AppPalette.muted,
          ),
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
    ],
  );
}
