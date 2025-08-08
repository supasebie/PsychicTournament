# PsychicTournament App Context

This document provides a complete, high-signal overview of the PsychicTournament Flutter app: what it does, how it’s structured, key data models, services, navigation, theming, and extension points. You can hand this file back to me to answer “how to build X into this app” with precision.


## 1) App Summary
- Purpose: Zener card ESP game (25 turns, 5 symbols). Tracks results, shows animated/modern UI, optional authentication, local history/statistics, and remote high-scores.
- Primary stacks/libs: Flutter (Material 3), Google Mobile Ads, Supabase (auth + table high_scores), sqflite (local SQLite), fl_chart (charts), flutter_svg, google_fonts, vibration.
- Platforms: Android, iOS, Web (web scaffolding present). Android manifest includes AdMob test App ID. iOS configs not in repo (standard Flutter), web manifest/index included.


## 2) Entry, Routing, Screens
- Entry: lib/main.dart
  - Locks portrait Up, initializes Supabase (best-effort), initializes Google Mobile Ads, then runs MaterialApp with AppTheme.dark().
  - Named routes:
    - '/': MainMenuScreen (home)
    - '/zener-game': ZenerGameScreen
    - '/game-history': GameHistoryScreen
    - '/game-statistics': GameStatisticsScreen
    - '/stats-menu': PerformanceMenuScreen
  - onGenerateRoute: '/session-detail' expects a GameSession argument -> SessionDetailScreen(session: ...)

- Screens:
  - MainMenuScreen: Animated gradient background + glass UI. Primary actions: Zener Cards, My Games (sub-menu), Auth (Sign In/Out). Shows “Leaderboard” card with top scores (today, this month) fetched from Supabase via HighScoresService. Optional bottom banner ad.
  - ZenerGameScreen: The game experience with animations, symbol selection, score & turn display, remote viewing coordinates, haptic feedback, feedback overlay, card reveal animation. On completion: optional interstitial ad, then navigates to ResultsReviewScreen (or shows a final score dialog with “Play Again” and “View Detailed Results”). Has Debug mode to preview next cards.
  - ResultsReviewScreen: Turn-by-turn 5x5 results grid showing user guess vs correct answer; saves the session locally on entry (via GameDataConverter -> GameDatabaseService), and tries to insert high score remotely (>= 11) via Supabase.
  - GameHistoryScreen: Paginated list of saved sessions from local SQLite with swipe-to-delete, pull-to-refresh, and detail navigation.
  - SessionDetailScreen: Loads full session with turn results; shows metadata, performance analysis, per-symbol hit rates, 5x5 grid, legend. Allows delete and copy-to-clipboard “share” text.
  - GameStatisticsScreen: Aggregates all sessions to compute total games, best score, average score, hit rate, trends. Displays charts (fl_chart) for average score and hit rate over time, date range filters, grouping (daily/weekly/monthly), and insights.
  - PerformanceMenuScreen: Simple menu linking to History and Statistics with animated background.
  - AuthScreen: Email/password Sign In/Sign Up + Reset Password backed by SupabaseService.


## 3) Core Game Logic and Models
- GameController (lib/controllers/game_controller.dart)
  - Maintains an immutable GameState and exposes operations:
    - createShuffledDeck(): 25 cards (5 of each symbol), Fisher–Yates shuffle.
    - generateRemoteViewingCoordinates(): "XXXX-XXXX" alphanumeric (A-Z0-9) string.
    - makeGuess(ZenerSymbol): returns GuessResult, updates state (score, turn, results, completion).
    - resetGame(), getters for current score/turn/coordinates/results.
  - GameState (lib/models/game_state.dart): deck, coordinates, currentTurn, score, isComplete, gameResults ([[userGuess, correctAnswer] per turn]). Derived: currentCard, hasMoreTurns.
  - ZenerSymbol (lib/models/zener_symbol.dart): enum { circle, cross, waves, square, star } with displayName and assetPath (SVGs in assets/zener).
  - GuessResult (lib/models/guess_result.dart): isCorrect, correctSymbol, userGuess, newScore + feedbackMessage.


