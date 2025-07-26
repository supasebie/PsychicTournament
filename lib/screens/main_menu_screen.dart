import 'package:flutter/material.dart';
import 'zener_game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  /// Navigate to Zener Game Screen with error handling
  void _navigateToZenerGame(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ZenerGameScreen()),
      );
    } catch (e) {
      // Log error and show user-friendly message
      debugPrint('Navigation to Zener Game failed: $e');
      _showErrorDialog(
        context,
        'Failed to start Zener Cards game. Please try again.',
      );
    }
  }

  /// Show coming soon dialog for placeholder features
  void _showComingSoonDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.construction, color: colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Coming Soon',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'More psychic games are under development!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming Features:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(context, '🔮', 'Crystal Ball Reading'),
                    _buildFeatureItem(context, '🃏', 'Tarot Card Divination'),
                    _buildFeatureItem(context, '🌟', 'Aura Color Detection'),
                    _buildFeatureItem(context, '🎯', 'Remote Viewing Tests'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Got it!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build a feature item for the coming soon dialog
  Widget _buildFeatureItem(BuildContext context, String emoji, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
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

              // Footer Section (Bottom 15%)
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(
                    _getResponsiveFooterPadding(
                      MediaQuery.of(context).size.width,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Explore the mysteries of the mind',
                        style: _getResponsiveFooterTextStyle(
                          context,
                          theme,
                          colorScheme,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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

        // Coming Soon Button (Secondary)
        _buildSecondaryButton(
          context: context,
          icon: Icons.lock_clock,
          title: 'More Games',
          subtitle: 'Coming Soon',
          onPressed: () => _showComingSoonDialog(context),
        ),
      ],
    );
  }

  Widget _buildHorizontalButtonLayout(BuildContext context, double spacing) {
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

        // Coming Soon Button (Secondary)
        Expanded(
          child: _buildSecondaryButton(
            context: context,
            icon: Icons.lock_clock,
            title: 'More Games',
            subtitle: 'Coming Soon',
            onPressed: () => _showComingSoonDialog(context),
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
                Icons.schedule,
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
