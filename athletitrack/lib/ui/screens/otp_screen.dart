import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../components/common_components.dart';
import '../../core/providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  void _verifyOtp() async {
    final auth = ref.read(authProvider.notifier);
    final success = await auth.verifyOtp(_otpController.text.trim());
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification successful! Logging you in...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter OTP',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A 6-digit code has been sent to your email.',
                        style: Theme.of(context).textTheme.bodyMedium,
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
                      TextField(
                        controller: _otpController,
                        enabled: !authState.isInCooldown,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall,
                        decoration: const InputDecoration(
                          hintText: '000000',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: (authState.isLoading || authState.isInCooldown) ? null : _verifyOtp,
                        child: authState.isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Verify'),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: (authState.isLoading || authState.isInCooldown) ? null : () async {
                          final success = await ref.read(authProvider.notifier).resendOtp();
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('A new OTP has been sent to your email.')),
                            );
                          }
                        },
                        child: Text('Resend OTP', style: TextStyle(color: (authState.isLoading || authState.isInCooldown) ? Colors.grey : AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
