# BagiRasa UI Implementation Rules (read before EVERY screen task)

## Project
Flutter, Android, portrait, design artboard 390x844. All UI text is Indonesian. Light mode only. Code identifiers are in English.

## Inputs per task
- A screenshot = visual source of truth. CSS exported from Figma = exact sizes, spacing, colors, radii, shadows, fonts.
- The CSS contains NO text content. Read every visible text from the screenshot and use it exactly. At the end, list ALL texts you extracted so I can verify them.
- If CSS and screenshot disagree, follow the screenshot.

## Layout rules
1. Translate Figma auto-layout into Column, Row, Padding, SizedBox, Expanded, Spacer. Never place content by hard-coded absolute coordinates. `position: absolute` is only for layering (overlays, floating buttons, handles).
2. 390px is the design artboard. The result must adapt to other widths (constraints + horizontal paddings from the CSS).
3. Use exact paddings, gaps, radii, font sizes, weights, and line heights from the CSS.
4. `box-shadow: 0px Ypx 0px color` (zero blur) is a solid bottom edge (3D look): BoxShadow(blurRadius: 0, offset: Offset(0, Y)). Never soften it.
5. Rectangles named "Icon" with only a background color are icon placeholders. Replace with rounded Material icons in that color. Never draw a plain colored rectangle.
6. Mascot "Rasi" must NOT be rebuilt from vector boxes. Use image assets: assets/images/rasi_worried.png, assets/images/rasi_empty.png. If a file is missing, show a neutral placeholder with a TODO comment.
7. Ignore layers named "BACKGROUND SIMULATED..." or any dimmed/blurred copy of another screen. They are context only.
8. Any layer that is a map picture or map placeholder must be replaced by a real FlutterMap widget in the same area.
9. Ignore `backdrop-filter`. Approximate with a plain semi-transparent color.

## Code rules
- Use ONLY tokens from lib/core/theme (AppColors, AppTextStyles, AppRadius) and the ChunkyButton widget. No hard-coded hex colors in feature files. If a token is missing, add it to the theme file first.
- Keep UI and logic separate. Widgets only display data and call functions. Logic lives in controllers/repositories.
- State management: Provider with ChangeNotifier. (Team may change this single line.)
- Allowed packages: google_fonts, provider, flutter_map, latlong2. Ask before adding anything else, unless the task explicitly allows it.
- Split big build methods into small private widgets. No duplicated blocks. Use clear names.
- No backend. Use an in-memory repository with dummy data.
- Do not add features that are not in the design.
- STUB POLICY: if the design shows a control whose real feature is not built (GPS "lokasi saya", route, reminders, address lookup), render it faithfully, wire it to a stub that shows a SnackBar "Fitur ini belum tersedia", and add `// TODO(stub): ...`. NEVER fake a successful result.
- Maps: use flutter_map with OpenStreetMap tiles (https://tile.openstreetmap.org/{z}/{x}/{y}.png), set userAgentPackageName to this app's applicationId, and make sure android/app/src/main/AndroidManifest.xml has the INTERNET permission.

## Shared structure (create if missing, REUSE if it exists, never duplicate)
- lib/features/lokasi/data/pickup_point.dart: class PickupPoint { id, name, address, latitude, longitude, openTime, closeTime, note, photoPath, activeListingCount, status }.
- lib/features/lokasi/data/pickup_point_repository.dart: ChangeNotifier, in-memory, methods getAll, getById, add, update, delete. Seed 4-5 dummy points using the names/addresses visible in the screenshots. Coordinates are dummy values around one constant `kCampusCenter = LatLng(-0.9140, 100.4590)` (team can change it to their campus).
- lib/core/widgets/main_shell.dart: minimal Scaffold with a 4-tab bottom navigation (Beranda, Peta, Klaim, Profil) styled from the design. Tabs without a built screen show a simple placeholder.

## Always finish with
(a) `flutter analyze` with zero errors, (b) list of files created/changed, (c) the extracted texts, (d) every stub you added, (e) anything you could not reproduce exactly and why.