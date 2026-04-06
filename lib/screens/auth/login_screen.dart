import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raksh_health/config/app_theme.dart';
import 'package:raksh_health/widgets/glass_container.dart';
import 'package:raksh_health/screens/auth/otp_screen.dart';
import 'package:raksh_health/repositories/auth_repository.dart';
import 'package:raksh_health/utils/ui_utils.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      context.showSnackBar('Please enter a phone number', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final phoneNumber = '+91${_phoneController.text.trim()}';
      await ref.read(authRepositoryProvider).signInWithPhone(phoneNumber);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(phoneNumber: phoneNumber),
          ),
        );
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Login failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A0F1E), Color(0xFF1A1F3D), Color(0xFF0A0F1E)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Raksh Health',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: AppTheme.secondaryColor,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Step into the future of healthcare.',
                    style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 60),
                  GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Secure Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 24),
                        const Text('Phone Number', style: TextStyle(fontSize: 14, color: Colors.white60)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              child: Text(
                                '+91',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                              ),
                            ),
                            hintText: '888 888 8888',
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Send Secure OTP'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: () async {
                      try {
                        await ref.read(authRepositoryProvider).signInWithGoogle();
                      } catch (e) {
                         if (mounted) context.showSnackBar('Google Sign-in failed: $e', isError: true);
                      }
                    },
                    child: GlassContainer(
                      padding: const EdgeInsets.all(4),
                      borderRadius: 28,
                      opacity: 0.05,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login, color: Colors.white70),
                          const SizedBox(width: 12),
                          const Text('Continue with Google', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  const Center(
                    child: Text(
                      'Your data is private and encrypted.',
                      style: TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.w300),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
