import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raksh_health/config/app_theme.dart';
import 'package:raksh_health/widgets/glass_container.dart';
import 'package:raksh_health/repositories/auth_repository.dart';
import 'package:raksh_health/repositories/profile_repository.dart';
import 'package:raksh_health/utils/ui_utils.dart';
import 'package:raksh_health/features/documents/upload_document_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0F1E), Color(0xFF141A33)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: profileAsync.when(
                          data: (profile) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Namaste ${profile?['full_name'] ?? '🙏'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (profile?['raksh_id'] != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 4, bottom: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'ID: ${profile?['raksh_id']}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              Text(
                                'How are you feeling today?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                          loading: () => const Text('Namaste 🙏', style: TextStyle(color: Colors.white, fontSize: 18)),
                          error: (err, stack) => const Text('Namaste 🙏', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          try {
                            await ref.read(authRepositoryProvider).signOut();
                          } catch (e) {
                            if (context.mounted) context.showSnackBar('Logout failed: $e', isError: true);
                          }
                        },
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.glassColor,
                          child: Icon(CupertinoIcons.person_fill, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: const [
                      FeatureCard(
                        title: 'Health Vault',
                        subtitle: 'Secure medical records',
                        icon: CupertinoIcons.lock_shield_fill,
                        iconColor: AppTheme.primaryColor,
                        glowColor: AppTheme.primaryColor,
                      ),
                      FeatureCard(
                        title: 'Medicines',
                        subtitle: 'Reminders & Tracking',
                        icon: CupertinoIcons.capsule_fill,
                        iconColor: Colors.blueAccent,
                        glowColor: Colors.blueAccent,
                      ),
                      FeatureCard(
                        title: 'Lab Reports',
                        subtitle: 'Diagnosis results',
                        icon: CupertinoIcons.chart_bar_fill,
                        iconColor: Colors.greenAccent,
                        glowColor: Colors.greenAccent,
                      ),
                      FeatureCard(
                        title: 'Doctor Visits',
                        subtitle: 'Upcoming appointments',
                        icon: Icons.medical_services,
                        iconColor: Colors.orangeAccent,
                        glowColor: Colors.orangeAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Recent Reports',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(CupertinoIcons.doc_text, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Blood Test Result', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('April 5th, 2026', style: TextStyle(color: Colors.white38, fontSize: 13)),
                          ],
                        ),
                        const Spacer(),
                        const Icon(CupertinoIcons.chevron_right, color: Colors.white24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              borderRadius: 0,
              blur: 25,
              opacity: 0.12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(CupertinoIcons.house_fill, color: AppTheme.secondaryColor, size: 28),
                  Icon(CupertinoIcons.doc_fill, color: Colors.white.withValues(alpha: 0.4), size: 28),
                  Icon(CupertinoIcons.capsule, color: Colors.white.withValues(alpha: 0.4), size: 28),
                  Icon(CupertinoIcons.person_circle, color: Colors.white.withValues(alpha: 0.4), size: 28),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadDocumentScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(CupertinoIcons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color glowColor;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w400),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
