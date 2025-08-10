import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../database/services/game_database_service.dart';
import '../widgets/animated_gradient_background.dart';
import 'auth_screen.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  Future<void> _resetLocalScores(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      await GameDatabaseService.instance.resetDatabase();
      scaffold.showSnackBar(
        const SnackBar(content: Text('Local scores reset successfully')),
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Failed to reset scores: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSignedIn = SupabaseService.isSignedIn;

    return Scaffold(
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
                    // Header styled like Performance menu
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        children: [
                          Text(
                            'Options',
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

                    // Buttons styled like _buildSecondaryButton in Performance menu
                    _OptionsMenuButton(
                      icon: isSignedIn ? Icons.logout : Icons.login,
                      title: isSignedIn ? 'Sign Out' : 'Sign In',
                      subtitle: isSignedIn
                          ? 'Sign out of your account'
                          : 'Sign in to sync and save scores',
                      onPressed: () async {
                        if (isSignedIn) {
                          await SupabaseService.signOut();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Signed out')),
                          );
                        } else {
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const AuthScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    _OptionsMenuButton(
                      icon: Icons.delete_forever,
                      title: 'Reset scores',
                      subtitle: 'Delete all local game data on this device',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Reset scores?'),
                            content: const Text(
                              'This will delete all local game sessions and scores stored on this device. This will not reset leaderboard scores! This cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _resetLocalScores(context);
                        }
                      },
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
}

class _OptionsMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _OptionsMenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
