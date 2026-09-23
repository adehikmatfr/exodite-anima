import '../data/entry_repository.dart' show Mood;

/// Every user-visible string of the app, in English and Indonesian.
///
/// The language is chosen in Settings (follow the phone, English, or
/// Indonesian; English when the phone uses neither). Every string exists in
/// both languages: `test/settings_test.dart` fails when one is missing. The
/// Indonesian text was reviewed and accepted by the owner on 2026-09-23. Do
/// not write text inline in widgets.
String _lang = 'en';

/// The language code in use: `en` or `id`.
String get currentLanguage => _lang;

/// Sets the language for all text (call [notifyLanguageChanged] afterwards so screens redraw).
void setLanguage(String code) => _lang = code == 'id' ? 'id' : 'en';

/// The language to use when the setting is "follow the phone".
String languageForPhone(String phoneLanguageCode) => phoneLanguageCode == 'id' ? 'id' : 'en';

String _t(String en, String id) => _lang == 'id' ? id : en;

class S {
  static String get appTitle => _t('Journal', 'Jurnal');
  static String get emptyTitle => _t('Nothing here yet', 'Belum ada catatan');
  static String get emptyBody => _t('Write your first entry. It stays on this phone.', 'Tulis catatan pertama Anda. Catatan hanya tersimpan di ponsel ini.');
  static String get writeFirst => _t('Write your first entry', 'Tulis catatan pertama');
  static String get newEntry => _t('New entry', 'Catatan baru');
  static String get today => _t('Today', 'Hari ini');
  static String get yesterday => _t('Yesterday', 'Kemarin');
  static String get onThisDayTitle => _t('On this day', 'Pada hari ini');
  static String get loading => _t('Opening your journal...', 'Membuka jurnal Anda...');
  static String get back => _t('Back', 'Kembali');
  static String get save => _t('Save', 'Simpan');
  static String get saveNeedsText => _t('Write something to save', 'Tulis sesuatu untuk menyimpan');
  static String get draftKept => _t('Draft kept safely on this phone', 'Draf tersimpan aman di ponsel ini');
  static String get entryTextLabel => _t('Entry text', 'Isi catatan');
  static String get entryHint => _t('Write what\'s on your mind', 'Tulis apa yang ada di pikiran Anda');
  static String get deleteEntry => _t('Delete entry', 'Hapus catatan');
  static String get cancel => _t('Cancel', 'Batal');
  static String get deleteTitle => _t('Delete this entry?', 'Hapus catatan ini?');
  static String get deleteBody => _t('This cannot be undone. The entry is removed from search and from future exports.', 'Tindakan ini tidak bisa dibatalkan. Catatan dihapus dari pencarian dan dari ekspor berikutnya.');
  static String get resumeTitle => _t('Continue your unsaved entry?', 'Lanjutkan catatan yang belum disimpan?');
  static String get resumeBody => _t('The app closed before you saved. Your text is still here.', 'Aplikasi tertutup sebelum Anda menyimpan. Tulisan Anda masih ada.');
  static String get resumeContinue => _t('Continue writing', 'Lanjut menulis');
  static String get resumeDiscard => _t('Discard draft', 'Buang draf');
  static String get saveErrorTitle => _t('Couldn\'t save your entry', 'Catatan tidak bisa disimpan');
  static String get saveErrorBody => _t('Your text is kept. Free some space on the phone, then try again.', 'Tulisan Anda tetap aman. Kosongkan sedikit ruang di ponsel, lalu coba lagi.');
  static String get tryAgain => _t('Try again', 'Coba lagi');
  static String get important => _t('Important', 'Penting');
  static String get settings => _t('Settings', 'Pengaturan');
  static String get backupSection => _t('Backup', 'Cadangan');
  static String get exportRow => _t('Export your journal', 'Ekspor jurnal Anda');
  static String get importRow => _t('Import your journal', 'Impor jurnal Anda');
  static String get neverExported => _t('Not exported yet', 'Belum pernah diekspor');
  static String get exportBody => _t('Save a copy of everything you have written. You can bring it back on this phone or a new one.', 'Simpan salinan semua yang sudah Anda tulis. Anda bisa memulihkannya di ponsel ini atau di ponsel baru.');
  static String get exportProtected => _t('Protected with a password', 'Dilindungi kata sandi');
  static String get exportProtectedNote => _t('Recommended. Only someone with the password can open it.', 'Disarankan. Hanya orang yang tahu kata sandinya yang bisa membukanya.');
  static String get exportPlain => _t('Readable by anyone', 'Bisa dibaca siapa saja');
  static String get exportPlainNote => _t('Not protected. Anyone who gets the file can read your entries.', 'Tidak dilindungi. Siapa pun yang mendapat file ini bisa membaca catatan Anda.');
  static String get exportPasswordTitle => _t('Choose an export password', 'Pilih kata sandi ekspor');
  static String get exportPasswordBody => _t('This is not your passcode. You need it to open the export, and it cannot be recovered.', 'Ini bukan kode sandi aplikasi. Anda memerlukannya untuk membuka ekspor, dan tidak bisa dipulihkan.');
  static String get exportPasswordLabel => _t('Export password', 'Kata sandi ekspor');
  static String get exportPasswordHint => _t('Choose an export password', 'Pilih kata sandi ekspor');
  static String get exportPasswordHelper => _t('Use at least 8 characters. Keep it somewhere safe, apart from the file.', 'Gunakan minimal 8 karakter. Simpan di tempat yang aman, terpisah dari file.');
  static String get exportPasswordTooShort => _t('Use at least 8 characters.', 'Gunakan minimal 8 karakter.');
  static String get exportButton => _t('Export', 'Ekspor');
  static String get warnPlainTitle => _t('Anyone who gets this file can read your journal.', 'Siapa pun yang mendapat file ini bisa membaca jurnal Anda.');
  static String get warnPlainBody => _t('Only choose this if you will keep the file somewhere safe. You can still choose a password instead.', 'Pilih ini hanya jika Anda akan menyimpan file di tempat yang aman. Anda masih bisa memilih kata sandi.');
  static String get exportWithoutProtection => _t('Export without protection', 'Ekspor tanpa perlindungan');
  static String get goBack => _t('Go back', 'Kembali');
  static String get exportWorkingTitle => _t('Preparing your export', 'Menyiapkan ekspor Anda');
  static String get exportWorkingBody => _t('Keep the app open. This can take a moment for a large journal.', 'Biarkan aplikasi tetap terbuka. Jurnal yang besar bisa memerlukan waktu.');
  static String get exportDoneTitle => _t('Your export is ready', 'Ekspor Anda siap');
  static String get exportDoneBody => _t('Choose where to save it on the next screen.', 'Pilih tempat menyimpannya di layar berikutnya.');
  static String get keepPasswordTitle => _t('Keep your export password', 'Simpan kata sandi ekspor Anda');
  static String get keepPasswordBody => _t('Without it the file cannot be opened.', 'Tanpa kata sandi itu, file tidak bisa dibuka.');
  static String get done => _t('Done', 'Selesai');
  static String get exportErrorTitle => _t('The export could not be saved', 'Ekspor tidak bisa disimpan');
  static String get exportErrorBody => _t('Your phone may be low on space. Nothing was changed. Free some space and try again.', 'Ruang di ponsel Anda mungkin hampir penuh. Tidak ada yang diubah. Kosongkan sedikit ruang lalu coba lagi.');
  static String get exportNotSaved => _t('The export was not saved. Nothing was changed.', 'Ekspor tidak disimpan. Tidak ada yang diubah.');
  static String get importTitle => _t('Import your journal', 'Impor jurnal Anda');
  static String get importBody => _t('Choose an export made by this app. Entries already on this phone are kept.', 'Pilih ekspor yang dibuat oleh aplikasi ini. Catatan yang sudah ada di ponsel ini tetap dipertahankan.');
  static String get chooseFile => _t('Choose a file', 'Pilih file');
  static String get chooseAnotherFile => _t('Choose another file', 'Pilih file lain');
  static String get importPasswordTitle => _t('Enter the export password', 'Masukkan kata sandi ekspor');
  static String get importPasswordBody => _t('This export is protected. Use the password you chose when you made it.', 'Ekspor ini dilindungi. Gunakan kata sandi yang Anda pilih saat membuatnya.');
  static String get importButton => _t('Import', 'Impor');
  static String get importWrongPassword => _t('That password does not open this export. Nothing was changed.', 'Kata sandi itu tidak bisa membuka ekspor ini. Tidak ada yang diubah.');
  static String get importWorkingTitle => _t('Importing your journal', 'Mengimpor jurnal Anda');
  static String get importWorkingBody => _t('Keep the app open. Your journal only changes when everything is ready.', 'Biarkan aplikasi tetap terbuka. Jurnal Anda baru berubah setelah semuanya siap.');
  static String get importDoneTitle => _t('Your journal is back', 'Jurnal Anda kembali');
  static String get openMyJournal => _t('Open my journal', 'Buka jurnal saya');
  static String get importDamagedTitle => _t('This file is damaged', 'File ini rusak');
  static String get importDamagedBody => _t('It could not be read, so nothing was imported. Try another export.', 'File tidak bisa dibaca, jadi tidak ada yang diimpor. Coba ekspor yang lain.');
  static String get importNewerTitle => _t('This export needs a newer version of the app', 'Ekspor ini memerlukan versi aplikasi yang lebih baru');
  static String get importNewerBody => _t('Update the app, then try again. Nothing was changed.', 'Perbarui aplikasi, lalu coba lagi. Tidak ada yang diubah.');
  static String get importWrongFileTitle => _t('This is not an export from this app', 'Ini bukan ekspor dari aplikasi ini');
  static String get importWrongFileBody => _t('Choose the file you saved when you exported your journal.', 'Pilih file yang Anda simpan saat mengekspor jurnal.');
  static String get importTooLargeTitle => _t('This file is too large to import', 'File ini terlalu besar untuk diimpor');
  static String get importTooLargeBody => _t('It is bigger than the app can import safely. Nothing was changed.', 'Ukurannya lebih besar dari yang bisa diimpor aplikasi dengan aman. Tidak ada yang diubah.');
  static String get importFailedTitle => _t('The import could not finish', 'Impor tidak bisa diselesaikan');
  static String get importFailedBody => _t('Nothing was changed. Free some space if the phone is full, then try again.', 'Tidak ada yang diubah. Kosongkan ruang jika ponsel penuh, lalu coba lagi.');
  static String get reminderNeverTitle => _t('Your journal has not been exported yet', 'Jurnal Anda belum pernah diekspor');
  static String get reminderOverdueTitle => _t('Your last export is more than 30 days old', 'Ekspor terakhir Anda sudah lebih dari 30 hari');
  static String get reminderBody => _t('Export it so a lost phone doesn\'t mean lost memories.', 'Ekspor agar ponsel yang hilang tidak berarti kenangan yang hilang.');
  static String get reminderExportNow => _t('Export now', 'Ekspor sekarang');
  static String get reminderLater => _t('Later', 'Nanti');
  static String get searchLabel => _t('Search your entries', 'Cari catatan Anda');
  static String get searchHint => _t('Search your entries', 'Cari catatan Anda');
  static String get clearSearch => _t('Clear search', 'Hapus pencarian');
  static String get typeAWord => _t('Type a word you remember.', 'Ketik kata yang Anda ingat.');
  static String get tryAnotherWord => _t('Try another word, or part of a word.', 'Coba kata lain, atau sebagian dari kata.');
  static String get cannotOpenTitle => _t('Your journal cannot be opened', 'Jurnal Anda tidak bisa dibuka');
  static String get cannotOpenBody => _t('Nothing has been deleted. Your entries are still stored on this phone. Try again, or restore from an export file.', 'Tidak ada yang dihapus. Catatan Anda masih tersimpan di ponsel ini. Coba lagi, atau pulihkan dari file ekspor.');
  static String get importJournal => _t('Import your journal', 'Impor jurnal Anda');
  static String get importSoon => _t('Import is not available in this version yet.', 'Impor belum tersedia di versi ini.');
  static String get tooNewTitle => _t('Please update the app', 'Mohon perbarui aplikasi');
  static String get tooNewBody => _t('Your journal was saved by a newer version of this app. This version will not change it. Update the app to open it.', 'Jurnal Anda disimpan oleh versi aplikasi yang lebih baru. Versi ini tidak akan mengubahnya. Perbarui aplikasi untuk membukanya.');
  static String get welcomeTitle => _t('A journal only you can read', 'Jurnal yang hanya bisa Anda baca');
  static String get welcomeBody => _t('Everything you write stays on this phone. Nothing is uploaded, ever.', 'Semua yang Anda tulis tetap di ponsel ini. Tidak ada yang pernah diunggah.');
  static String get welcomePoint1 => _t('No account or sign-up', 'Tanpa akun atau pendaftaran');
  static String get welcomePoint2 => _t('No ads, no tracking', 'Tanpa iklan, tanpa pelacakan');
  static String get welcomePoint3 => _t('Free, for good', 'Gratis, selamanya');
  static String get getStarted => _t('Get started', 'Mulai');
  static String get passcodeTitle => _t('Create a passcode', 'Buat kode sandi');
  static String get passcodeBody => _t('You\'ll use it to open your journal when your face or fingerprint isn\'t available.', 'Anda akan memakainya untuk membuka jurnal ketika wajah atau sidik jari tidak tersedia.');
  static String get passcodeLabel => _t('Passcode', 'Kode sandi');
  static String get passcodeHint => _t('Choose a passcode', 'Pilih kode sandi');
  static String get repeatLabel => _t('Repeat passcode', 'Ulangi kode sandi');
  static String get repeatHint => _t('Type it again', 'Ketik sekali lagi');
  static String get passcodeHelper => _t('Use at least 8 characters. Choose something you will remember. It cannot be recovered.', 'Gunakan minimal 8 karakter. Pilih sesuatu yang akan Anda ingat. Kode sandi tidak bisa dipulihkan.');
  static String get passcodeTooShort => _t('Use at least 8 characters.', 'Gunakan minimal 8 karakter.');
  static String get passcodeTooCommon => _t('This passcode is too easy to guess. Try a longer or less common one.', 'Kode sandi ini terlalu mudah ditebak. Coba yang lebih panjang atau lebih jarang dipakai.');
  static String get passcodeMismatch => _t('The two passcodes are different. Type them again.', 'Kedua kode sandi berbeda. Ketik ulang.');
  static String get passcodeNeeded => _t('Enter and repeat your passcode to continue.', 'Masukkan dan ulangi kode sandi untuk melanjutkan.');
  static String get showPasscode => _t('Show passcode', 'Tampilkan kode sandi');
  static String get hidePasscode => _t('Hide passcode', 'Sembunyikan kode sandi');
  static String get show => _t('Show', 'Tampilkan');
  static String get hide => _t('Hide', 'Sembunyikan');
  static String get continueLabel => _t('Continue', 'Lanjut');
  static String get bioTitle => _t('Open it with a glance or a touch', 'Buka dengan sekali lihat atau sentuh');
  static String get bioBody => _t('Use your face or fingerprint for quick access. Your passcode always works as a backup.', 'Gunakan wajah atau sidik jari untuk akses cepat. Kode sandi Anda selalu bisa dipakai sebagai cadangan.');
  static String get bioTurnOn => _t('Turn on', 'Aktifkan');
  static String get bioNotNow => _t('Not now', 'Nanti saja');
  static String get bioMissingTitle => _t('Face and fingerprint are not set up on this phone', 'Wajah dan sidik jari belum diatur di ponsel ini');
  static String get bioMissingBody => _t('You can still open your journal with your passcode. If you set up a face or fingerprint on your phone later, you can turn it on in Settings.', 'Anda tetap bisa membuka jurnal dengan kode sandi. Jika nanti Anda mengatur wajah atau sidik jari di ponsel, Anda bisa mengaktifkannya di Pengaturan.');
  static String get bioReason => _t('Open your journal', 'Buka jurnal Anda');
  static String get warnTitle => _t('If you forget your passcode, your journal is gone', 'Jika Anda lupa kode sandi, jurnal Anda hilang');
  static String get warnBody1 => _t('Nobody can reset your passcode, including us. We never have your data.', 'Tidak ada yang bisa mereset kode sandi Anda, termasuk kami. Kami tidak pernah memegang data Anda.');
  static String get warnBody2 => _t('Export your journal from time to time to keep a backup you control.', 'Ekspor jurnal Anda sesekali untuk menyimpan cadangan yang Anda kendalikan.');
  static String get warnCheck => _t('I understand that a forgotten passcode can\'t be recovered', 'Saya mengerti bahwa kode sandi tidak bisa dipulihkan jika terlupa');
  static String get warnNeeded => _t('Tick the box to continue.', 'Centang kotak untuk melanjutkan.');
  static String get startJournaling => _t('Start journaling', 'Mulai menulis');
  static String get settingUp => _t('Setting up...', 'Menyiapkan...');
  static String get lockTitle => _t('Enter your passcode', 'Masukkan kode sandi Anda');
  static String get lockHint => _t('Your passcode', 'Kode sandi Anda');
  static String get unlock => _t('Unlock', 'Buka kunci');
  static String get useBiometrics => _t('Use face or fingerprint', 'Gunakan wajah atau sidik jari');
  static String get wrongPasscode => _t('That passcode is not right. Try again.', 'Kode sandi itu salah. Coba lagi.');
  static String get unlocking => _t('Unlocking...', 'Membuka kunci...');
  static String get vaultDamagedTitle => _t('Your journal key could not be read', 'Kunci jurnal Anda tidak bisa dibaca');
  static String get vaultDamagedBody => _t('Nothing has been deleted. Try again. If it keeps happening, restore from an export file.', 'Tidak ada yang dihapus. Coba lagi. Jika terus terjadi, pulihkan dari file ekspor.');

