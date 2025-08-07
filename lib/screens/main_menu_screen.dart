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
                        padding: EdgeInsets.symmetric(
                          horizontal: _getResponsiveHorizontalPadding(
                            MediaQuery.of(context).size.width,
                          ),
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
                                style: _getResponsiveTitleStyle(
                                  context,
                                  theme,
                                  colorScheme,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: _getResponsiveTitleSpacing(
                                  MediaQuery.of(context).size.width,
                                ),
                              ),
                              // Subtitle
                              Text(
                                'Test Your Psychic Abilities',
                                style: _getResponsiveSubtitleStyle(
                                  context,
                                  theme,
                                  colorScheme,
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _getResponsiveHorizontalPadding(
                            MediaQuery.of(context).size.width,
                          ),
                        ),
                        child: const _ScoreboardsCard(),
                      ),
                      // Navigation Section - intrinsic height inside scroll view
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _getResponsiveHorizontalPadding(
                            MediaQuery.of(context).size.width,
                          ),
                        ),
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
                      Padding(
                        padding: EdgeInsets.all(
                          _getResponsiveFooterPadding(
                            MediaQuery.of(context).size.width,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 18,
                            ),
                            borderRadius: 14,
                            tintOpacity: 0.6,
                            borderGradient: LinearGradient(
                              colors: [
                                colorScheme.secondary.withValues(alpha: 0.8),
                                colorScheme.primary.withValues(alpha: 0.8),
                              ],
                            ),
                            borderWidth: 1.2,
                            child: Text(
                              'Explore the mysteries of the mind',
                              style: _getResponsiveFooterTextStyle(
                                context,
                                theme,
                                colorScheme,
                              )?.copyWith(letterSpacing: 0.4),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isTabletOrDesktop = screenWidth >= 600;
        final isLandscape = screenWidth > screenHeight;

        // Determine layout based on screen size and orientation
        final useHorizontalLayout =
            isTabletOrDesktop || (isLandscape && screenWidth >= 800);

        // Calculate responsive padding
        final horizontalPadding = _getResponsiveHorizontalPadding(screenWidth);
        final buttonSpacing = _getResponsiveButtonSpacing(screenWidth);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: useHorizontalLayout
              ? _buildHorizontalButtonLayout(context, buttonSpacing)
              : _buildVerticalButtonLayout(context, buttonSpacing),
        );
      },
    );
  }

  Widget _buildVerticalButtonLayout(BuildContext context, double spacing) {
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
        SizedBox(height: spacing),

        // My Games Menu Button (opens sub-menu with History & Statistics)
        _buildSecondaryButton(
          context: context,
          icon: Icons.insights,
          title: 'My Games',
          subtitle: 'History and Statistics',
          onPressed: () {
            Navigator.pushNamed(context, '/stats-menu');
          },
        ),
        SizedBox(height: spacing),

        // Authentication Button (Secondary)
        if (isSignedIn)
          _buildSecondaryButton(
            context: context,
            icon: Icons.person,
            title: userDisplayName ?? 'User',
            subtitle: 'Tap to sign out',
            onPressed: () => _handleSignOut(context),
          )
        else
          _buildSecondaryButton(
            context: context,
            icon: Icons.login,
            title: 'Sign In',
            subtitle: 'Save your scores',
            onPressed: () => _navigateToAuth(context),
          ),
      ],
    );
  }

  Widget _buildHorizontalButtonLayout(BuildContext context, double spacing) {
    final isSignedIn = SupabaseService.isSignedIn;
    final userDisplayName = SupabaseService.userDisplayName;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Zener Cards Button (Primary)
        Expanded(
          child: _buildPrimaryButton(
            context: context,
            icon: Icons.style,
            title: 'Zener Cards',
            subtitle: 'Test ESP with classic cards',
            onPressed: () => _navigateToZenerGame(context),
          ),
        ),
        SizedBox(width: spacing),

        // Performance Menu Button (opens sub-menu with History & Statistics)
        Expanded(
          child: _buildSecondaryButton(
            context: context,
            icon: Icons.insights,
            title: 'Performance',
            subtitle: 'History and Statistics',
            onPressed: () {
              Navigator.pushNamed(context, '/stats-menu');
            },
          ),
        ),
        SizedBox(width: spacing),

        // Authentication Button (Secondary)
        Expanded(
          child: isSignedIn
              ? _buildSecondaryButton(
                  context: context,
                  icon: Icons.person,
                  title: userDisplayName ?? 'User',
                  subtitle: 'Tap to sign out',
                  onPressed: () => _handleSignOut(context),
                )
              : _buildSecondaryButton(
                  context: context,
                  icon: Icons.login,
                  title: 'Sign In',
                  subtitle: 'Save your scores',
                  onPressed: () => _navigateToAuth(context),
                ),
        ),
      ],
    );
  }

  double _getResponsiveHorizontalPadding(double screenWidth) {
    if (screenWidth >= 1200) {
      return screenWidth * 0.2; // 20% padding on very large screens
    } else if (screenWidth >= 800) {
      return screenWidth * 0.15; // 15% padding on large screens
    } else if (screenWidth >= 600) {
      return 48.0; // Fixed padding for tablets
    } else {
      return 32.0; // Standard mobile padding
    }
  }

  double _getResponsiveButtonSpacing(double screenWidth) {
    if (screenWidth >= 800) {
      return 32.0; // Larger spacing for bigger screens
    } else if (screenWidth >= 600) {
      return 28.0; // Medium spacing for tablets
    } else {
      return 24.0; // Standard mobile spacing
    }
  }

  double _getResponsiveButtonHeight(double screenWidth) {
    if (screenWidth >= 800) {
      return 95.0; // Taller buttons for larger screens
    } else if (screenWidth >= 600) {
      return 90.0; // Medium height for tablets
    } else {
      return 85.0; // Increased height for mobile to prevent overflow
    }
  }

  double _getResponsiveButtonPadding(double screenWidth) {
    if (screenWidth >= 800) {
      return 32.0; // More padding for larger screens
    } else if (screenWidth >= 600) {
      return 28.0; // Medium padding for tablets
    } else {
      return 24.0; // Standard mobile padding
    }
  }

  double _getResponsiveIconSize(double screenWidth) {
    if (screenWidth >= 800) {
      return 32.0; // Larger icons for bigger screens
    } else if (screenWidth >= 600) {
      return 30.0; // Medium icons for tablets
    } else {
      return 28.0; // Standard mobile icons
    }
  }

  double _getResponsiveIconSpacing(double screenWidth) {
    if (screenWidth >= 800) {
      return 24.0; // More spacing for larger screens
    } else if (screenWidth >= 600) {
      return 22.0; // Medium spacing for tablets
    } else {
      return 20.0; // Standard mobile spacing
    }
  }

  TextStyle? _getResponsiveTitleStyle(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 800) {
      return theme.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
        letterSpacing: 1.2,
      );
    } else if (screenWidth >= 600) {
      return theme.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
        letterSpacing: 1.2,
      );
    } else {
      return theme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
        letterSpacing: 1.2,
      );
    }
  }

  TextStyle? _getResponsiveSubtitleStyle(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 800) {
      return theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w300,
        color: colorScheme.onSurface.withValues(alpha: 0.8),
        letterSpacing: 0.5,
      );
    } else if (screenWidth >= 600) {
      return theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w300,
        color: colorScheme.onSurface.withValues(alpha: 0.8),
        letterSpacing: 0.5,
      );
    } else {
      return theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w300,
        color: colorScheme.onSurface.withValues(alpha: 0.8),
        letterSpacing: 0.5,
      );
    }
  }

  double _getResponsiveTitleSpacing(double screenWidth) {
    if (screenWidth >= 800) {
      return 20.0; // More spacing for larger screens
    } else if (screenWidth >= 600) {
      return 18.0; // Medium spacing for tablets
    } else {
      return 16.0; // Standard mobile spacing
    }
  }

  double _getResponsiveFooterPadding(double screenWidth) {
    if (screenWidth >= 800) {
      return 32.0; // More padding for larger screens
    } else if (screenWidth >= 600) {
      return 28.0; // Medium padding for tablets
    } else {
      return 24.0; // Standard mobile padding
    }
  }

  TextStyle? _getResponsiveFooterTextStyle(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 800) {
      return theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        fontStyle: FontStyle.italic,
      );
    } else if (screenWidth >= 600) {
      return theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        fontStyle: FontStyle.italic,
      );
    } else {
      return theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        fontStyle: FontStyle.italic,
      );
    }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonHeight = _getResponsiveButtonHeight(screenWidth);

    // Prevent text overflow by allowing subtitle to wrap and using flexible layout.
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: buttonHeight),
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
            padding: EdgeInsets.symmetric(
              horizontal: _getResponsiveButtonPadding(screenWidth),
              vertical: 12,
            ),
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
                child: Icon(
                  icon,
                  size: _getResponsiveIconSize(screenWidth),
                  color: colorScheme.onPrimary,
                ),
              ),
              SizedBox(width: _getResponsiveIconSpacing(screenWidth)),
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
                Icons.arrow_forward_ios,
                color: colorScheme.onPrimary.withValues(alpha: 0.7),
                size: 20,
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
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonHeight = _getResponsiveButtonHeight(screenWidth);

    // Prevent overflow in secondary buttons as well.
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: buttonHeight),
      child: Semantics(
        label: '$title - $subtitle',
        button: true,
        enabled: onPressed != null,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.5),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: _getResponsiveButtonPadding(screenWidth),
              vertical: 12,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: _getResponsiveIconSize(screenWidth),
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              SizedBox(width: _getResponsiveIconSpacing(screenWidth)),
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
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
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
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                SupabaseService.isSignedIn
                    ? Icons.logout
                    : Icons.arrow_forward_ios,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: 20,
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
              Icon(icon, color: effectiveColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: effectiveColor,
                  letterSpacing: 0.8,
                ),
              ),
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

  const _ScoreTile({
    required this.label,
    required this.primaryText,
    required this.secondaryText,
    required this.icon,
    required this.accent,
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
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent.withValues(alpha: 0.85),
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