## 4) Persistence Layer (Local SQLite)
- Storage: sqflite via DatabaseConfig and GameDatabaseService.
- Schema (lib/database/database_constants.dart):
  - game_sessions(id PK, date_time TEXT ISO, coordinates TEXT, final_score INT, total_turns INT default 25, created_at TEXT default CURRENT_TIMESTAMP)
  - turn_results(id PK, session_id INT FK -> game_sessions(id) ON DELETE CASCADE, turn_number INT, user_guess TEXT, correct_answer TEXT, is_hit INT)
- Models (lib/database/models/...):
  - GameSession: id?, dateTime, coordinates, finalScore, totalTurns, [turnResults]. Validates coordinate format, scores, counts.
  - TurnResult (database variant): id?, sessionId?, turnNumber, userGuess, correctAnswer, isHit. toMap stores enums by name and booleans as 0/1.
  - GameStatistics + PerformanceTrend: computed analytics object, not persisted.
- Services:
  - GameDatabaseService: singleton. Transactions for saving complete sessions and turn results. Utilities: getAll/getById (with/without turn results), delete session (cascade), pagination, date range queries, filtered turn result queries, counts, raw SQL helpers, health/version checks. Handles exceptions via DatabaseException wrapper.
  - GameStatisticsService: reads sessions (+turn results) to calculate:
    - totalGames, averageScore, bestScore, totalTurns, totalHits, hitRate%, performance trends (daily/weekly/monthly groupings). Methods also provide filtered/date-range stats and recent trends.
- Conversion:
  - GameDataConverter: converts UI gameResults ([[userGuess, correctAnswer]]) into TurnResult list and GameSession. Validates coordinates format, final score consistency, caps at 25 turns, etc.


## 5) Remote Backend (Supabase)
- Config: lib/config/supabase_config.dart contains url + anon key (replace for production; treat as non-secret client key).
- SupabaseService: static helper to initialize SDK, expose client, current user, auth state stream, and actions (signInWithEmail, signUpWithEmail with display_name, signOut, resetPassword). Safe to call when uninitialized; most methods guard and either throw or no-op.
- HighScoresService: inserts/fetches high scores from Supabase table public.high_scores with columns: username (text), score (int), recorded_at (timestamptz default now()). Guards to insert only if score >= 11 and Supabase initialized; derives username from user metadata display_name else 'Anon'.
  - fetchTopScores(limit=20), fetchTopScoreToday(), fetchTopScoreThisMonth() (UTC boundaries).
- AuthScreen uses SupabaseService for Sign In/Up and Reset.


## 6) Ads (Google Mobile Ads)
- AdService: wraps test Ad Unit IDs (Android/iOS) for banner and interstitial and builders for BannerAd and loading InterstitialAd. MainMenu displays a banner at footer when loaded. ZenerGame preloads an interstitial to display once after session completion, before navigating to results.
- AndroidManifest includes AdMob test application ID meta-data. Replace with production IDs for release.


## 7) UI, Theming, and Widgets
- Theme (lib/theme):
  - AppTheme.dark(): Material 3, custom dark ColorScheme with neon accents; Sora font via google_fonts with fallbacks; themed buttons, cards, dialogs, transitions, and a Backgrounds theme extension providing gradients.
  - gradients.dart: multi-palette gradients (cosmic, aurora, neonBlue, neonPurple).
  - motion.dart: central durations/curves.
  - typography.dart: Sora text theme, tuned sizes and letter spacing.

- Shared Widgets:
  - AnimatedGradientBackground: full-screen animated gradient with neon glows, starfield, shooting star, shimmer sweep. Wraps screen bodies for ambiance.
  - GlassContainer: glassmorphism panel with backdrop blur, glow shadow, optional gradient border, and InkWell tap support.
  - SvgSymbol: central wrapper for SvgPicture.asset with color filter, semantics, and placeholder.
  - Shimmer + PurpleGlowShimmer: decorative shimmer effects (used in symbol buttons, etc.).
  - SymbolSelectionWidget: five animated buttons (the symbols). Calls onSymbolSelected(ZenerSymbol). Accessibility/semantics provided.
  - CardRevealWidget: 3D flip reveal of the current card with scaling and glow.
  - ScoreDisplayWidget: “Score: X / 25” chip.
  - FeedbackOverlay: large text overlay (“Hit!”/“Miss”) with bounce/opacity/scale animations, auto-dismiss.
  - FinalScoreDialog: score summary, descriptive chip, accuracy %, and optional “View Detailed Results” if provided gameResults.

