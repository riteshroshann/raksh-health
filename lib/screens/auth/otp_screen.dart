import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raksh_health/config/app_theme.dart';
import 'package:raksh_health/widgets/glass_container.dart';
import 'package:raksh_health/repositories/auth_repository.dart';
import 'package:raksh_health/repositories/profile_repository.dart';
import 'package:raksh_health/utils/ui_utils.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
       if (mounted) context.showSnackBar('Please enter all 6 digits', isError: true);
       return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ref.read(authRepositoryProvider).verifyOTP(
        widget.phoneNumber,
        otp,
      );
      
      final user = response.user;
      if (user != null) {
        final profileRepo = ref.read(profileRepositoryProvider);
        final existingProfile = await profileRepo.getProfile(user.id);
        
        if (existingProfile == null) {
          await profileRepo.createProfile(
            authId: user.id,
            fullName: 'Raksh User',
            phoneNumber: widget.phoneNumber,
          );
        }
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Verification failed: $e', isError: true);
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
                   const Text('Verification Code', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                   const SizedBox(height: 12),
                   Text('Verification code sent to ${widget.phoneNumber}', style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w300)),
                   const SizedBox(height: 60),
                   GlassContainer(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 45,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(counterText: '', contentPadding: EdgeInsets.zero, border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    if (index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else {
                                      _focusNodes[index].unfocus();
                                      _verifyOtp();
                                    }
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 48),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                            child: _isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Verify Account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      children: [
                        Text(_secondsRemaining > 0 ? 'Resend OTP in 0:${_secondsRemaining.toString().padLeft(2, '0')}' : "Didn't receive the code?", style: const TextStyle(color: Colors.white60)),
                        if (_secondsRemaining == 0)
                          TextButton(
                            onPressed: () async {
                              try {
                                await ref.read(authRepositoryProvider).signInWithPhone(widget.phoneNumber);
                                if (!mounted) return;
                                _startTimer();
                                if (context.mounted) {
                                  context.showSnackBar('OTP Resent');
                                }
                              } catch (e) {
                                if (mounted) {
                                  context.showSnackBar('Resend failed: $e', isError: true);
                                }
                              }
                            },
                            child: const Text('Resend Secure OTP', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
                          ),
                      ],
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
