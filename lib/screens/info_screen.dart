import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/animated_gradient_background.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  late Future<String> _mdFuture;

  @override
  void initState() {
    super.initState();
    _mdFuture = rootBundle.loadString('StatsData.md');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header styled similar to Performance/Options
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        children: [
                          Text(
                            'Information',
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
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: _mdFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Failed to load content',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          );
                        }
                        final data = snapshot.data ?? '# Info\nNo content available.';
                        return MarkdownBody(
                          data: data,
                          selectable: false,
                          styleSheet: MarkdownStyleSheet(
                            h1: theme.textTheme.headlineMedium,
                            h2: theme.textTheme.titleLarge,
                            h3: theme.textTheme.titleMedium,
                            p: theme.textTheme.bodyMedium,
                            codeblockDecoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                            blockquoteDecoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                              border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
                            ),
                            tableBorder: TableBorder.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                            tableHead: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            a: TextStyle(color: colorScheme.secondary),
                            listBullet: theme.textTheme.bodyMedium,
                          ),
                        );
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
