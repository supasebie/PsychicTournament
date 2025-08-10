import 'package:flutter/material.dart';
import 'auth_screen.dart';
import '../services/supabase_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';
import '../services/high_scores_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    // Create and load a standard banner at init. We render it in the footer if loaded.
    final banner = AdService.createBanner(
      size: AdSize.banner,
      onAdLoaded: (ad) {
        if (!mounted) return;
        setState(() {
          _bannerAd = ad as BannerAd;
          _isBannerLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        // Already disposed in AdService listener; just mark as not loaded.
        if (!mounted) return;
        setState(() {
          _bannerAd = null;
          _isBannerLoaded = false;
        });
        debugPrint('Main menu banner failed to load: $error');
      },
    );
    _bannerAd = banner;
    banner.load();
  }

  @override
  void dispose() {
    try {
      _bannerAd?.dispose();
    } catch (_) {}
    super.dispose();
  }

  /// Navigate to authentication screen
  void _navigateToAuth(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } catch (e) {
      debugPrint('Navigation to Auth failed: $e');
      _showErrorDialog(
        context,
        'Failed to open authentication screen. Please try again.',
      );
    }
  }

  /// Handle sign out
  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await SupabaseService.signOut();
      if (mounted) {
        setState(() {}); // Refresh the UI
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed out successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        _showErrorDialog(context, 'Failed to sign out. Please try again.');
      }
    }
  }

  /// Navigate to Zener Game Screen with error handling
  void _navigateToZenerGame(BuildContext context) {
    try {
      Navigator.pushNamed(context, '/zener-game');
    } catch (e) {
      // Log error and show user-friendly message
      debugPrint('Navigation to Zener Game failed: $e');
      _showErrorDialog(
        context,
        'Failed to start Zener Cards game. Please try again.',
      );
    }
  }

  /// Show error dialog for navigation failures
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Reserve bottom padding when banner is loaded to prevent overlap
    final double bannerHeight = (_isBannerLoaded && _bannerAd != null)
        ? _bannerAd!.size.height.toDouble()
        : 0.0;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          // Use a Stack so we can anchor the banner to the bottom safely
          child: Stack(
            children: [
              // Main content with extra bottom padding so content doesn't hide under the ad
              // Wrap in SingleChildScrollView to prevent overflows on small screens.
              Padding(
                padding: EdgeInsets.only(
                  bottom: bannerHeight > 0 ? bannerHeight + 12 : 0,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Header Section → Glass panel (no Expanded inside scroll)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 16.0,
                        ),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          borderGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.9),
                              colorScheme.secondary.withValues(alpha: 0.9),
                            ],
                          ),
                          borderWidth: 1.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // App Title
                              Text(
                                'Psychic Tournament',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              // Subtitle
                              Text(
                                'Test Your Psychic Abilities',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.8,
                                  ),
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              // Decorative element
                              Container(
                                width: 80,
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary,
                                      colorScheme.secondary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Scoreboards Section
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: _ScoreboardsCard(),
                      ),
                      // Navigation Section - intrinsic height inside scroll view
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: 20,
                          tintOpacity: 0.65,
                          borderGradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.75),
                              colorScheme.secondary.withValues(alpha: 0.75),
                            ],
                          ),
                          child: _buildResponsiveNavigationSection(context),
                        ),
                      ),
                      // Footer text (chip) - intrinsic height
                      // Padding(
                      //   padding: const EdgeInsets.all(24.0),
                      //   child: Align(
                      //     alignment: Alignment.bottomCenter,
                      //     child: GlassContainer(
                      //       padding: const EdgeInsets.symmetric(
                      //         vertical: 12,
                      //         horizontal: 18,
                      //       ),
                      //       borderRadius: 14,
                      //       tintOpacity: 0.6,
                      //       borderGradient: LinearGradient(
                      //         colors: [
                      //           colorScheme.secondary.withValues(alpha: 0.8),
                      //           colorScheme.primary.withValues(alpha: 0.8),
                      //         ],
                      //       ),
                      //       borderWidth: 1.2,
                      //       child: Text(
                      //         'Explore the mysteries of the mind',
                      //         style: theme.textTheme.bodySmall?.copyWith(
                      //           color: colorScheme.onSurface.withValues(alpha: 0.6),
                      //           fontStyle: FontStyle.italic,
                      //           letterSpacing: 0.4,
                      //         ),
                      //         textAlign: TextAlign.center,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),

              // Bottom-anchored banner ad
              if (_isBannerLoaded && _bannerAd != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    left: false,
                    right: false,
                    child: Center(
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveNavigationSection(BuildContext context) {
    final isSignedIn = SupabaseService.isSignedIn;
    final userDisplayName = SupabaseService.userDisplayName;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Zener Cards Button (Primary)
        _buildPrimaryButton(
          context: context,
          icon: Icons.style,
          title: 'Zener Cards',
          subtitle: 'Test ESP with classic cards',
          onPressed: () => _navigateToZenerGame(context),
        ),
        const SizedBox(height: 24),

        // My Games Menu Button (opens sub-menu with History & Statistics)
        _buildSecondaryButton(
          context: context,
          icon: Icons.insights,
          title: 'My Games',
          subtitle: 'History and Statistics',
          onPressed: () {
            Navigator.pushNamed(context, '/stats-menu');
          },
          containerColor: Theme.of(context).colorScheme.secondaryContainer,
          onContainerColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        const SizedBox(height: 24),

        // Options Button (Secondary) -> navigates to Options screen
        _buildSecondaryButton(
          context: context,
          icon: Icons.settings,
          title: 'Options',
          subtitle: 'Account / scores etc.',
          onPressed: () {
            Navigator.pushNamed(context, '/options');
          },
          containerColor: Theme.of(context).colorScheme.tertiaryContainer,
          onContainerColor: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Prevent text overflow by allowing subtitle to wrap and using flexible layout.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 85),
      child: Semantics(
        label: '$title - $subtitle',
        button: true,
        enabled: onPressed != null,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 4,
            shadowColor: colorScheme.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: colorScheme.onPrimary),
              ),
              const SizedBox(width: 20),
              // Let the text wrap and avoid overflow
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.2,
                        color: colorScheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onPrimary.withValues(alpha: 0.9),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onPressed,
    Color? containerColor,
    Color? onContainerColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color bg = containerColor ?? colorScheme.secondaryContainer;
    final Color fg = onContainerColor ?? colorScheme.onSecondaryContainer;

    // Prevent overflow in secondary buttons as well.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 85),
      child: Semantics(
        label: '$title - $subtitle',
        button: true,
        enabled: onPressed != null,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            side: BorderSide(
              color: fg.withValues(alpha: 0.3),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: fg.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: fg.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.2,
                        color: fg.withValues(alpha: 0.75),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: fg.withValues(alpha: 0.9),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scoreboards card showing today's top and this month's top scores.
/// Uses UTC boundaries as defined by HighScoresService.
class _ScoreboardsCard extends StatelessWidget {
  const _ScoreboardsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.25),
            colorScheme.secondary.withValues(alpha: 0.25),
            colorScheme.tertiary.withValues(alpha: 0.20),
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: GlassContainer(
        borderRadius: 22,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        tintOpacity: 0.55,
        borderGradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.6),
            colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _ScoreSectionHeader(
              icon: Icons.emoji_events,
              title: 'Leaderboard',
              color: null,
            ),
            SizedBox(height: 14),
            _TodayTopTile(),
            SizedBox(height: 10),
            _MonthTopTile(),
          ],
        ),
      ),
    );
  }
}