- Haptics:
  - HapticFeedbackService: On correct guesses vibrates for 500ms where supported (uses vibration pkg). Incorrect guesses produce no vibration by design. All calls are safe and no-op on unsupported devices (web, etc.).


## 8) Game Flow Details
- Deck: 25 cards, 5 of each symbol, Fisher–Yates shuffle. One card per turn. GameState.currentCard indexes deck[currentTurn - 1].
- Turn cycle (ZenerGameScreen):
  1) User taps a symbol -> makeGuess.
  2) Immediately reveal card (flip) and present overlay “Hit!”/“Miss”; trigger haptics per outcome.
  3) Update score immediately on hits; slight 300ms delay for misses.
  4) After ~800ms overlay period, hide overlay, hide card, re-enable buttons.
  5) Increment turn; when 25 turns complete, wait ~1500ms, optionally show interstitial, navigate to results review.
- Results review/saving: ResultsReviewScreen constructs a GameSession via GameDataConverter and saves to local database on init; also tries inserting a high score (>=11) in Supabase (non-blocking).


## 9) Local Database Usage Patterns
- Save a session: GameDatabaseService.saveGameSession(GameSession) in a transaction, then inserts all TurnResults with the generated sessionId.
- Query sessions: getAllGameSessions(includeTurnResults?), pagination via getGameSessionsPaginated(limit, offset), getRecentGameSessions(limit), or by date range.
- Delete session: deleteGameSession(id) cascades to turn_results.
- Turn results queries: by session, by filters (isHit, turnNumber), replace all for a session with updateTurnResultsForSession.


## 10) Analytics and Charts
- GameStatisticsService.calculateStatistics() computes:
  - totalGames, averageScore, bestScore, totalTurns, totalHits, hitRate% = totalHits / totalTurns * 100
  - trends grouped daily/weekly/monthly (group date normalized, sorted desc). Aggregates average score and hit rate per period.
- GameStatisticsScreen renders:
  - Stat cards (Total Games, Best Score, Average Score, Hit Rate), hit-rate indicator vs expected 20%, insights copy, trend toggle chips, line charts for average score and hit rate (fl_chart), tips and labels. Empty and error states handled.


## 11) Navigation Contracts
- Named routes (see Section 2) and one generated route:
  - '/session-detail' expects settings.arguments as GameSession.
- Direct navigations:
  - ResultsReviewScreen uses pushNamedAndRemoveUntil('/', ...) for back to menu and pushNamedAndRemoveUntil('/zener-game', ...) for play again.
  - ZenerGameScreen pushReplacement to ResultsReviewScreen with parameters.
- All screens guard navigation in try/catch and show dialogs/snackbars on errors.


## 12) Assets and Fonts
- Assets (pubspec.yaml):
  - assets/zener/{circle.svg, plus.svg, waves.svg, square.svg, star.svg}
- Fonts: google_fonts (Sora) at runtime with fallbacks if blocked/unavailable.


## 13) Android/Web Platform Configs
- Android: app/src/main/AndroidManifest.xml
  - MainActivity exported true; Flutter embedding V2; AdMob test app ID meta-data included; queries allow ACTION_PROCESS_TEXT.
- Gradle: Kotlin 2.1.0, AGP 8.7.3, compile/target SDK via Flutter. NDK pinned. Release signs with debug by default (change for prod).
- Web: web/index.html bootstrap + PWA manifest with icons.


## 14) Dependencies (pubspec.yaml)
- flutter, cupertino_icons
- google_fonts, animations, flutter_animate, lottie, flutter_svg
- vibration
- supabase_flutter
- shared_preferences
- sqflite, path
- fl_chart
- google_mobile_ads
- dev: flutter_lints


## 15) Security/Secrets
- Supabase anon key in config is a public client key used by supabase_flutter. Replace with your own project keys for deployment. Never commit service-role or private keys. Consider environment-specific config management.
- Do not log PII; current usage logs errors only.


## 16) Extending the App (Guidelines)
- New game modes:
  - Add a controller similar to GameController or extend it; add a screen; register route; reuse widgets (CardRevealWidget, SymbolSelectionWidget) or create new ones.
  - Persist results: create corresponding database schema (new tables) and a service; or reuse existing if the turn/score model fits (25 turns, hits/misses).