  // Settings, change passcode, about (FEAT-009)
  static String get appearance => _t('Appearance', 'Tampilan');
  static String get theme => _t('Theme', 'Tema');
  static String get themeSystem => _t('Match phone', 'Ikuti ponsel');
  static String get themeLight => _t('Light', 'Terang');
  static String get themeDark => _t('Dark', 'Gelap');
  static String get language => _t('Language', 'Bahasa');
  static String get languageSystem => _t('Match phone', 'Ikuti ponsel');
  static String get languageSystemNote => _t('Uses English unless your phone is set to Indonesian', 'Memakai bahasa Inggris kecuali ponsel Anda diatur ke bahasa Indonesia');
  static String get languageEnglish => _t('English', 'English');
  static String get languageIndonesian => _t('Bahasa Indonesia', 'Bahasa Indonesia');
  static String get securitySection => _t('Security', 'Keamanan');
  static String get changePasscode => _t('Change passcode', 'Ganti kode sandi');
  static String get biometricsRow => _t('Face or fingerprint', 'Wajah atau sidik jari');
  static String get on => _t('On', 'Aktif');
  static String get off => _t('Off', 'Mati');
  static String get biometricsUnavailable => _t('Face and fingerprint are not set up on this phone.', 'Wajah dan sidik jari belum diatur di ponsel ini.');
  static String get biometricsFailed => _t('Face or fingerprint was not recognised, so it stays off.', 'Wajah atau sidik jari tidak dikenali, jadi tetap mati.');
  static String get lockTimeoutRow => _t('Lock when I leave the app', 'Kunci saat saya meninggalkan aplikasi');
  static String get timeoutImmediately => _t('Immediately', 'Segera');
  static String get timeoutRecommended => _t('Recommended', 'Disarankan');
  static String get timeout1 => _t('After 1 minute', 'Setelah 1 menit');
  static String get timeout5 => _t('After 5 minutes', 'Setelah 5 menit');
  static String get timeout15 => _t('After 15 minutes', 'Setelah 15 menit');
  static String get aboutSection => _t('About', 'Tentang');
  static String get aboutRow => _t('About and privacy', 'Tentang dan privasi');
  static String get aboutTitle => _t('Your journal stays on this phone', 'Jurnal Anda tetap di ponsel ini');
  static String get aboutPoint1 => _t('Nothing you write is uploaded or shared by the app.', 'Tidak ada tulisan Anda yang diunggah atau dibagikan oleh aplikasi.');
  static String get aboutPoint2 => _t('There is no account, no ads, and no tracking.', 'Tidak ada akun, tidak ada iklan, dan tidak ada pelacakan.');
  static String get aboutPoint3 => _t('The only way your writing leaves this phone is an export you choose to make.', 'Satu-satunya cara tulisan Anda keluar dari ponsel ini adalah ekspor yang Anda pilih sendiri.');
  static String get aboutPoint4 => _t('If you forget your passcode, your journal cannot be recovered.', 'Jika Anda lupa kode sandi, jurnal Anda tidak bisa dipulihkan.');
  static String get currentPasscode => _t('Current passcode', 'Kode sandi saat ini');
  static String get currentPasscodeHint => _t('Your current passcode', 'Kode sandi Anda saat ini');
  static String get newPasscode => _t('New passcode', 'Kode sandi baru');
  static String get newPasscodeHint => _t('Choose a new passcode', 'Pilih kode sandi baru');
  static String get repeatNewPasscode => _t('Repeat new passcode', 'Ulangi kode sandi baru');
  static String get currentPasscodeWrong => _t('That is not your current passcode.', 'Itu bukan kode sandi Anda saat ini.');
  static String get changePasscodeButton => _t('Change passcode', 'Ganti kode sandi');
  static String get passcodeChangedTitle => _t('Passcode changed', 'Kode sandi diganti');
  static String get passcodeChangedBody => _t('Your journal opens with the new passcode from now on. Your entries are unchanged.', 'Mulai sekarang jurnal Anda terbuka dengan kode sandi baru. Catatan Anda tidak berubah.');
  static String get passcodeChangeFailed => _t('The passcode could not be changed. Nothing was changed. Try again.', 'Kode sandi tidak bisa diganti. Tidak ada yang diubah. Coba lagi.');
  static String get chooseLanguageTitle => _t('Language', 'Bahasa');
  static String get addTag => _t('Add a tag', 'Tambah tag');
  static String get addTagHint => _t('Type a tag and press done', 'Ketik tag lalu tekan selesai');
  static String get clearMood => _t('Clear mood', 'Hapus mood');

