/// Passcode rules decided on 2026-09-20 (`lock-and-passcode-policy`): at least
/// 8 characters, and not on a list of very common passcodes.
enum PasscodeProblem { tooShort, tooCommon }

/// A short built-in list of very common passcodes of 8 or more characters.
/// OPEN: replace with a vetted published list before release (the owner
/// decides which); this list is only a floor.
const _common = <String>{
  'password', 'password1', 'password12', 'password123', '12345678', '123456789', '1234567890',
  '87654321', '11111111', '00000000', '88888888', '12341234', '123123123', 'qwertyui', 'qwertyuiop',
  'qwerty123', 'iloveyou', 'abcd1234', 'abc12345', 'letmein1', 'welcome1', 'admin123', 'passw0rd',
  'p@ssw0rd', 'football', 'baseball', 'sunshine', 'princess', 'trustno1', 'dragon12', 'monkey12',
  'master12', 'superman', 'whatever', 'starwars', 'computer', 'internet', '1q2w3e4r', '1qaz2wsx',
  'asdfghjk', 'zxcvbnm1', 'jurnalku', 'rahasia1', 'rahasia123', 'katasandi', 'sayangku', 'bismillah',
};

const int minPasscodeLength = 8;

PasscodeProblem? checkPasscode(String value) {
  if (value.runes.length < minPasscodeLength) return PasscodeProblem.tooShort;
  if (_common.contains(value.toLowerCase())) return PasscodeProblem.tooCommon;
  return null;
}