class _ScoreSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;

  const _ScoreSectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Centered "Leaderboard" chip with accent gradient and subtle glow
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                effectiveColor.withValues(alpha: 0.22),
                effectiveColor.withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(
              color: effectiveColor.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveColor.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy icon in gold with a subtle glow
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFD700), // gold
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              // Glowing, animated purple text (non-gradient, alternating hues)
              _FirePurpleGlowText(title: title),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayTopTile extends StatelessWidget {
  const _TodayTopTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: HighScoresService.instance.fetchTopScoreToday(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ScoreTileSkeleton(label: 'Today');
        }
        final data = snapshot.data ?? const [];
        if (snapshot.hasError) {
          return const _ScoreTileError(label: 'Today');
        }
        if (data.isEmpty) {
          return _ScoreTile(
            label: 'Today',
            primaryText: 'Be the first to score over 10',
            secondaryText: null,
            icon: Icons.wb_sunny,
            accent: colorScheme.tertiary,
            leading: const _AnimatedSunIcon(size: 22),
          );
        }
        final row = data.first;
        final username = (row['username'] as String?) ?? 'Anon';
        final score = (row['score'] as int?) ?? 0;
        return _ScoreTile(
          label: 'Today',
          primaryText: '$score points',
          secondaryText: 'by $username',
          icon: Icons.wb_sunny,
          accent: colorScheme.primary,
          leading: const _AnimatedSunIcon(size: 22),
        );
      },
    );
  }
}

