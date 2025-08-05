import 'package:flutter/material.dart';
import '../widgets/animated_gradient_background.dart';

class PerformanceMenuScreen extends StatelessWidget {
  const PerformanceMenuScreen({super.key});

  void _navigateToHistory(BuildContext context) {
    try {
      Navigator.pushNamed(context, '/game-history');
    } catch (e) {
      _showError(context, 'Failed to open history. Please try again.');
    }
  }

  void _navigateToStatistics(BuildContext context) {
    try {
      Navigator.pushNamed(context, '/game-statistics');
    } catch (e) {
      _showError(context, 'Failed to open statistics. Please try again.');
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        children: [
                          Text(
                            'Performance',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
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
                    const SizedBox(height: 16),

                    // Buttons Column
                    _buildSecondaryButton(
                      context: context,
                      icon: Icons.history,
                      title: 'History',
                      subtitle: 'Review past sessions',
                      onPressed: () => _navigateToHistory(context),
                    ),
                    const SizedBox(height: 20),
                    _buildSecondaryButton(
                      context: context,
                      icon: Icons.bar_chart,
                      title: 'Statistics',
                      subtitle: 'View performance analytics',
                      onPressed: () => _navigateToStatistics(context),
                    ),
                  ],
                ),
              ),
            ),
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
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    double buttonHeight;
    double horizontalPadding;
    double iconSize;
    double iconSpacing;

    if (screenWidth >= 800) {
      buttonHeight = 95.0;
      horizontalPadding = 32.0;
      iconSize = 32.0;
      iconSpacing = 24.0;
    } else if (screenWidth >= 600) {
      buttonHeight = 90.0;
      horizontalPadding = 28.0;
      iconSize = 30.0;
      iconSpacing = 22.0;
    } else {
      buttonHeight = 85.0;
      horizontalPadding = 24.0;
      iconSize = 28.0;
      iconSpacing = 20.0;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: buttonHeight),
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
            horizontal: horizontalPadding,
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
                size: iconSize,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            SizedBox(width: iconSpacing),
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
              Icons.arrow_forward_ios,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
