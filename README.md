# PlantQuest

An offline plant-learning game for Grades 1–6. Kids explore 15 Philippine plants across
three worlds (Bakuran, Bukid, Kalikasan) with Binhi, a little seed in a pot who grows as
they earn leaves.

- Fully offline: no internet permission, no accounts, no ads, no data leaves the phone.
- Read-aloud with the phone's own offline voice; soft background music.
- Quizzes, mini-games (Label it, Grow it, Match it), a sticker book, badges, and a leaf
  Shop for Binhi's outfits.

The full design, every decision and the content rules are in **[PLAN.md](PLAN.md)**.

## What's inside

| Folder | What |
|---|---|
| `lib/app` | Start screen, router, bottom bar, page transitions |
| `lib/art` | All drawings: Binhi, avatars, animal friends, plants, world scenes, icons |
| `lib/content` | Plant text, questions and game words (marked DRAFT for teacher review) |
| `lib/data` | The local database (drift/SQLite) and how progress is saved |
| `lib/features` | The screens: onboarding, Home, Plants, quizzes, games, Shop, Profile, Settings |
| `lib/game` | Pure game rules: leaves, unlocking, quizzes, Shop, badges |
| `lib/services` | Read-aloud, sound effects, music |
| `lib/state` | App state (Riverpod) and celebrations |
| `lib/widgets` | Shared building blocks (chunky buttons, cards, pills, effects) |
| `lib/dev` | Preview pages used while designing (debug and web builds only) |
| `assets` | Fonts, sounds, music, app icon and splash images |
| `test` | Automated tests (rules, database, screens, small phones) |
| `tool` | Scripts that draw preview pictures and generate sounds/music |
| `docs` | Original screenshots and every preview picture |

## Set up a computer

1. Install Flutter (3.47 or newer) and Android Studio (for the Android SDK).
2. In this folder run:

   ```
   flutter pub get
   flutter test
   ```

   All tests should pass.

**This PC only:** Gradle needs this before Android builds (the Windows temp path has a
space in it):

```
set JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\Android\tmp
```

## Try it in a browser

```
flutter build web --release --no-web-resources-cdn
```

Then serve `build/web` (for example `python -m http.server 8686` inside it) and open
`http://localhost:8686`. Press Ctrl+Shift+R after each rebuild.

## Build the Android app

1. **Once:** make a release key, stored outside this folder, and write
   `android/key.properties` (see "Release key" below).
2. Build:

   ```
   flutter build apk --release --split-per-abi
   ```

3. The APKs are in `build/app/outputs/flutter-apk/`:
   - `app-arm64-v8a-release.apk`: most phones from the last several years (use this one).
   - `app-armeabi-v7a-release.apk`: older 32-bit phones.
4. Copy the APK to the phone (USB file transfer), open it in the phone's Files app and
   allow "Install unknown apps" when asked.

To update the app later, raise the version in `pubspec.yaml` (e.g. `2.0.1+2`), build
again with the **same key**, and install over the old one. Progress on the phone is kept.

### Release key

The key proves an update comes from you. **Keep it and its passwords safe and backed up.**
If it is lost, phones can't take updates of the app; it would have to be uninstalled
(losing the child's progress) and installed fresh.

- Key file: `C:\Android\keys\plantquest-release.jks` (never inside this project).
- `android/key.properties` (never shared; already ignored):

  ```
  storeFile=C:/Android/keys/plantquest-release.jks
  storePassword=<your password>
  keyAlias=plantquest
  keyPassword=<your password>
  ```

Without `key.properties` the build still works but signs with this PC's test key. That's
what version 2.0.0 uses (no Play Store yet). Updates built on **this PC** install over it
and keep progress. Switching to a real key later means uninstalling the test-key app first
(which clears that phone's progress), so make the real key before giving the app to many
children.

## Backups

Settings → Progress → SAVE writes all of a child's progress to one JSON
file (via the `file_picker` package and the phone's own file chooser);
LOAD restores it. When you add a table or column, old backups still load:
missing columns take their defaults. See PLAN.md §5h.

## Changing the database

The database is versioned so updates never wipe progress. To change a table: edit
`lib/data/tables.dart`, raise `schemaVersion` in `lib/data/database.dart`, run
`dart run drift_dev make-migrations`, add the step to `onUpgrade`, then run the tests.

## Content review

All plant text, questions and game words are drafts until a teacher checks them:
`lib/content/plant_content.dart`, `questions.dart` and `plant_games.dart`.

## Credits

Developed by the PlantQuest team (names on the loading screen). Fonts: Fredoka (SIL Open
Font License, `assets/fonts/OFL.txt`). Sounds and music were generated for this project
by scripts in `tool/`.
