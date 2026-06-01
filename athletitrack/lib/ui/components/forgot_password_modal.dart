import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/services/api_client.dart';

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({super.key});

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSendingOtp = false;
  bool _isResetting = false;
  bool _otpSent = false;
  String? _error;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email.');
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _error = null;
    });

    try {
      final res = await ApiClient().dio.post('/forgot_password.php', data: {
        'email': email,
      });

      if (res.data['status'] == 'success') {
        setState(() {
          _otpSent = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message'])));
        }
      } else {
        setState(() => _error = res.data['message']);
      }
    } catch (e) {
      setState(() => _error = 'Failed to request reset. Check your connection.');
    } finally {
      setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (otp.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _error = 'Please fill out all fields.');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    if (newPassword.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters long.');
      return;
    }

    setState(() {
      _isResetting = true;
      _error = null;
    });

    try {
      final res = await ApiClient().dio.post('/reset_password.php', data: {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      });

      if (res.data['status'] == 'success') {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message']), backgroundColor: AppColors.success));
        }
      } else {
        setState(() => _error = res.data['message']);
      }
    } catch (e) {
      setState(() => _error = 'Failed to reset password. Check your connection.');
    } finally {
      setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !_otpSent ? _buildRequestStep() : _buildVerifyStep(),
        ),
      ),
    );
  }

  Widget _buildRequestStep() {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Forgot Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        const SizedBox(height: 16),
        const Text('Enter your registered email address to receive a password reset code.', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        if (_error != null) ...[
          Text(_error!, style: const TextStyle(color: AppColors.danger)),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email Address'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isSendingOtp ? null : _sendOtp,
          child: _isSendingOtp 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Send Code'),
        )
      ],
    );
  }

  Widget _buildVerifyStep() {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Verify & Reset', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text('We sent a 6-digit code to ${_emailController.text}. It expires in 10 minutes.', style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        if (_error != null) ...[
          Text(_error!, style: const TextStyle(color: AppColors.danger)),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _otpController,
          decoration: const InputDecoration(labelText: '6-Digit Code'),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: 'New Password',
            suffixIcon: IconButton(
              icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary),
              onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
          ),
          obscureText: _obscureNewPassword,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          obscureText: _obscureConfirmPassword,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isResetting ? null : _resetPassword,
          child: _isResetting 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Reset Password'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _otpSent = false;
              _error = null;
              _otpController.clear();
            });
          },
          child: const Text('Back to Email', style: TextStyle(color: AppColors.textSecondary)),
        )
      ],
    );
  }
}
