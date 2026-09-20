import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../data/entry_repository.dart';
import '../l10n/strings.dart';
import '../security/biometrics.dart';
import '../security/key_vault.dart';

enum ThemeChoice { system, light, dark }

enum LanguageChoice { system, en, id }

/// The lock timeouts a person can choose (decision `lock-and-passcode-policy`).
const lockTimeoutChoices = <Duration>[
  Duration.zero,
  Duration(minutes: 1),
  Duration(minutes: 5),
  Duration(minutes: 15),
];

enum BiometricsChange { on, off, unavailable, notRecognised }

/// The settings of the app (FEAT-009).
///
/// * Theme and language are not secret and are needed before the journal is
///   open (the lock screen has both), so they live in a small plain file.
/// * The lock timeout changes how safe the journal is, so it lives inside the
///   encrypted journal and cannot be changed from outside.
/// * Face and fingerprint are on when the OS key store holds the biometric copy of the key.
class SettingsController extends ChangeNotifier {
  SettingsController({
    required this.directory,
    required this.vault,
    required this.biometrics,
    required this.phoneLanguage,
    Duration initialLockTimeout = Duration.zero,
  }) : _lockTimeout = initialLockTimeout;

  final Directory directory;
  final KeyVault vault;
  final Biometrics biometrics;

  /// The phone's language code, read when "follow the phone" applies.
  final String Function() phoneLanguage;

  ThemeChoice _theme = ThemeChoice.system;
  LanguageChoice _language = LanguageChoice.system;
  Duration _lockTimeout;
  bool _biometricsOn = false;
  EntryRepository? _repository;
  Uint8List? Function()? _keyOf;

  ThemeChoice get theme => _theme;
  LanguageChoice get language => _language;
  Duration get lockTimeout => _lockTimeout;
  bool get biometricsOn => _biometricsOn;

  ThemeMode get themeMode => switch (_theme) {
        ThemeChoice.system => ThemeMode.system,
        ThemeChoice.light => ThemeMode.light,
        ThemeChoice.dark => ThemeMode.dark,
      };

  /// The code the text is shown in: `en` or `id`.
  String get languageCode => switch (_language) {
        LanguageChoice.system => languageForPhone(phoneLanguage()),
        LanguageChoice.en => 'en',
        LanguageChoice.id => 'id',
      };

  File get _prefsFile => File(p.join(directory.path, 'prefs.json'));

  /// Reads theme and language. Anything unreadable falls back to "follow the phone".
  Future<void> loadPrefs() async {
    try {
      final j = jsonDecode(await _prefsFile.readAsString()) as Map<String, dynamic>;
      _theme = ThemeChoice.values.asNameMap()[j['theme']] ?? ThemeChoice.system;
      _language = LanguageChoice.values.asNameMap()[j['language']] ?? LanguageChoice.system;
    } catch (_) {
      _theme = ThemeChoice.system;
      _language = LanguageChoice.system;
    }
    setLanguage(languageCode);
  }

  Future<void> _savePrefs() async {
    await directory.create(recursive: true);
    final tmp = File('${_prefsFile.path}.tmp');
    await tmp.writeAsString(jsonEncode({'theme': _theme.name, 'language': _language.name}), flush: true);
    await tmp.rename(_prefsFile.path);
  }

  /// Called after every unlock, with the open journal and a way to read the key.
  Future<void> attach(EntryRepository repository, Uint8List? Function() keyOf) async {
    _repository = repository;
    _keyOf = keyOf;
    try {
      final s = await repository.lockTimeoutSeconds();
      if (s != null && lockTimeoutChoices.any((d) => d.inSeconds == s)) _lockTimeout = Duration(seconds: s);
      _biometricsOn = await vault.biometricsEnabled;
    } catch (_) {
      // the journal closed while attaching (the app locked)
    }
    notifyListeners();
  }

  /// Called when the app locks: nothing may point at the closed journal.
  void detach() {
    _repository = null;
    _keyOf = null;
  }

  Future<void> setTheme(ThemeChoice choice) async {
    _theme = choice;
    notifyListeners();
    await _savePrefs();
  }

  Future<void> setLanguageChoice(LanguageChoice choice) async {
    _language = choice;
    setLanguage(languageCode);
    notifyListeners(); // every screen redraws in the new language at once
    await _savePrefs();
  }

  Future<void> setLockTimeout(Duration d) async {
    _lockTimeout = d;
    notifyListeners();
    await _repository?.setLockTimeoutSeconds(d.inSeconds);
  }

  /// Turns the face and fingerprint shortcut on or off. Turning it on asks the
  /// phone to check a face or fingerprint first.
  Future<BiometricsChange> setBiometrics(bool on) async {
    if (!on) {
      await vault.setBiometrics(false);
      _biometricsOn = false;
      notifyListeners();
      return BiometricsChange.off;
    }
    if (!await biometrics.available) return BiometricsChange.unavailable;
    final key = _keyOf?.call();
    if (key == null) return BiometricsChange.unavailable;
    if (!await biometrics.authenticate(S.bioReason)) return BiometricsChange.notRecognised;
    await vault.setBiometrics(true, dataKey: key);
    _biometricsOn = true;
    notifyListeners();
    return BiometricsChange.on;
  }

  Future<ChangePasscodeResult> changePasscode(String current, String next) => vault.changePasscode(current, next);
}
