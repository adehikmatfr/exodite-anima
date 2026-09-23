import 'package:flutter/foundation.dart';

/// Lets a screen that must hand control to an external activity - the
/// camera, the photo library - tell [_Shell] (`app/lib/main.dart`) to defer
/// its immediate-lock rule for as long as that hand-off is in flight,
/// including the whole time the app sits in the background waiting for the
/// activity to return (FEAT-011). Without this, opening the camera or the
/// gallery backgrounds the app exactly the way switching to any other app
/// does, so FEAT-003's "lock immediately" rule fires mid-pick: the database
/// closes, the data key is wiped, and every screen is popped back to the
/// timeline before the picked photo can ever be saved - the photo is not
/// lost by the lock as such, it simply never had anywhere left to land.
///
/// This does not weaken the lock rule itself, only when it runs: [_Shell]
/// still locks the moment the last hold ends, so returning from the camera
/// or the library still asks for the passcode again, same as returning from
/// anywhere else. The held photo is written to the still-open, still-keyed
/// database first, so it survives that lock instead of being lost by it.
class AutoLockGuard {
  AutoLockGuard._();

  static final ValueNotifier<int> _holds = ValueNotifier(0);

  /// Whether a hold is currently active. [_Shell] checks this before locking
  /// and defers if true; it does not need to know why.
  static bool get held => _holds.value > 0;

  /// Notifies on every change to the hold count; [_Shell] listens so it can
  /// apply a lock it deferred the moment the last hold ends.
  static Listenable get changes => _holds;

  /// Runs [action] with locking held off for its whole duration. Holds
  /// nest: the app stays unlocked-on-background until every concurrent
  /// hold has released, not just the first one.
  static Future<T> hold<T>(Future<T> Function() action) async {
    _holds.value++;
    try {
      return await action();
    } finally {
      _holds.value--;
    }
  }
}
