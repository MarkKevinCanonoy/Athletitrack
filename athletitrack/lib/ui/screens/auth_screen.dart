import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../components/common_components.dart';
import '../components/forgot_password_modal.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isLogin = true;
  bool _obscurePassword = true;
  String selectedRole = 'Athlete'; // Default role for registration
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    final auth = ref.read(authProvider.notifier);
    auth.clearError();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    if (isLogin) {
      final success = await auth.login(email, password);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged in.')),
        );
      }
    } else {
      final name = _nameController.text.trim();
      if (name.isEmpty) return;
      
      final success = await auth.register(name, email, password, selectedRole);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered! Please verify your email.')),
        );
        context.go('/otp'); // Navigate to OTP screen for verification
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BRANDING HEADER
                  Text(
                    'AthletiTrack',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primary,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ATHLETE TRAINING SYSTEM',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // LOGIN CARD
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey(isLogin),
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              isLogin ? 'Welcome Back' : 'Create Account',
                              style: Theme.of(context).textTheme.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            if (authState.error != null) ...[
                              Text(
                                authState.error!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (!isLogin) ...[
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Full Name'),
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(labelText: 'Email Address'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            if (!isLogin) ...[
                              DropdownButtonFormField<String>(
                                value: selectedRole,
                                decoration: const InputDecoration(labelText: 'Role'),
                                items: ['Athlete', 'Coach']
                                    .map((role) => DropdownMenuItem(
                                          value: role,
                                          child: Text(role),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => selectedRole = val);
                                },
                                dropdownColor: AppColors.surface,
                              ),
                              const SizedBox(height: 16),
                              ],
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                              ),
                              const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: authState.isLoading ? null : _submit,
                              child: authState.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(isLogin ? 'Login' : 'Register'),
                            ),
                            const SizedBox(height: 16),
                            if (isLogin)
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => const ForgotPasswordModal(),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            const SizedBox(height: 8),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                                ref.read(authProvider.notifier).clearError();
                              },
                              child: Text(
                                isLogin ? 'Need an account? Register' : 'Already have an account? Login',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
