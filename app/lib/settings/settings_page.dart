import 'package:flutter/material.dart';

import '../backup/backup_files.dart';
import '../backup/backup_widgets.dart';
import '../backup/export_page.dart';
import '../backup/import_page.dart';
import '../data/entry_repository.dart';
import '../l10n/strings.dart';
import '../theme/tokens.dart';
import 'about_page.dart';
import 'change_passcode_page.dart';
import 'settings_controller.dart';
import '../theme/app_icons.dart';

/// S9 Settings (FEAT-009): appearance, security, backup, about.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.repository, required this.files, required this.settings, this.now});
  final EntryRepository repository;
  final BackupFiles files;
  final SettingsController settings;
  final DateTime Function()? now;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<DateTime?> _last = widget.repository.lastExportAt();
  String? _note;

  SettingsController get _s => widget.settings;

  @override
  void initState() {
    super.initState();
    _s.addListener(_changed);
  }

  @override
  void dispose() {
    _s.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  String _when(DateTime? d) {
    if (d == null) return S.neverExported;
    final now = (widget.now ?? DateTime.now)();
    if (dayKey(d) == dayKey(now)) return S.lastExport(S.today.toLowerCase());
    return S.lastExport(formatDay(dayKey(d)));
  }

  Future<T?> _sheet<T>(String title, List<Widget> Function(BuildContext) cards) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).surfaceRaised,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.screenMargin),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(header: true, child: Text(title, style: AppType.title)),
                const SizedBox(height: AppSpace.s16),
                ...cards(ctx),
                const SizedBox(height: AppSpace.s8),
                Center(child: TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(S.cancel))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: AppSpace.s12);

  String _themeName(ThemeChoice c) => switch (c) {
        ThemeChoice.system => S.themeSystem,
        ThemeChoice.light => S.themeLight,
        ThemeChoice.dark => S.themeDark,
      };

  String _languageName(LanguageChoice c) => switch (c) {
        LanguageChoice.system => S.languageSystem,
        LanguageChoice.en => S.languageEnglish,
        LanguageChoice.id => S.languageIndonesian,
      };

  String _timeoutName(Duration d) => switch (d.inMinutes) {
        0 => S.timeoutImmediately,
        1 => S.timeout1,
        5 => S.timeout5,
        _ => S.timeout15,
      };

  Future<void> _pickTheme() async {
    final v = await _sheet<ThemeChoice>(S.theme, (ctx) => [
          for (final c in ThemeChoice.values) ...[
            ChoiceCard(
              title: _themeName(c),
              note: '',
              selected: _s.theme == c,
              onTap: () => Navigator.of(ctx).pop(c),
            ),
            _gap(),
          ],
        ]);
    if (v != null) await _s.setTheme(v);
  }

  Future<void> _pickLanguage() async {
    final v = await _sheet<LanguageChoice>(S.chooseLanguageTitle, (ctx) => [
          ChoiceCard(
            title: S.languageSystem,
            note: S.languageSystemNote,
            selected: _s.language == LanguageChoice.system,
            onTap: () => Navigator.of(ctx).pop(LanguageChoice.system),
          ),
          _gap(),
          ChoiceCard(
            title: S.languageEnglish,
            note: '',
            selected: _s.language == LanguageChoice.en,
            onTap: () => Navigator.of(ctx).pop(LanguageChoice.en),
          ),
          _gap(),
          ChoiceCard(
            title: S.languageIndonesian,
            note: '',
            selected: _s.language == LanguageChoice.id,
            onTap: () => Navigator.of(ctx).pop(LanguageChoice.id),
          ),
          _gap(),
        ]);
    if (v != null) await _s.setLanguageChoice(v);
  }

  Future<void> _pickTimeout() async {
    final v = await _sheet<Duration>(S.lockTimeoutRow, (ctx) => [
          for (final d in lockTimeoutChoices) ...[
            ChoiceCard(
              title: _timeoutName(d),
              note: d == Duration.zero ? S.timeoutRecommended : '',
              selected: _s.lockTimeout == d,
              onTap: () => Navigator.of(ctx).pop(d),
            ),
            _gap(),
          ],
        ]);
    if (v != null) await _s.setLockTimeout(v);
  }

  Future<void> _toggleBiometrics(bool on) async {
    final r = await _s.setBiometrics(on);
    if (!mounted) return;
    setState(() {
      _note = switch (r) {
        BiometricsChange.unavailable => S.biometricsUnavailable,
        BiometricsChange.notRecognised => S.biometricsFailed,
        _ => null,
      };
    });
  }

  Future<void> _export() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ExportPage(repository: widget.repository, files: widget.files, now: widget.now),
    ));
    if (mounted) {
      setState(() {
        _last = widget.repository.lastExportAt();
      });
    }
  }

  Future<void> _import() async {
    final done = await Navigator.of(context).push<bool>(MaterialPageRoute<bool>(
      builder: (_) => ImportPage(repository: widget.repository, files: widget.files),
    ));
    if (done == true && mounted) Navigator.of(context).pop(); // "Open my journal"
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget section(String label) => Padding(
          padding: const EdgeInsets.only(top: AppSpace.s24, bottom: AppSpace.s4),
          child: Semantics(header: true, child: Text(label, style: AppType.caption.copyWith(color: c.textSecondary))),
        );
    Widget row(String title, {String? value, Widget? trailing, required VoidCallback onTap, Key? key}) => InkWell(
          key: key,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.s12),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: AppType.body),
                    if (value != null) Text(value, style: AppType.caption.copyWith(color: c.textSecondary)),
                  ]),
                ),
                trailing ?? Icon(AppIcons.chevronRight, color: c.textSecondary),
              ]),
            ),
          ),
        );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenMargin),
          child: ListView(
            children: [
              Row(children: [
                IconButton(
                  tooltip: S.back,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(AppIcons.back),
                  constraints: const BoxConstraints(minWidth: AppSpace.touchMin, minHeight: AppSpace.touchMin),
                ),
                Semantics(header: true, child: Text(S.settings, style: AppType.title)),
              ]),
              section(S.appearance),
              row(S.theme, value: _themeName(_s.theme), onTap: _pickTheme, key: const Key('row-theme')),
              Divider(height: 1, color: c.borderDefault),
              row(S.language, value: _languageName(_s.language), onTap: _pickLanguage, key: const Key('row-language')),
              section(S.securitySection),
              row(
                S.changePasscode,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ChangePasscodePage(settings: _s))),
                key: const Key('row-change-passcode'),
              ),
              Divider(height: 1, color: c.borderDefault),
              row(
                S.biometricsRow,
                value: _s.biometricsOn ? S.on : S.off,
                key: const Key('row-biometrics'),
                onTap: () => _toggleBiometrics(!_s.biometricsOn),
                trailing: Semantics(
                  label: '${S.biometricsRow}, ${_s.biometricsOn ? S.on : S.off}',
                  child: ExcludeSemantics(
                    child: Switch(value: _s.biometricsOn, onChanged: _toggleBiometrics),
                  ),
                ),
              ),
              if (_note != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.s8),
                  child: Semantics(liveRegion: true, child: Text(_note!, style: AppType.caption.copyWith(color: c.warningFg))),
                ),
              Divider(height: 1, color: c.borderDefault),
              row(S.lockTimeoutRow, value: _timeoutName(_s.lockTimeout), onTap: _pickTimeout, key: const Key('row-lock-timeout')),
              section(S.backupSection),
              row(
                S.exportRow,
                onTap: _export,
                key: const Key('row-export'),
                trailing: FutureBuilder<DateTime?>(
                  future: _last,
                  builder: (context, snap) => snap.connectionState != ConnectionState.done
                      ? const SizedBox.shrink()
                      : Flexible(
                          child: Text(_when(snap.data), style: AppType.caption.copyWith(color: c.textSecondary), textAlign: TextAlign.end),
                        ),
                ),
              ),
              Divider(height: 1, color: c.borderDefault),
              row(S.importRow, onTap: _import, key: const Key('row-import')),
              section(S.aboutSection),
              row(
                S.aboutRow,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AboutPage())),
                key: const Key('row-about'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