- New persistence fields:
  - Update DatabaseConstants SQL, bump databaseVersion and implement _upgradeDatabase in DatabaseConfig (migrations). Update models’ toMap/fromMap and validation.

- Supabase integrations:
  - Add new tables and RLS policies on Supabase; extend HighScoresService or add a new service. Always guard on SupabaseService.isInitialized and handle failures quietly for non-critical UX.

- Ads:
  - Replace test IDs with real ones in AdService and AndroidManifest meta-data. Consider platform-conditional activation or consent flows as needed.

- Theming:
  - Add/adjust colors in AppTheme and AppGradients. Widgets rely on ColorScheme.* classes; keep good contrast.

- Accessibility:
  - Current widgets provide semantics labels. Continue adding semanticLabel, hints, and adequate touch target sizes.

- Error handling:
  - Follow existing try/catch patterns; show SnackBar or AlertDialog for user-visible failures; keep non-critical failures silent in release.


## 17) Build & Run
- Flutter 3.8 beta specified (sdk: ^3.8.0-278.1.beta). Use a compatible Flutter/Dart SDK.
- Run: flutter pub get; flutter run (choose device). For Android release, configure signing and replace AdMob IDs.


## 18) Known Constraints / Notes
- ResultsReviewScreen saves session on init; ensure duplicate navigation doesn’t cause multiple saves (guarding present via _isSaving/_saveCompleted flags).
- GameStatistics trends rely on loaded sessions with included turn results for hit-rate accuracy.
- Web: vibration not supported; HapticFeedbackService handles gracefully.
- Auth: minimal UI; no social providers; email/password only.


## 19) File Index (by feature)
- Entry & Theme
  - lib/main.dart
  - lib/theme/{app_theme.dart, gradients.dart, motion.dart, typography.dart}
- Game Core
  - lib/controllers/game_controller.dart
  - lib/models/{game_state.dart, guess_result.dart, turn_result.dart, zener_symbol.dart}
- Persistence (local)
  - lib/database/{database_config.dart, database_constants.dart, database_exceptions.dart}
  - lib/database/models/{game_session.dart, game_statistics.dart, turn_result.dart}
  - lib/database/services/{game_database_service.dart, game_statistics_service.dart}
  - lib/database/converters/game_data_converter.dart
- Remote
  - lib/config/supabase_config.dart
  - lib/services/{supabase_service.dart, high_scores_service.dart}
- Ads & Haptics
  - lib/services/{ad_service.dart, haptic_feedback_service.dart}
- Screens
  - lib/screens/{main_menu_screen.dart, zener_game_screen.dart, results_review_screen.dart,
    game_history_screen.dart, session_detail_screen.dart, game_statistics_screen.dart,
    stats_menu_screen.dart, auth_screen.dart}
- Widgets
  - lib/widgets/{animated_gradient_background.dart, glass_container.dart, svg_symbol.dart,
    shimmer.dart, symbol_selection_widget.dart, card_reveal_widget.dart,
    score_display_widget.dart, feedback_overlay_widget.dart, final_score_dialog.dart}
- Platform/Web
  - android/... (Manifests, Gradle)
  - web/{index.html, manifest.json}


## 20) Quick How-To Recipes
- Add a new route/screen:
  1) Create lib/screens/my_screen.dart.
  2) Register in MaterialApp.routes (lib/main.dart) or via onGenerateRoute if it needs args.
  3) Navigate with Navigator.pushNamed(context, '/my-screen').

- Save a finished game manually:
  1) Convert [[userGuess, correctAnswer]] via GameDataConverter.fromResultsReviewData(...).
  2) await GameDatabaseService.instance.saveGameSession(session).

- Compute statistics in code:
  - final stats = await GameStatisticsService().calculateStatistics();

- Insert a high score (>= 11):
  - await HighScoresService.instance.insertHighScore(score: 13);

- Show a banner ad in a widget:
  - final ad = AdService.createBanner(...); ad.load(); render via AdWidget.


---
This context is derived from the current repository state. If you update code, regenerate or annotate deltas. When you ask me to build features, include this file and any changes since it was produced.

