A starter Flutter project with a minimal shell of a  game
including the following features:

- main menu screen
- basic navigation
- game-y theming
- settings
- sound

You can jump directly into building your game in `lib/src/play_session/`.

When you're ready for things like ads, in-app purchases, achievements,
analytics, crash reporting, and so on, 
there are resources ready for you
at [flutter.dev/games](https://flutter.dev/games).


# Getting started

Clone this project and run the following command in its root directory:

```terminal
flutter create . --project-name game_template
```

This will create the necessary platform files, such as `ios/`, `android/`,
`web/`, `macos/`, `linux/` or `windows/`, depending on your installation of Flutter.

After this, the game compiles and works out of the box. It comes with things
like a main menu, a router, a settings screen, and audio.
When building a new game, this is likely everything you first need.

When you're ready to enable more advanced integrations, like ads
and in-app payments, read the _Integrations_ section below.


# Development

To run the app in debug mode:

    flutter run

This assumes you have an Android emulator,
iOS Simulator, or an attached physical device.

It is often convenient to develop your game as a desktop app.
For example, you can run `flutter run -d macOS`, and get the same UI
in a desktop window on a Mac. That way, you don't need to use a
simulator/emulator or attach a mobile device. This template supports
desktop development by disabling integrations like AdMob for desktop.


## Code organization

Code is organized in a loose and shallow feature-first fashion.
In `lib/src`, you'll therefore find directories such as `ads`, `audio`
or `main_menu`. Nothing fancy, but usable.

```
lib
├── src
│   ├── app_lifecycle
│   ├── audio
│   ├── game_internals
│   ├── level_selection
│   ├── main_menu
│   ├── play_session
│   ├── player_progress
│   ├── settings
│   ├── style
│   └── win_game
├── ...
└── main.dart
```

The state management approach is intentionally low-level. That way, it's easy to
take this project and run with it, without having to learn new paradigms, or having
to remember to run `flutter pub run build_runner watch`. You are,
of course, encouraged to use whatever paradigm, helper package or code generation
scheme that you prefer.


## Building for production

To build the app for iOS (and open Xcode when finished):

```bash
flutter build ipa && open build/ios/archive/Runner.xcarchive
```

To build the app for Android (and open the folder with the bundle when finished):

```bash
flutter build appbundle && open build/app/outputs/bundle/release
```

While the template is meant for mobile games, you can also publish
for the web. This might be useful for web-based demos, for example,
or for rapid play-testing. The following command requires installing
[`peanut`](https://pub.dev/packages/peanut/install).

```bash
flutter pub global run peanut \
--web-renderer canvaskit \
--extra-args "--base-href=/name_of_your_github_repo/" \
&& git push origin --set-upstream gh-pages
```

The last line of the command above automatically pushes
your newly built web game to GitHub pages, assuming that you have
that set up.


# Integrations

TODO(filiph): keep the general advice, like changing package name early,
              but move everything else to adjacent documentation (such as cookbook)


## Settings

The settings page is enabled by default, and accessible both
from the main menu and the "gear" button in the play session screen.

Settings are saved to local storage using the `package:shared_preferences`.
To change what preferences are saved and how, edit files in
`lib/src/settings/persistence`.

```dart
abstract class SettingsPersistence {
  Future<bool> getMusicOn();

  Future<bool> getMuted({required bool defaultValue});

  Future<String> getPlayerName();

  Future<bool> getSoundsOn();

  Future<void> saveMusicOn(bool value);

  Future<void> saveMuted(bool value);

  Future<void> savePlayerName(String value);

  Future<void> saveSoundsOn(bool value);
}
```

# Icon

To update the launcher icon, first change the files
`assets/icon-adaptive-foreground.png` and `assets/icon.png`.
Then, run the following:

```bash
flutter pub run flutter_launcher_icons:main
```

You can [configure](https://github.com/fluttercommunity/flutter_launcher_icons#book-guide)
the look of the icon in the `flutter_icons:` section of `pubspec.yaml`.
