import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.premiumBlack,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C1F26), Color(0xFF0F1115)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Logo Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 48),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ATOMIC HABITS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Master your daily routine',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 80),
                
                // Form Section & Content Constrained for Web
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Your Name',
                        icon: Icons.person_rounded,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                             if (_nameController.text.isNotEmpty) {
                                ref.read(userNameProvider.notifier).saveName(_nameController.text.trim());
                                ref.read(authControllerProvider.notifier).signInAnonymously();
                              } else {
                                // Optional: Show snackbar "Please enter your name"
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter your name to start')),
                                );
                              }
                          },
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Text(
                                  'Get Started',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w600, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 22),
        ),
      ),
    );
  }
}
