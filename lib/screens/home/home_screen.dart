import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raksh_health/widgets/glass_card.dart';
import 'package:raksh_health/widgets/spatial_background.dart';
import 'package:raksh_health/repositories/profile_repository.dart';
import 'package:raksh_health/features/documents/upload_document_screen.dart';
import 'package:raksh_health/features/vault/document_list_screen.dart';
import 'package:raksh_health/features/medicines/medicines_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeDashboardView(),
    const DocumentListScreen(),
    const MedicinesScreen(),
    const Center(child: Text("Settings")), // Placeholder for Settings from Prompt
  ];

  @override
  Widget build(BuildContext context) {
    return SpatialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            
            // Custom Floating Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: _buildFloatingNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    final size = MediaQuery.of(context).size;
    
    return Center(
      child: GlassCard(
        width: size.width * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderRadius: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarIcon(
              icon: CupertinoIcons.house,
              isActive: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _NavBarIcon(
              icon: CupertinoIcons.sparkles,
              isActive: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _NavBarIcon(
              icon: CupertinoIcons.settings,
              isActive: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDashboardView extends ConsumerWidget {
  const _HomeDashboardView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Top App Bar Area
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  profileAsync.when(
                    data: (profile) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Morning,",
                          style: textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white.withOpacity(0.6) 
                              : Colors.black.withOpacity(0.4),
                          ),
                        ),
                        Text(
                          "${profile?['full_name']?.split(' ')[0] ?? 'Gladys'}!",
                          style: textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    loading: () => const CupertinoActivityIndicator(),
                    error: (_, __) => const Text("Welcome!"),
                  ),
                  const _ProfileAvatar(),
                ],
              ),
            ),
          ),

          // Primary Action: Upload Document
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const UploadDocumentScreen()),
                ),
                child: GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const _AnimatedPulseIcon(),
                      const SizedBox(height: 20),
                      Text(
                        "Upload new document",
                        style: textTheme.headlineMedium?.copyWith(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "AI will analyze and organize your medical records automatically.",
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // The 4 Pillars Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
              children: const [
                _PillarCard(
                  title: "Tests",
                  subtitle: "Sugar, Thyroid, CBC",
                  icon: CupertinoIcons.drop_fill,
                  color: Color(0xFFF06292),
                ),
                _PillarCard(
                  title: "Scans",
                  subtitle: "X-Ray, MRI, CT",
                  icon: CupertinoIcons.waveform_path_ecg,
                  color: Color(0xFF64B5F6),
                ),
                _PillarCard(
                  title: "Medicines",
                  subtitle: "Active & Past",
                  icon: CupertinoIcons.capsule_fill,
                  color: Color(0xFF81C784),
                ),
                _PillarCard(
                  title: "Doctor Visits",
                  subtitle: "Prescriptions",
                  icon: CupertinoIcons.stethoscope,
                  color: Color(0xFFFFB74D),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          "https://i.pravatar.cc/150?u=raksh",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AnimatedPulseIcon extends StatefulWidget {
  const _AnimatedPulseIcon();

  @override
  State<_AnimatedPulseIcon> createState() => _AnimatedPulseIconState();
}

class _AnimatedPulseIconState extends State<_AnimatedPulseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          CupertinoIcons.cloud_upload,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PillarCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive 
      ? Theme.of(context).colorScheme.primary 
      : (Theme.of(context).brightness == Brightness.dark ? Colors.white30 : Colors.black26);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