  // Photos (FEAT-011)
  static String get addPhoto => _t('Add photo', 'Tambah foto');
  static String get takePhoto => _t('Take a photo', 'Ambil foto');
  static String get chooseFromLibrary => _t('Choose from library', 'Pilih dari galeri');
  static String get photoGenericLabel => _t('Photo', 'Foto');
  static String get addCaptionHint => _t('Add a caption (optional)', 'Tambah keterangan (opsional)');
  static String get removePhotoAction => _t('Remove', 'Hapus');
  static String get removePhotoTitle => _t('Remove this photo?', 'Hapus foto ini?');
  static String get removePhotoBody => _t('This cannot be undone. The photo is removed from this entry.', 'Tindakan ini tidak bisa dibatalkan. Foto dihapus dari catatan ini.');
  static String get photoAddFailedTitle => _t('Couldn\'t add that photo', 'Foto tidak bisa ditambahkan');
  static String get photoAddFailedBody => _t('Free some space on the phone, then try again.', 'Kosongkan sedikit ruang di ponsel, lalu coba lagi.');
  static String get photoOpenFailedTitle => _t('This photo can\'t be opened', 'Foto ini tidak bisa dibuka');
  static String get photoOpenFailedBody => _t('It may be damaged. Everything else in this entry is unaffected.', 'Foto ini mungkin rusak. Bagian lain dari catatan ini tidak terpengaruh.');

