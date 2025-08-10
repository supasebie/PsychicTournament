import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// Authentication screen for sign in and sign up
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  /// Handle authentication (sign in or sign up)
  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if Supabase is initialized
    if (!SupabaseService.isInitialized) {
      _showErrorMessage(
        'Authentication service is not available. Please try again later.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      AuthResponse response;

      if (_isSignUp) {
        response = await SupabaseService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim().isEmpty
              ? null
              : _displayNameController.text.trim(),
        );

        if (response.user != null) {
          if (mounted) {
            _showSuccessMessage(
              'Account created successfully! Please check your email to verify your account.',
            );
          }
        }
      } else {
        response = await SupabaseService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null && mounted) {
          Navigator.of(context).pop(); // Return to main menu
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showErrorMessage(e.message);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An unexpected error occurred. Please try again.';
        if (e.toString().contains('not initialized')) {
          errorMessage =
              'Authentication service is not available. Please check your internet connection and try again.';
        }
        _showErrorMessage(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle password reset
  Future<void> _handlePasswordReset() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your email address first.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.resetPassword(_emailController.text.trim());
      if (mounted) {
        _showSuccessMessage('Password reset email sent! Check your inbox.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(
          'Failed to send password reset email. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// Email validator
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Password validator
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Display name validator
  String? _validateDisplayName(String? value) {
    if (_isSignUp && (value == null || value.trim().isEmpty)) {
      return 'Display name is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Welcome text
                Text(
                  _isSignUp ? 'Join the Tournament' : 'Welcome Back',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  _isSignUp
                      ? 'Create an account to save your psychic scores'
                      : 'Sign in to continue your psychic journey',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Display name field (only for sign up)
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter your display name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: _validateDisplayName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleAuth(),
                ),

                const SizedBox(height: 24),

                // Auth button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isSignUp ? 'Create Account' : 'Sign In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Forgot password (only for sign in)
                if (!_isSignUp)
                  TextButton(
                    onPressed: _isLoading ? null : _handlePasswordReset,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Toggle between sign in and sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp
                          ? 'Already have an account? '
                          : "Don't have an account? ",
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                              });
                            },
                      child: Text(
                        _isSignUp ? 'Sign In' : 'Sign Up',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
