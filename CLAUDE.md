# BartoszWeather

Weather forecast app for iOS 17+ built with SwiftUI, MVVM-Coordinator and Swift Testing.
Data comes from Open-Meteo (geocoding and forecast APIs, no API key).

## Commands

```sh
xcodebuild build -scheme BartoszWeather -destination 'platform=iOS Simulator,name=iPhone 17'
xcodebuild test  -scheme BartoszWeather -destination 'platform=iOS Simulator,name=iPhone 17'
```

The project uses the Xcode 27 `project.xcproj` format with filesystem-synchronized folders:
files added under `BartoszWeather/` or `BartoszWeatherTests/` join their target automatically.
Change targets and build settings with `xcrun xcodeproj`, not by hand-editing the project file.

## Architecture

Modules are folders inside one app target, laid out so they can later become real modules:

| Folder | Contents | May depend on |
|---|---|---|
| `App/` | Entry point, composition root, app coordinator | everything |
| `Core/` | Domain models and shared utilities | nothing |
| `Networking/` | HTTP client, endpoints, DTOs | `Core` |
| `Theming/` | Design tokens, icons, shared SwiftUI components | `Core` |
| `Features/<Name>/` | Screens, view models, coordinators, services | `Core`, `Networking`, `Theming` |

- Features never import each other.
- MVVM-C: views render state and forward intents; `@Observable` view models own state and logic;
  coordinators own navigation. View models report navigation through closures or protocols and never touch SwiftUI navigation types.
- Dependencies are created once in the composition root and injected through initializers.
- Mark API meant to cross module boundaries as `public` now so the module migration stays mechanical.
- DTOs stay in `Networking`; mapping DTO to domain happens in the feature service layer and is tested.

## Testing

- TDD: write a failing test, make it pass, refactor.
- Swift Testing only (`import Testing`, `@Test`, `#expect`, `#require`). No XCTest.
- `BartoszWeatherTests/` mirrors the source folder structure.
- Test through protocols with hand-written fakes; no network in unit tests (`URLProtocol` stubs for the HTTP client).

## Code style

- English everywhere: code, strings in tests, commits, PRs.
- No explanatory comments; names carry the meaning. Doc comments only on non-obvious public API.
- Swift 6 language mode with MainActor default isolation; keep code free of concurrency warnings.
- No third-party dependencies.

## Git workflow

- One branch and one PR per step, branched from current `main`: `type/short-description`.
- Conventional Commits: `type(scope): subject` in the imperative mood, subject at most 72 characters.
  - Types: `feat`, `fix`, `test`, `refactor`, `chore`, `ci`, `docs`, `style`.
  - Scopes: `app`, `core`, `networking`, `theming`, `search`, `forecast`, `ci`.
    Leave the scope out only for repository-wide changes (tooling, docs, ignore rules).
- Each commit is one coherent change with its tests, and builds with green tests.
  Red-green cycles stay local; do not commit failing tests or fix-up commits.
- Before every push, run the `pre-push-review` skill and resolve its findings.
- PRs are merged with a merge commit. Never squash.
- Local-only files (listed in `.git/info/exclude`): `TASKS.md`, `networkInfo.md`, the task PDF.