  // Text with a value in it
  static String entryDateLabel(String date) => _lang == 'id' ? 'Tanggal catatan, $date, ubah' : 'Entry date, $date, change';
  static String lastExport(String when) => _lang == 'id' ? 'Ekspor terakhir: $when' : 'Last export: $when';
  static String entryCount(int n) => _lang == 'id' ? '$n catatan' : n == 1 ? '1 entry' : '$n entries';
  static String importDoneBody(int added, int skipped) => _lang == 'id' ? '$added catatan ditambahkan. $skipped catatan sudah ada di ponsel ini.' : '${entryCount(added)} added. ${skipped == 1 ? '1 was' : '$skipped were'} already on this phone.';
  static String noResults(String q) => _lang == 'id' ? 'Tidak ada catatan yang memuat "$q".' : 'No entries contain "$q".';
  static String matched(String word) => _lang == 'id' ? 'cocok: $word' : 'matched: $word';
  static String waitMessage(String time) => _lang == 'id' ? 'Terlalu banyak percobaan. Anda bisa mencoba lagi dalam $time.' : 'Too many tries. You can try again in $time.';
  static String onThisDayItemLabel(String date) => _lang == 'id' ? 'Pada hari ini, $date' : 'On this day, $date';

  /// FEAT-010's mood scale. The stored value is [Mood.index]; only the label
  /// shown to the person is translated.
  static String moodLabel(Mood mood) => switch (mood) {
        Mood.great => _t('Great', 'Luar biasa'),
        Mood.good => _t('Good', 'Baik'),
        Mood.okay => _t('Okay', 'Biasa'),
        Mood.bad => _t('Bad', 'Buruk'),
        Mood.awful => _t('Awful', 'Sangat buruk'),
      };

