import 'dart:io';
import 'dart:typed_data';

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';

import 'backup/backup_files.dart';
import 'data/data_key_source.dart';
import 'journal/cannot_open_page.dart';
import 'journal/journal_session.dart';
import 'journal/timeline_page.dart';
import 'l10n/strings.dart';
import 'lock/lock_page.dart';
import 'onboarding/onboarding_flow.dart';
import 'security/biometrics.dart';
import 'security/key_vault.dart';
import 'security/secret_store.dart';
import 'settings/settings_controller.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';
import 'widgets/common.dart';

void main() {
  runApp(const JournalApp());
}

/// The app. The optional parameters are for tests; the app uses the defaults.
class JournalApp extends StatelessWidget {
  const JournalApp({
    super.key,
    this.directory,
    this.secrets,
    this.biometrics,
    this.kdf,
    this.lockTimeout = Duration.zero,
    this.now,
    this.testKeySource,
    this.files,
    this.phoneLanguage,
  });

  /// TEST ONLY: the phone's language code (the app reads the real one).
  final String Function()? phoneLanguage;

  final Directory? directory;
  final SecretStore? secrets;
  final Biometrics? biometrics;
  final KdfParams? kdf;

  /// How long the app may stay in the background before it locks. Zero means
  /// "Immediately", the default (FEAT-003); the choices arrive with FEAT-009.
  final Duration lockTimeout;
  final DateTime Function()? now;

  /// TEST ONLY: skips onboarding and the lock and opens the journal with this key.
  final DataKeySource? testKeySource;

  /// How exports leave and imports arrive; tests pass a fake.
  final BackupFiles? files;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      files: files,
      phoneLanguage: phoneLanguage,
      directory: directory,
      secrets: secrets,
      biometrics: biometrics,
      kdf: kdf,
      lockTimeout: lockTimeout,
      now: now,
      testKeySource: testKeySource,
    );
  }
}

enum _Phase { booting, onboarding, locked, open, cannotOpen, tooNew }

class _Shell extends StatefulWidget {
  const _Shell({
    this.directory,
    this.secrets,
    this.biometrics,
    this.kdf,
    required this.lockTimeout,
    this.now,
    this.testKeySource,
    this.files,
    this.phoneLanguage,
  });
  final String Function()? phoneLanguage;
  final BackupFiles? files;
  final Directory? directory;
  final SecretStore? secrets;
  final Biometrics? biometrics;
  final KdfParams? kdf;
  final Duration lockTimeout;
  final DateTime Function()? now;
  final DataKeySource? testKeySource;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> with WidgetsBindingObserver {
  final _navigator = GlobalKey<NavigatorState>();
  late final Biometrics _biometrics = widget.biometrics ?? PlatformBiometrics();
  late final BackupFiles _files = widget.files ?? SystemBackupFiles();
  bool _importAfterSetup = false; // chosen on the welcome screen
  bool _importThisSession = false; // consumed by the first timeline after setup

  KeyVault? _vault;
  SettingsController? _settings;
  String _shownLanguage = 'en';
  Directory? _dir;
  _Phase _phase = _Phase.booting;
  SessionOpen? _session;
  Uint8List? _key;
  bool _obscured = false;
  DateTime? _leftAt;

  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _boot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settings?.removeListener(_onSettings);
    _session?.database.close();
    _key?.fillRange(0, _key!.length, 0);
    super.dispose();
  }

  Future<void> _boot() async {
    final files = _files;
    if (files is SystemBackupFiles) await files.clearLeftovers(); // no export file is kept between runs
    final dir = widget.directory ?? await getApplicationSupportDirectory();
    _dir = dir;
    _vault = KeyVault(
      directory: dir,
      secrets: widget.secrets ?? OsSecretStore(),
      params: widget.kdf ?? const KdfParams(),
      now: widget.now,
    );
    final settings = SettingsController(
      directory: dir,
      vault: _vault!,
      biometrics: _biometrics,
      phoneLanguage: widget.phoneLanguage ?? () => ui.PlatformDispatcher.instance.locale.languageCode,
      initialLockTimeout: widget.lockTimeout,
    );
    await settings.loadPrefs();
    _settings = settings;
    _shownLanguage = currentLanguage;
    settings.addListener(_onSettings);
    if (widget.testKeySource != null) {
      await _openWith(await widget.testKeySource!.load());
      return;
    }
    if (!mounted) return;
    setState(() => _phase = _vault!.isSetUp ? _Phase.locked : _Phase.onboarding);
  }

