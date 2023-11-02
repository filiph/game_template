// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'persistence/local_storage_player_progress_persistence.dart';
import 'persistence/player_progress_persistence.dart';

/// Encapsulates the player's progress.
class PlayerProgress extends ChangeNotifier {
  static final _log = Logger('PlayerProgress');

  static const maxHighestScoresPerPlayer = 10;

  /// By default, settings are persisted using
  /// [LocalStoragePlayerProgressPersistence] (i.e. NSUserDefaults on iOS,
  /// SharedPreferences on Android or local storage on the web).
  final PlayerProgressPersistence _store;

  int _highestLevelReached = 0;

  /// A future that completes when the initial loading of values
  /// from the [store] has been either finished (`true`),
  /// or has timed out (`false`).
  late final Future<bool> hasLoadedSuccessfully;

  /// Creates an instance of [PlayerProgress] backed by an injected
  /// persistence [store].
  PlayerProgress({PlayerProgressPersistence? store})
      : _store = store ?? LocalStoragePlayerProgressPersistence() {
    hasLoadedSuccessfully = _getLatestFromStore();
  }

  /// The highest level that the player has reached so far.
  int get highestLevelReached => _highestLevelReached;

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  void reset() async {
    _highestLevelReached = 0;
    notifyListeners();

    await hasLoadedSuccessfully;
    unawaited(_store.saveHighestLevelReached(_highestLevelReached));
  }

  /// Registers [level] as reached.
  ///
  /// If this is higher than [highestLevelReached], it will update that
  /// value and save it to the injected persistence store.
  void setLevelReached(int level) async {
    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      notifyListeners();

      await hasLoadedSuccessfully;
      unawaited(_store.saveHighestLevelReached(level));
    }
  }

  /// Fetches the latest data from the backing persistence store.
  Future<bool> _getLatestFromStore() async {
    final timeLimit = Duration(seconds: 5);

    int level;
    try {
      level = await _store.getHighestLevelReached().timeout(timeLimit);
    } on TimeoutException {
      _log.warning(
          'Timed out while fetching highest level reached from store.');
      return false;
    } catch (e) {
      _log.warning('Error loading highest level reached from store', e);
      return false;
    }

    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      notifyListeners();
    } else if (level < _highestLevelReached) {
      await _store.saveHighestLevelReached(_highestLevelReached);
    }

    return true;
  }
}