  /// A preset tag's display label. [key] must be one of [presetTags]; the
  /// stored and exported value is always the English key, never this label.
  static String presetTagLabel(String key) => switch (key) {
        'Work' => _t('Work', 'Kerja'),
        'Family' => _t('Family', 'Keluarga'),
        'Relationships' => _t('Relationships', 'Hubungan'),
        'Health' => _t('Health', 'Kesehatan'),
        'Travel' => _t('Travel', 'Perjalanan'),
        'Gratitude' => _t('Gratitude', 'Syukur'),
        'Goals' => _t('Goals', 'Tujuan'),
        'Reflection' => _t('Reflection', 'Refleksi'),
        _ => key, // a free-text tag: shown exactly as typed, never translated
      };
}

const _daysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _daysId = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _monthsId = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// "Sat, 20 Sep 2026" (or "Sab, 20 Sep 2026") from a `yyyy-MM-dd` day.
String formatDay(String day) {
  final d = DateTime.parse(day);
  final days = _lang == 'id' ? _daysId : _daysEn;
  final months = _lang == 'id' ? _monthsId : _monthsEn;
  return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
}

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Every string name with both texts, for the completeness test.
List<(String, String, String)> allStringsForTest() => [
  ('appTitle', 'Journal', 'Jurnal'),
  ('emptyTitle', 'Nothing here yet', 'Belum ada catatan'),
  ('emptyBody', 'Write your first entry. It stays on this phone.', 'Tulis catatan pertama Anda. Catatan hanya tersimpan di ponsel ini.'),
  ('writeFirst', 'Write your first entry', 'Tulis catatan pertama'),
  ('newEntry', 'New entry', 'Catatan baru'),
  ('today', 'Today', 'Hari ini'),
  ('yesterday', 'Yesterday', 'Kemarin'),
  ('onThisDayTitle', 'On this day', 'Pada hari ini'),
  ('loading', 'Opening your journal...', 'Membuka jurnal Anda...'),
  ('back', 'Back', 'Kembali'),
  ('save', 'Save', 'Simpan'),
  ('saveNeedsText', 'Write something to save', 'Tulis sesuatu untuk menyimpan'),
  ('draftKept', 'Draft kept safely on this phone', 'Draf tersimpan aman di ponsel ini'),
  ('entryTextLabel', 'Entry text', 'Isi catatan'),
  ('entryHint', 'Write what\'s on your mind', 'Tulis apa yang ada di pikiran Anda'),
  ('deleteEntry', 'Delete entry', 'Hapus catatan'),
  ('cancel', 'Cancel', 'Batal'),
  ('deleteTitle', 'Delete this entry?', 'Hapus catatan ini?'),
  ('deleteBody', 'This cannot be undone. The entry is removed from search and from future exports.', 'Tindakan ini tidak bisa dibatalkan. Catatan dihapus dari pencarian dan dari ekspor berikutnya.'),
  ('resumeTitle', 'Continue your unsaved entry?', 'Lanjutkan catatan yang belum disimpan?'),
  ('resumeBody', 'The app closed before you saved. Your text is still here.', 'Aplikasi tertutup sebelum Anda menyimpan. Tulisan Anda masih ada.'),
  ('resumeContinue', 'Continue writing', 'Lanjut menulis'),
  ('resumeDiscard', 'Discard draft', 'Buang draf'),
  ('saveErrorTitle', 'Couldn\'t save your entry', 'Catatan tidak bisa disimpan'),
  ('saveErrorBody', 'Your text is kept. Free some space on the phone, then try again.', 'Tulisan Anda tetap aman. Kosongkan sedikit ruang di ponsel, lalu coba lagi.'),
  ('tryAgain', 'Try again', 'Coba lagi'),
  ('important', 'Important', 'Penting'),
  ('settings', 'Settings', 'Pengaturan'),
  ('backupSection', 'Backup', 'Cadangan'),
  ('exportRow', 'Export your journal', 'Ekspor jurnal Anda'),
  ('importRow', 'Import your journal', 'Impor jurnal Anda'),
  ('neverExported', 'Not exported yet', 'Belum pernah diekspor'),
  ('exportBody', 'Save a copy of everything you have written. You can bring it back on this phone or a new one.', 'Simpan salinan semua yang sudah Anda tulis. Anda bisa memulihkannya di ponsel ini atau di ponsel baru.'),
  ('exportProtected', 'Protected with a password', 'Dilindungi kata sandi'),
  ('exportProtectedNote', 'Recommended. Only someone with the password can open it.', 'Disarankan. Hanya orang yang tahu kata sandinya yang bisa membukanya.'),
  ('exportPlain', 'Readable by anyone', 'Bisa dibaca siapa saja'),
  ('exportPlainNote', 'Not protected. Anyone who gets the file can read your entries.', 'Tidak dilindungi. Siapa pun yang mendapat file ini bisa membaca catatan Anda.'),
  ('exportPasswordTitle', 'Choose an export password', 'Pilih kata sandi ekspor'),
  ('exportPasswordBody', 'This is not your passcode. You need it to open the export, and it cannot be recovered.', 'Ini bukan kode sandi aplikasi. Anda memerlukannya untuk membuka ekspor, dan tidak bisa dipulihkan.'),
  ('exportPasswordLabel', 'Export password', 'Kata sandi ekspor'),
  ('exportPasswordHint', 'Choose an export password', 'Pilih kata sandi ekspor'),
  ('exportPasswordHelper', 'Use at least 8 characters. Keep it somewhere safe, apart from the file.', 'Gunakan minimal 8 karakter. Simpan di tempat yang aman, terpisah dari file.'),
  ('exportPasswordTooShort', 'Use at least 8 characters.', 'Gunakan minimal 8 karakter.'),
  ('exportButton', 'Export', 'Ekspor'),
  ('warnPlainTitle', 'Anyone who gets this file can read your journal.', 'Siapa pun yang mendapat file ini bisa membaca jurnal Anda.'),
  ('warnPlainBody', 'Only choose this if you will keep the file somewhere safe. You can still choose a password instead.', 'Pilih ini hanya jika Anda akan menyimpan file di tempat yang aman. Anda masih bisa memilih kata sandi.'),
  ('exportWithoutProtection', 'Export without protection', 'Ekspor tanpa perlindungan'),
  ('goBack', 'Go back', 'Kembali'),
  ('exportWorkingTitle', 'Preparing your export', 'Menyiapkan ekspor Anda'),
  ('exportWorkingBody', 'Keep the app open. This can take a moment for a large journal.', 'Biarkan aplikasi tetap terbuka. Jurnal yang besar bisa memerlukan waktu.'),
  ('exportDoneTitle', 'Your export is ready', 'Ekspor Anda siap'),
  ('exportDoneBody', 'Choose where to save it on the next screen.', 'Pilih tempat menyimpannya di layar berikutnya.'),
  ('keepPasswordTitle', 'Keep your export password', 'Simpan kata sandi ekspor Anda'),
  ('keepPasswordBody', 'Without it the file cannot be opened.', 'Tanpa kata sandi itu, file tidak bisa dibuka.'),
  ('done', 'Done', 'Selesai'),
  ('exportErrorTitle', 'The export could not be saved', 'Ekspor tidak bisa disimpan'),
  ('exportErrorBody', 'Your phone may be low on space. Nothing was changed. Free some space and try again.', 'Ruang di ponsel Anda mungkin hampir penuh. Tidak ada yang diubah. Kosongkan sedikit ruang lalu coba lagi.'),
  ('exportNotSaved', 'The export was not saved. Nothing was changed.', 'Ekspor tidak disimpan. Tidak ada yang diubah.'),
  ('importTitle', 'Import your journal', 'Impor jurnal Anda'),
  ('importBody', 'Choose an export made by this app. Entries already on this phone are kept.', 'Pilih ekspor yang dibuat oleh aplikasi ini. Catatan yang sudah ada di ponsel ini tetap dipertahankan.'),
  ('chooseFile', 'Choose a file', 'Pilih file'),
  ('chooseAnotherFile', 'Choose another file', 'Pilih file lain'),
  ('importPasswordTitle', 'Enter the export password', 'Masukkan kata sandi ekspor'),
  ('importPasswordBody', 'This export is protected. Use the password you chose when you made it.', 'Ekspor ini dilindungi. Gunakan kata sandi yang Anda pilih saat membuatnya.'),
  ('importButton', 'Import', 'Impor'),
  ('importWrongPassword', 'That password does not open this export. Nothing was changed.', 'Kata sandi itu tidak bisa membuka ekspor ini. Tidak ada yang diubah.'),
  ('importWorkingTitle', 'Importing your journal', 'Mengimpor jurnal Anda'),
  ('importWorkingBody', 'Keep the app open. Your journal only changes when everything is ready.', 'Biarkan aplikasi tetap terbuka. Jurnal Anda baru berubah setelah semuanya siap.'),
  ('importDoneTitle', 'Your journal is back', 'Jurnal Anda kembali'),
  ('openMyJournal', 'Open my journal', 'Buka jurnal saya'),
  ('importDamagedTitle', 'This file is damaged', 'File ini rusak'),
  ('importDamagedBody', 'It could not be read, so nothing was imported. Try another export.', 'File tidak bisa dibaca, jadi tidak ada yang diimpor. Coba ekspor yang lain.'),
  ('importNewerTitle', 'This export needs a newer version of the app', 'Ekspor ini memerlukan versi aplikasi yang lebih baru'),
  ('importNewerBody', 'Update the app, then try again. Nothing was changed.', 'Perbarui aplikasi, lalu coba lagi. Tidak ada yang diubah.'),
  ('importWrongFileTitle', 'This is not an export from this app', 'Ini bukan ekspor dari aplikasi ini'),
  ('importWrongFileBody', 'Choose the file you saved when you exported your journal.', 'Pilih file yang Anda simpan saat mengekspor jurnal.'),
  ('importTooLargeTitle', 'This file is too large to import', 'File ini terlalu besar untuk diimpor'),
  ('importTooLargeBody', 'It is bigger than the app can import safely. Nothing was changed.', 'Ukurannya lebih besar dari yang bisa diimpor aplikasi dengan aman. Tidak ada yang diubah.'),
  ('importFailedTitle', 'The import could not finish', 'Impor tidak bisa diselesaikan'),
  ('importFailedBody', 'Nothing was changed. Free some space if the phone is full, then try again.', 'Tidak ada yang diubah. Kosongkan ruang jika ponsel penuh, lalu coba lagi.'),
  ('reminderNeverTitle', 'Your journal has not been exported yet', 'Jurnal Anda belum pernah diekspor'),
  ('reminderOverdueTitle', 'Your last export is more than 30 days old', 'Ekspor terakhir Anda sudah lebih dari 30 hari'),
  ('reminderBody', 'Export it so a lost phone doesn\'t mean lost memories.', 'Ekspor agar ponsel yang hilang tidak berarti kenangan yang hilang.'),
  ('reminderExportNow', 'Export now', 'Ekspor sekarang'),
  ('reminderLater', 'Later', 'Nanti'),
  ('searchLabel', 'Search your entries', 'Cari catatan Anda'),
  ('searchHint', 'Search your entries', 'Cari catatan Anda'),
  ('clearSearch', 'Clear search', 'Hapus pencarian'),
  ('typeAWord', 'Type a word you remember.', 'Ketik kata yang Anda ingat.'),
  ('tryAnotherWord', 'Try another word, or part of a word.', 'Coba kata lain, atau sebagian dari kata.'),
  ('cannotOpenTitle', 'Your journal cannot be opened', 'Jurnal Anda tidak bisa dibuka'),
  ('cannotOpenBody', 'Nothing has been deleted. Your entries are still stored on this phone. Try again, or restore from an export file.', 'Tidak ada yang dihapus. Catatan Anda masih tersimpan di ponsel ini. Coba lagi, atau pulihkan dari file ekspor.'),
  ('importJournal', 'Import your journal', 'Impor jurnal Anda'),
  ('importSoon', 'Import is not available in this version yet.', 'Impor belum tersedia di versi ini.'),
  ('tooNewTitle', 'Please update the app', 'Mohon perbarui aplikasi'),
  ('tooNewBody', 'Your journal was saved by a newer version of this app. This version will not change it. Update the app to open it.', 'Jurnal Anda disimpan oleh versi aplikasi yang lebih baru. Versi ini tidak akan mengubahnya. Perbarui aplikasi untuk membukanya.'),
  ('welcomeTitle', 'A journal only you can read', 'Jurnal yang hanya bisa Anda baca'),
  ('welcomeBody', 'Everything you write stays on this phone. Nothing is uploaded, ever.', 'Semua yang Anda tulis tetap di ponsel ini. Tidak ada yang pernah diunggah.'),
  ('welcomePoint1', 'No account or sign-up', 'Tanpa akun atau pendaftaran'),
  ('welcomePoint2', 'No ads, no tracking', 'Tanpa iklan, tanpa pelacakan'),
  ('welcomePoint3', 'Free, for good', 'Gratis, selamanya'),
  ('getStarted', 'Get started', 'Mulai'),
  ('passcodeTitle', 'Create a passcode', 'Buat kode sandi'),
  ('passcodeBody', 'You\'ll use it to open your journal when your face or fingerprint isn\'t available.', 'Anda akan memakainya untuk membuka jurnal ketika wajah atau sidik jari tidak tersedia.'),
  ('passcodeLabel', 'Passcode', 'Kode sandi'),
  ('passcodeHint', 'Choose a passcode', 'Pilih kode sandi'),
  ('repeatLabel', 'Repeat passcode', 'Ulangi kode sandi'),
  ('repeatHint', 'Type it again', 'Ketik sekali lagi'),
  ('passcodeHelper', 'Use at least 8 characters. Choose something you will remember. It cannot be recovered.', 'Gunakan minimal 8 karakter. Pilih sesuatu yang akan Anda ingat. Kode sandi tidak bisa dipulihkan.'),
  ('passcodeTooShort', 'Use at least 8 characters.', 'Gunakan minimal 8 karakter.'),
  ('passcodeTooCommon', 'This passcode is too easy to guess. Try a longer or less common one.', 'Kode sandi ini terlalu mudah ditebak. Coba yang lebih panjang atau lebih jarang dipakai.'),
  ('passcodeMismatch', 'The two passcodes are different. Type them again.', 'Kedua kode sandi berbeda. Ketik ulang.'),
  ('passcodeNeeded', 'Enter and repeat your passcode to continue.', 'Masukkan dan ulangi kode sandi untuk melanjutkan.'),
  ('showPasscode', 'Show passcode', 'Tampilkan kode sandi'),
  ('hidePasscode', 'Hide passcode', 'Sembunyikan kode sandi'),
  ('show', 'Show', 'Tampilkan'),
  ('hide', 'Hide', 'Sembunyikan'),
  ('continueLabel', 'Continue', 'Lanjut'),
  ('bioTitle', 'Open it with a glance or a touch', 'Buka dengan sekali lihat atau sentuh'),
  ('bioBody', 'Use your face or fingerprint for quick access. Your passcode always works as a backup.', 'Gunakan wajah atau sidik jari untuk akses cepat. Kode sandi Anda selalu bisa dipakai sebagai cadangan.'),
  ('bioTurnOn', 'Turn on', 'Aktifkan'),
  ('bioNotNow', 'Not now', 'Nanti saja'),
  ('bioMissingTitle', 'Face and fingerprint are not set up on this phone', 'Wajah dan sidik jari belum diatur di ponsel ini'),
  ('bioMissingBody', 'You can still open your journal with your passcode. If you set up a face or fingerprint on your phone later, you can turn it on in Settings.', 'Anda tetap bisa membuka jurnal dengan kode sandi. Jika nanti Anda mengatur wajah atau sidik jari di ponsel, Anda bisa mengaktifkannya di Pengaturan.'),
  ('bioReason', 'Open your journal', 'Buka jurnal Anda'),
  ('warnTitle', 'If you forget your passcode, your journal is gone', 'Jika Anda lupa kode sandi, jurnal Anda hilang'),
  ('warnBody1', 'Nobody can reset your passcode, including us. We never have your data.', 'Tidak ada yang bisa mereset kode sandi Anda, termasuk kami. Kami tidak pernah memegang data Anda.'),
  ('warnBody2', 'Export your journal from time to time to keep a backup you control.', 'Ekspor jurnal Anda sesekali untuk menyimpan cadangan yang Anda kendalikan.'),
  ('warnCheck', 'I understand that a forgotten passcode can\'t be recovered', 'Saya mengerti bahwa kode sandi tidak bisa dipulihkan jika terlupa'),
  ('warnNeeded', 'Tick the box to continue.', 'Centang kotak untuk melanjutkan.'),
  ('startJournaling', 'Start journaling', 'Mulai menulis'),
  ('settingUp', 'Setting up...', 'Menyiapkan...'),
  ('lockTitle', 'Enter your passcode', 'Masukkan kode sandi Anda'),
  ('lockHint', 'Your passcode', 'Kode sandi Anda'),
  ('unlock', 'Unlock', 'Buka kunci'),
  ('useBiometrics', 'Use face or fingerprint', 'Gunakan wajah atau sidik jari'),
  ('wrongPasscode', 'That passcode is not right. Try again.', 'Kode sandi itu salah. Coba lagi.'),
  ('unlocking', 'Unlocking...', 'Membuka kunci...'),
  ('vaultDamagedTitle', 'Your journal key could not be read', 'Kunci jurnal Anda tidak bisa dibaca'),
  ('vaultDamagedBody', 'Nothing has been deleted. Try again. If it keeps happening, restore from an export file.', 'Tidak ada yang dihapus. Coba lagi. Jika terus terjadi, pulihkan dari file ekspor.'),
  ('appearance', 'Appearance', 'Tampilan'),
  ('theme', 'Theme', 'Tema'),
  ('themeSystem', 'Match phone', 'Ikuti ponsel'),
  ('themeLight', 'Light', 'Terang'),
  ('themeDark', 'Dark', 'Gelap'),
  ('language', 'Language', 'Bahasa'),
  ('languageSystem', 'Match phone', 'Ikuti ponsel'),
  ('languageSystemNote', 'Uses English unless your phone is set to Indonesian', 'Memakai bahasa Inggris kecuali ponsel Anda diatur ke bahasa Indonesia'),
  ('languageEnglish', 'English', 'English'),
  ('languageIndonesian', 'Bahasa Indonesia', 'Bahasa Indonesia'),
  ('securitySection', 'Security', 'Keamanan'),
  ('changePasscode', 'Change passcode', 'Ganti kode sandi'),
  ('biometricsRow', 'Face or fingerprint', 'Wajah atau sidik jari'),
  ('on', 'On', 'Aktif'),
  ('off', 'Off', 'Mati'),
  ('biometricsUnavailable', 'Face and fingerprint are not set up on this phone.', 'Wajah dan sidik jari belum diatur di ponsel ini.'),
  ('biometricsFailed', 'Face or fingerprint was not recognised, so it stays off.', 'Wajah atau sidik jari tidak dikenali, jadi tetap mati.'),
  ('lockTimeoutRow', 'Lock when I leave the app', 'Kunci saat saya meninggalkan aplikasi'),
  ('timeoutImmediately', 'Immediately', 'Segera'),
  ('timeoutRecommended', 'Recommended', 'Disarankan'),
  ('timeout1', 'After 1 minute', 'Setelah 1 menit'),
  ('timeout5', 'After 5 minutes', 'Setelah 5 menit'),
  ('timeout15', 'After 15 minutes', 'Setelah 15 menit'),
  ('aboutSection', 'About', 'Tentang'),
  ('aboutRow', 'About and privacy', 'Tentang dan privasi'),
  ('aboutTitle', 'Your journal stays on this phone', 'Jurnal Anda tetap di ponsel ini'),
  ('aboutPoint1', 'Nothing you write is uploaded or shared by the app.', 'Tidak ada tulisan Anda yang diunggah atau dibagikan oleh aplikasi.'),
  ('aboutPoint2', 'There is no account, no ads, and no tracking.', 'Tidak ada akun, tidak ada iklan, dan tidak ada pelacakan.'),
  ('aboutPoint3', 'The only way your writing leaves this phone is an export you choose to make.', 'Satu-satunya cara tulisan Anda keluar dari ponsel ini adalah ekspor yang Anda pilih sendiri.'),
  ('aboutPoint4', 'If you forget your passcode, your journal cannot be recovered.', 'Jika Anda lupa kode sandi, jurnal Anda tidak bisa dipulihkan.'),
  ('currentPasscode', 'Current passcode', 'Kode sandi saat ini'),
  ('currentPasscodeHint', 'Your current passcode', 'Kode sandi Anda saat ini'),
  ('newPasscode', 'New passcode', 'Kode sandi baru'),
  ('newPasscodeHint', 'Choose a new passcode', 'Pilih kode sandi baru'),
  ('repeatNewPasscode', 'Repeat new passcode', 'Ulangi kode sandi baru'),
  ('currentPasscodeWrong', 'That is not your current passcode.', 'Itu bukan kode sandi Anda saat ini.'),
  ('changePasscodeButton', 'Change passcode', 'Ganti kode sandi'),
  ('passcodeChangedTitle', 'Passcode changed', 'Kode sandi diganti'),
  ('passcodeChangedBody', 'Your journal opens with the new passcode from now on. Your entries are unchanged.', 'Mulai sekarang jurnal Anda terbuka dengan kode sandi baru. Catatan Anda tidak berubah.'),
  ('passcodeChangeFailed', 'The passcode could not be changed. Nothing was changed. Try again.', 'Kode sandi tidak bisa diganti. Tidak ada yang diubah. Coba lagi.'),
  ('chooseLanguageTitle', 'Language', 'Bahasa'),
  ('addTag', 'Add a tag', 'Tambah tag'),
  ('addTagHint', 'Type a tag and press done', 'Ketik tag lalu tekan selesai'),
  ('clearMood', 'Clear mood', 'Hapus mood'),
  ('addPhoto', 'Add photo', 'Tambah foto'),
  ('takePhoto', 'Take a photo', 'Ambil foto'),
  ('chooseFromLibrary', 'Choose from library', 'Pilih dari galeri'),
  ('photoGenericLabel', 'Photo', 'Foto'),
  ('addCaptionHint', 'Add a caption (optional)', 'Tambah keterangan (opsional)'),
  ('removePhotoAction', 'Remove', 'Hapus'),
  ('removePhotoTitle', 'Remove this photo?', 'Hapus foto ini?'),
  ('removePhotoBody', 'This cannot be undone. The photo is removed from this entry.', 'Tindakan ini tidak bisa dibatalkan. Foto dihapus dari catatan ini.'),
  ('photoAddFailedTitle', 'Couldn\'t add that photo', 'Foto tidak bisa ditambahkan'),
  ('photoAddFailedBody', 'Free some space on the phone, then try again.', 'Kosongkan sedikit ruang di ponsel, lalu coba lagi.'),
  ('photoOpenFailedTitle', 'This photo can\'t be opened', 'Foto ini tidak bisa dibuka'),
  ('photoOpenFailedBody', 'It may be damaged. Everything else in this entry is unaffected.', 'Foto ini mungkin rusak. Bagian lain dari catatan ini tidak terpengaruh.'),
];