  /// A setting changed. A new language redraws every screen that is already open.
  void _onSettings() {
    if (!mounted) return;
    setState(() {});
    if (currentLanguage != _shownLanguage) {
      _shownLanguage = currentLanguage;
      void rebuild(Element e) {
        e.markNeedsBuild();
        e.visitChildren(rebuild);
      }

      WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
    }
  }

  Duration get _lockTimeout => _settings?.lockTimeout ?? widget.lockTimeout;

  Future<void> _openWith(Uint8List key) async {
    _key = key;
    final result = await openJournal(keySource: StaticKeySource(key), directory: _dir);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case SessionOpen():
          _session = result;
          _phase = _Phase.open;
          unawaited(_settings?.attach(result.repository, () => _key));
          _importThisSession = _importAfterSetup;
          _importAfterSetup = false;
        case SessionTooNew():
          _phase = _Phase.tooNew;
        case SessionCannotOpen():
          _phase = _Phase.cannotOpen;
      }
    });
  }

  Future<void> _complete(String passcode, bool bio) async {
    final key = await _vault!.create(passcode, enableBiometrics: bio);
    await _openWith(key);
  }

  /// Closes the journal and forgets the key, then shows the lock screen (FEAT-003).
  Future<void> _lock() async {
    if (_phase == _Phase.booting || _phase == _Phase.onboarding || _phase == _Phase.locked) return;
    final session = _session;
    final key = _key;
    _session = null;
    _key = null;
    _importThisSession = false;
    _settings?.detach();
    _navigator.currentState?.popUntil((r) => r.isFirst);
    if (mounted) setState(() => _phase = _Phase.locked);
    await session?.database.close();
    key?.fillRange(0, key.length, 0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        // Hide the content before the system takes its app-switcher snapshot.
        setState(() => _obscured = true);
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _leftAt ??= _now;
        setState(() => _obscured = true);
        if (_lockTimeout == Duration.zero) _lock();
      case AppLifecycleState.resumed:
        final left = _leftAt;
        _leftAt = null;
        if (left != null && _now.difference(left) >= _lockTimeout) _lock();
        setState(() => _obscured = false);
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
      title: S.appTitle,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: _settings?.themeMode ?? ThemeMode.system,
      locale: Locale(currentLanguage),
      supportedLocales: const [Locale('en'), Locale('id')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Stack(
        children: [
          child ?? const SizedBox.shrink(),
          if (_obscured)
            Positioned.fill(
              key: const Key('privacy-cover'),
              child: ColoredBox(
                color: AppColors.of(context).surfaceBase,
                child: const Center(child: LogoMark()),
              ),
            ),
        ],
      ),
      home: switch (_phase) {
        _Phase.booting => Scaffold(body: Center(child: Text(S.loading))),
        _Phase.onboarding => OnboardingFlow(
            biometrics: _biometrics,
            onComplete: _complete,
            onImport: () => _importAfterSetup = true,
          ),
        _Phase.locked => LockPage(
            vault: _vault!,
            biometrics: _biometrics,
            now: widget.now,
            onUnlocked: (k) => _openWith(Uint8List.fromList(k.bytes)),
          ),
        _Phase.open => TimelinePage(
            repository: _session!.repository,
            files: _files,
            startWithImport: _importThisSession,
            now: widget.now,
            settings: _settings!,
          ),
        _Phase.tooNew => CannotOpenPage(needsUpdate: true, onTryAgain: () {}),
        _Phase.cannotOpen => CannotOpenPage(onTryAgain: () => _openWith(_key!)),
      },
    );
  }
}
