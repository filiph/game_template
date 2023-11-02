// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'persistence/local_storage_settings_persistence.dart';
import 'persistence/settings_persistence.dart';

/// An class that holds settings like [playerName] or [musicOn],
/// and saves them to an injected persistence store.
class SettingsController {
  static final _log = Logger('SettingsController');

  /// The persistence store that is used to save settings.
  final SettingsPersistence _store;

  final ValueNotifier<bool> _audioOn = ValueNotifier(true);

  final ValueNotifier<String> _playerName = ValueNotifier('Player');

  final ValueNotifier<bool> _soundsOn = ValueNotifier(true);

  final ValueNotifier<bool> _musicOn = ValueNotifier(true);

  /// A future that completes when the initial loading of values
  /// from the [store] has been either finished (`true`),
  /// or has timed out (`false`).
  late final Future<bool> hasLoadedSuccessfully;

  /// Creates a new instance of [SettingsController] backed by [store].
  ///
  /// By default, settings are persisted using [LocalStorageSettingsPersistence]
  /// (i.e. NSUserDefaults on iOS, SharedPreferences on Android or
  /// local storage on the web).
  SettingsController({SettingsPersistence? store})
      : _store = store ?? LocalStorageSettingsPersistence() {
    // Start fetching the saved values from the persistence store.
    hasLoadedSuccessfully = _loadStateFromPersistence();
  }

  /// Whether or not the audio is on at all. This overrides both music
  /// and sounds (sfx).
  ///
  /// This is an important feature especially on mobile, where players
  /// expect to be able to quickly mute all the audio. Having this as
  /// a separate flag (as opposed to some kind of {off, sound, everything}
  /// enum) means that the player will not lose their [soundsOn] and
  /// [musicOn] preferences when they temporarily mute the game.
  ValueListenable<bool> get audioOn => _audioOn;

  /// Whether or not the music is on.
  ValueListenable<bool> get musicOn => _musicOn;

  /// The player's name. Used for things like high score lists.
  ValueListenable<String> get playerName => _playerName;

  /// Whether or not the sound effects (sfx) are on.
  ValueListenable<bool> get soundsOn => _soundsOn;

  void setPlayerName(String name) async {
    _playerName.value = name;

    await hasLoadedSuccessfully;
    _store.savePlayerName(_playerName.value);
  }

  void toggleAudioOn() async {
    _audioOn.value = !_audioOn.value;

    await hasLoadedSuccessfully;
    _store.saveAudioOn(_audioOn.value);
  }

  void toggleMusicOn() async {
    _musicOn.value = !_musicOn.value;

    await hasLoadedSuccessfully;
    _store.saveMusicOn(_musicOn.value);
  }

  void toggleSoundsOn() async {
    _soundsOn.value = !_soundsOn.value;

    await hasLoadedSuccessfully;
    _store.saveSoundsOn(_soundsOn.value);
  }

  /// Asynchronously loads values from the injected persistence store.
  Future<bool> _loadStateFromPersistence() async {
    const timeLimit = Duration(seconds: 5);

    final parallelFetch = Future.wait([
      _store.getAudioOn(defaultValue: true).timeout(timeLimit).then((value) {
        if (kIsWeb) {
          // On the web, sound can only start after user interaction, so
          // we start muted there on every game start.
          return _audioOn.value = false;
        }
        // On other platforms, we can use the persisted value.
        return _audioOn.value = value;
      }),
      _store
          .getSoundsOn(defaultValue: true)
          .timeout(timeLimit)
          .then((value) => _soundsOn.value = value),
      _store
          .getMusicOn(defaultValue: true)
          .timeout(timeLimit)
          .then((value) => _musicOn.value = value),
      _store
          .getPlayerName()
          .timeout(timeLimit)
          .then((value) => _playerName.value = value),
    ]);

    try {
      final loadedValues = await parallelFetch;
      _log.fine(() => 'Loaded all settings: $loadedValues');
      return true;
    } on TimeoutException {
      _log.warning('Failed to load settings within $timeLimit');
      return false;
    } catch (e) {
      _log.warning('Failed to load settings', e);
      return false;
    }
  }
}
