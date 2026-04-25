# BlitzFlash iOS Development Notes

Use this file as the handoff note when starting a new Codex/chat session.

## Project

BlitzFlash iOS is the native SwiftUI version of BlitzFlash, an English vocabulary learning app for Turkish users.

- iOS repo: https://github.com/BlitzHan/blitzflash-ios
- Web source repo: https://github.com/BlitzHan/BlitzFlash
- Local iOS project path: `/Users/blitz/Desktop/BlitzFlash-iOS/BlitzFlash`
- Xcode project: `BlitzFlash.xcodeproj`
- Bundle ID: `com.blitzhanlabs.BlitzFlash`

## Current State

The app builds and runs as a native SwiftUI app. It is no longer a WebView wrapper.

The web version was inspected and ported conceptually:

- Static web app using `index.html`, `style.css`, `app.js`, and `words*.js`.
- Vocabulary data was converted into Swift.
- `VocabularyData.swift` currently contains 790 words from the web app's BBC Essential word files.

Native iOS modes currently implemented:

- `Serbest Mod`
- `Yazarak Tahmin`
- `Cümle Tamamla`
- `Kelime Avı`

## Design Direction

The design language should follow the web app:

- Dark neon arcade style.
- Background: near-black, subtle cyan grid, soft glow.
- Main colors:
  - cyan: `#00f0ff`
  - magenta: `#ff2d7c`
  - amber/lightning: `#ffb800`
  - green/success: bright neon green
  - red/danger: bright warning red
- Use lightning/bolt visual language.
- Keep UI modern and game-like, but still clean enough for App Store.

Important recent design decisions:

- First screen should directly show the 4 game modes.
- Do not show the old "790 BBC Essential word" info card on the first screen.
- Avoid a generic "Start now" hero; user should pick a mode.
- App is Turkish-facing, so visible UI text should use correct Turkish characters.

## Important Files

- `BlitzFlash/BlitzModels.swift`
  - Shared models, `VocabularyWord`, `BlitzMode`.
- `BlitzFlash/VocabularyData.swift`
  - Generated local vocabulary data.
- `BlitzFlash/BlitzTheme.swift`
  - Colors, background, neon cards, button styles.
- `BlitzFlash/HomeView.swift`
  - First screen and mode selection.
- `BlitzFlash/StudySessionView.swift`
  - Serbest Mod.
- `BlitzFlash/TypingModeView.swift`
  - Yazarak Tahmin.
- `BlitzFlash/SentenceModeView.swift`
  - Cümle Tamamla.
- `BlitzFlash/WordHuntView.swift`
  - Kelime Avı.

## Serbest Mod Details

Recent UX requirements:

- Cards should sometimes start with English and sometimes with Turkish.
- The label must say `English` or `Türkçe`.
- `Türkçe` must be spelled correctly.
- Label position should be fixed and should not jump based on word length.
- Word and sentence areas should have stable heights so long words do not shift the card layout.
- User can tap the card to reveal the other side.
- User can swipe right for `Bildim`.
- User can swipe left for `Bilemedim`.
- Buttons still exist:
  - `Bildim`: encouraging green.
  - `Bilemedim`: warning/red, not amber.

## Build Check

Most recent successful build command:

```bash
xcodebuild -project BlitzFlash.xcodeproj -scheme BlitzFlash -destination 'generic/platform=iOS' -derivedDataPath /tmp/BlitzFlashDerivedData CODE_SIGNING_ALLOWED=NO ENABLE_USER_SCRIPT_SANDBOXING=NO build
```

The local terminal often prints CoreSimulator warnings due sandbox/service permissions, but the build is considered good when it ends with:

```text
** BUILD SUCCEEDED **
```

## Git History

Recent commits:

- `6793ee6` - Polish home screen and free study cards
- `fe5266f` - Refine mode selection and card gestures
- `f4285c6` - Apply BlitzFlash neon arcade design
- `8ac052a` - Initial native BlitzFlash iOS app

## Next Suggested Work

Likely next steps:

- Test the latest UI in Xcode simulator/device and tune spacing/gesture feel.
- Improve App Icon and Launch Screen using the neon lightning identity.
- Add persistent scores for `Yazarak Tahmin`.
- Add completion/result screens for each mode.
- Improve `Kelime Avı` so cards can show either EN or TR, similar to the web version.
- Add haptics for swipe/reveal/correct/wrong.
- Add local progress persistence.
- Prepare App Store metadata, screenshots, privacy policy, and TestFlight flow.

## New Session Prompt

When opening a new Codex/chat session, use:

```text
BlitzFlash iOS projesine devam ediyoruz. Önce /Users/blitz/Desktop/BlitzFlash-iOS/BlitzFlash/DEVELOPMENT_NOTES.md dosyasını oku, sonra git status ve build durumunu kontrol et. Kaldığımız yerden devam edelim.
```