class _MonthTopTile extends StatelessWidget {
  const _MonthTopTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: HighScoresService.instance.fetchTopScoreThisMonth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ScoreTileSkeleton(label: 'This Month');
        }
        if (snapshot.hasError) {
          return const _ScoreTileError(label: 'This Month');
        }
        final data = snapshot.data ?? const [];
        if (data.isEmpty) {
          return _ScoreTile(
            label: 'This Month',
            primaryText: 'No monthly scores yet',
            secondaryText: null,
            icon: Icons.calendar_today,
            accent: colorScheme.secondary,
            leading: const _AnimatedCalendarIcon(size: 22),
          );
        }
        final top = data.first;
        final username = (top['username'] as String?) ?? 'Anon';
        final score = (top['score'] as int?) ?? 0;
        return _ScoreTile(
          label: 'This Month',
          primaryText: '$score points',
          secondaryText: 'by $username',
          icon: Icons.calendar_today,
          accent: colorScheme.secondary,
          leading: const _AnimatedCalendarIcon(size: 22),
        );
      },
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final String label;
  final String primaryText;
  final String? secondaryText;
  final IconData icon;
  final Color accent;
  final Widget? leading; // optional custom leading widget (overrides icon)

  const _ScoreTile({
    required this.label,
    required this.primaryText,
    required this.secondaryText,
    required this.icon,
    required this.accent,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth >= 600 ? 16 : 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.12),
            accent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 12,
            spreadRadius: 0.5,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.22),
                  accent.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accent.withValues(alpha: 0.45),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: leading ?? Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFFFD700), // gold
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  primaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface.withValues(alpha: 0.95),
                  ),
                ),
                if (secondaryText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    secondaryText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreTileSkeleton extends StatelessWidget {
  final String label;
  const _ScoreTileSkeleton({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: 0.7,
      child: _ScoreTile(
        label: label,
        primaryText: 'Loading…',
        secondaryText: null,
        icon: Icons.hourglass_bottom,
        accent: colorScheme.primary.withValues(alpha: 0.7),
      ),
    );
  }
}

class _ScoreTileError extends StatelessWidget {
  final String label;
  const _ScoreTileError({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _ScoreTile(
      label: label,
      primaryText: 'Unable to load',
      secondaryText: null,
      icon: Icons.error_outline,
      accent: colorScheme.error.withValues(alpha: 0.9),
    );
  }
}

/// Animated calendar icon with a subtle page-flip and purple glow.
class _AnimatedCalendarIcon extends StatefulWidget {
  final double size;
  const _AnimatedCalendarIcon({super.key, this.size = 24});

  @override
  State<_AnimatedCalendarIcon> createState() => _AnimatedCalendarIconState();
}

class _AnimatedCalendarIconState extends State<_AnimatedCalendarIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const Color _purpleA = Color(0xFFB388FF);
  static const Color _purpleB = Color(0xFF7C4DFF);
  static const double _pi = 3.141592653589793;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value; // 0..1 repeating
        // Flip during first 18% of the cycle, otherwise rest.
        double angle;
        double flipPhase;
        if (t < 0.18) {
          flipPhase = t / 0.18; // 0..1
          angle = Curves.easeInOut.transform(flipPhase) * _pi;
        } else if (t > 0.82) {
          // Flip back near the end for symmetry
          flipPhase = (1.0 - t) / 0.18; // 0..1
          angle = Curves.easeInOut.transform(flipPhase) * _pi;
        } else {
          angle = 0.0;
        }

        // Pulse color between two purples for a cool glow
        final color = Color.lerp(_purpleA, _purpleB, (t * 2) % 1.0);

        return Container(
          width: widget.size + 10,
          height: widget.size + 10,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (color ?? _purpleA).withValues(alpha: 0.45),
                blurRadius: 10,
                spreadRadius: 1.5,
              ),
            ],
          ),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(angle > _pi / 2 ? _pi : 0),
              child: Icon(
                Icons.calendar_today,
                color: color,
                size: widget.size,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Simple animated yellow-orange sun icon: rotates gently and pulses color.
class _AnimatedSunIcon extends StatefulWidget {
  final double size;
  const _AnimatedSunIcon({super.key, this.size = 24});

  @override
  State<_AnimatedSunIcon> createState() => _AnimatedSunIconState();
}

class _AnimatedSunIconState extends State<_AnimatedSunIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const Color _sunYellow = Color(0xFFFFEB3B); // bright yellow
  static const Color _sunOrange = Color(0xFFFFA000); // deep orange

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Rotate continuously
        final angle = _controller.value * 6.283185307179586; // 2*pi
        // Pulse color between yellow and orange
        final t = (0.5 - (0.5 - _controller.value).abs()) * 2.0; // 0->1->0 triangle
        final color = Color.lerp(_sunYellow, _sunOrange, t);

        return Transform.rotate(
          angle: angle,
          child: Container(
            width: widget.size + 10,
            height: widget.size + 10,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (color ?? _sunYellow).withValues(alpha: 0.45),
                  blurRadius: 10,
                  spreadRadius: 1.5,
                ),
              ],
            ),
            child: Icon(
              Icons.wb_sunny,
              color: color,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}

/// Animated glowing text that alternates between two purple hues (no gradients).
class _FirePurpleGlowText extends StatefulWidget {
  final String title;
  final Duration duration;
  const _FirePurpleGlowText({
    required this.title,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<_FirePurpleGlowText> createState() => _FirePurpleGlowTextState();
}

class _FirePurpleGlowTextState extends State<_FirePurpleGlowText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Two rich purple hues to alternate between
  static const Color _purpleA = Color(0xFFB388FF); // light vibrant purple
  static const Color _purpleB = Color(0xFF7C4DFF); // deeper purple

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Create a smooth ping-pong between the two colors
        final t = _controller.value;
        final color = Color.lerp(_purpleA, _purpleB, t) ?? _purpleA;

        // Strong outer glow using multiple shadows with increasing blur
        final shadows = [
          Shadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 6,
            offset: const Offset(0, 0),
          ),
          Shadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 0),
          ),
          Shadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ];

        return Text(
          widget.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.8,
            shadows: shadows,
          ),
        );
      },
    );
  }
}
