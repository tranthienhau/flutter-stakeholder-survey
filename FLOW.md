# Screenshot capture flow

Real captures from the iOS Simulator via an integration-test driver (no mockups).

## Steps

1. Boot the simulator:
   ```bash
   xcrun simctl boot "iPhone 16e"
   open -a Simulator
   ```
2. Scaffold the iOS platform folder (if missing) and get dependencies:
   ```bash
   flutter create . --platforms=ios --project-name flutter_stakeholder_survey
   flutter pub get
   ```
3. Drive the screenshot test:
   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "889A2E50-D60F-4785-84BD-5700F9048279"
   ```
4. Build the demo GIF from the PNGs:
   ```bash
   cd screenshots
   ffmpeg -y -framerate 1 -pattern_type glob -i '*.png' \
     -vf "scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 demo.gif
   ```

PNGs + `demo.gif` are written to `screenshots/` and embedded in `README.md`.

## How it works

- `integration_test/screenshot_test.dart` - pumps each screen in a single `MaterialApp`
  wrapped in a `RepaintBoundary`, seeded with mock data through Riverpod
  `ProviderScope` overrides (so the Supabase-backed providers resolve without a
  live backend). It walks the three key screens:
  - `HomeScreen` - the stakeholder survey list (01-surveys)
  - `InterviewScreen` - mixed question types: rating, single choice, multi choice, text (02-interview)
  - `DashboardScreen` - response stats plus the fl_chart bar charts (03-dashboard)
- Each screen is rendered to a real PNG via `RepaintBoundary.toImage(pixelRatio: 3.0)`.
  This in-process path is used because the GPU surface-capture path
  (`convertFlutterSurfaceToImage` + `takeScreenshot`) returns blank frames on this
  simulator, and the simulator filesystem is read-only inside the test.
- `test_driver/integration_test.dart` - the captured PNGs are shipped back to the host
  as base64 in `reportData`; the driver's `responseDataCallback` decodes them and writes
  `screenshots/<name>.png` on the host machine. The `onScreenshot` hook is kept as a
  fallback for the standard `takeScreenshot` path.
