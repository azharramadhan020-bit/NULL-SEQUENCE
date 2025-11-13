System: Reason MUST YOU - Flutter project (skeleton)
--------------------------------------------------

What is included:
- lib/
  - main.dart (app UI + logic)
  - gacha_items.dart (500 randomized Sequence messages)
  - notification_service.dart (schedules one daily random notification in morning or afternoon window)
- pubspec.yaml (dependencies)
- assets/sound/glitch_pop.mp3 (placeholder)
- assets/images/icon.png (placeholder)
- android/ (minimal manifest + placeholders)

Important notes:
- This package is a complete Flutter *project skeleton* ready to be used. However, the Android native gradle wrapper files are minimal placeholders.
- If Codemagic fails to build due to missing Android Gradle files, do one of the following:
  1) On any machine with Flutter installed, run `flutter create .` inside the project folder to generate full native android/ios folders, then re-run build.
  2) Alternatively, upload this project to a GitHub repo and use Codemagic; if build fails, use option (1) on a PC or ask me to provide a full gradle-enabled project (I can try but may require more time).
- To test quickly: upload this ZIP to Codemagic; often Codemagic will generate the missing parts automatically. If not, follow step (1).

Build tips for Codemagic (quick):
1. Create GitHub repo and push this project (or upload ZIP on Codemagic if supported).
2. Configure build as Flutter app, Android, Debug mode.
3. If failure occurs about Gradle, run `flutter create .` locally or ask me to prepare full gradle files.

If you want, I can now attempt to also generate full native android gradle wrappers — tell me and I'll try, but it may take a bit longer.
