import 'package:flutter/material.dart';
import 'auth_screen.dart';
import '../services/supabase_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

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

  /// Navigate to Game Statistics Screen with error handling
  void _navigateToGameStatistics(BuildContext context) {
    try {
      Navigator.pushNamed(context, '/game-statistics');
    } catch (e) {
      // Log error and show user-friendly message
      debugPrint('Navigation to Game Statistics failed: $e');
      _showErrorDialog(
        context,
        'Failed to open game statistics. Please try again.',
      );
    }
  }

  /// Navigate to Game History Screen with error handling
  void _navigateToGameHistory(BuildContext context) {
    try {
      Navigator.pushNamed(context, '/game-history');
    } catch (e) {
      // Log error and show user-friendly message
      debugPrint('Navigation to Game History failed: $e');
      _showErrorDialog(
        context,
        'Failed to open game history. Please try again.',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          // Use a Stack so we can anchor the banner to the bottom safely
          child: Stack(
            children: [
              // Main content with extra bottom padding so content doesn't hide under the ad
              Padding(
                padding: EdgeInsets.only(
                  bottom: bannerHeight > 0 ? bannerHeight + 12 : 0,
                ),
                child: Column(
                  children: [
                    // Header Section (Top 25%)
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: _getResponsiveHorizontalPadding(
                            MediaQuery.of(context).size.width,
                          ),
                          vertical: 16.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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

                    // Navigation Section (Middle 60%)
                    Expanded(
                      flex: 5,
                      child: _buildResponsiveNavigationSection(context),
                    ),

                    // Footer text only (banner is handled separately)
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.all(
                          _getResponsiveFooterPadding(
                            MediaQuery.of(context).size.width,
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'Explore the mysteries of the mind',
                          style: _getResponsiveFooterTextStyle(
                            context,
                            theme,
                            colorScheme,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
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

        // Game History Button
        _buildSecondaryButton(
          context: context,
          icon: Icons.history,
          title: 'Game History',
          subtitle: 'Review past sessions',
          onPressed: () => _navigateToGameHistory(context),
        ),
        SizedBox(height: spacing),

        // Game Statistics Button
        _buildSecondaryButton(
          context: context,
          icon: Icons.bar_chart,
          title: 'Statistics',
          subtitle: 'View your game stats',
          onPressed: () => _navigateToGameStatistics(context),
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

        // Game History Button
        Expanded(
          child: _buildSecondaryButton(
            context: context,
            icon: Icons.history,
            title: 'Game History',
            subtitle: 'Review past sessions',
            onPressed: () => _navigateToGameHistory(context),
          ),
        ),
        SizedBox(width: spacing),

        // Game Statistics Button
        Expanded(
          child: _buildSecondaryButton(
            context: context,
            icon: Icons.bar_chart,
            title: 'Statistics',
            subtitle: 'View your game stats',
            onPressed: () => _navigateToGameStatistics(context),
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

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
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

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: Semantics(
        label: '$title - $subtitle',
        button: true,
        enabled: onPressed != null,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: _getResponsiveIconSize(screenWidth),
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(width: _getResponsiveIconSpacing(screenWidth)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                SupabaseService.isSignedIn
                    ? Icons.logout
                    : Icons.arrow_forward_ios,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
