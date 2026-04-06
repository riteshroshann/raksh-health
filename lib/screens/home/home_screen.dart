import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raksh_health/config/app_theme.dart';
import 'package:raksh_health/widgets/glass_container.dart';
import 'package:raksh_health/repositories/auth_repository.dart';
import 'package:raksh_health/repositories/profile_repository.dart';
import 'package:raksh_health/features/documents/upload_document_screen.dart';
import 'package:raksh_health/features/vault/document_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeDashboard(),
    const DocumentListScreen(),
    const UploadDocumentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A0F1E), Color(0xFF1A1F3D), Color(0xFF0A0F1E)],
              ),
            ),
          ),
          
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: GlassContainer(
        borderRadius: 30,
        blur: 30,
        opacity: 0.1,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.secondaryColor,
          unselectedItemColor: Colors.white24,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house), 
              activeIcon: Icon(CupertinoIcons.house_fill), 
              label: 'Home'
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.lock_shield), 
              activeIcon: Icon(CupertinoIcons.shield_fill), 
              label: 'Vault'
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.add_circled), 
              activeIcon: Icon(CupertinoIcons.plus_circle_fill), 
              label: 'Upload'
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDashboard extends ConsumerWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(profileAsync, ref),
            const SizedBox(height: 32),
            _buildQuickActions(context),
            const SizedBox(height: 32),
            _buildVitalsCard(),
            const SizedBox(height: 32),
            _buildGridActions(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<Map<String, dynamic>?> profileAsync, WidgetRef ref) {
    return profileAsync.when(
      data: (profile) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, ${profile?['full_name']?.split(' ')[0] ?? 'User'}', 
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const Text('Your health shield is active', 
                style: TextStyle(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.w300)),
            ],
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.square_arrow_right, color: Colors.white24),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error loading profile'),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionItem(icon: CupertinoIcons.chat_bubble_text, label: 'AI Chat', color: Colors.blueAccent),
        _ActionItem(icon: CupertinoIcons.calendar, label: 'Booking', color: Colors.purpleAccent),
        _ActionItem(icon: CupertinoIcons.timer, label: 'Stats', color: Colors.orangeAccent),
        _ActionItem(icon: CupertinoIcons.ellipsis, label: 'More', color: Colors.tealAccent),
      ],
    );
  }

  Widget _buildVitalsCard() {
    return GlassContainer(
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Real-time Vitals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(CupertinoIcons.waveform_path_ecg, size: 18, color: AppTheme.secondaryColor),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _VitalInfo(label: 'Weight', value: '72', unit: 'kg', icon: CupertinoIcons.gauge),
                _VitalInfo(label: 'Sleep', value: '7.5', unit: 'hrs', icon: CupertinoIcons.moon),
                _VitalInfo(label: 'BPM', value: '72', unit: 'bpm', icon: CupertinoIcons.heart),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: const [
        _FeatureCard(
          title: 'Medicines',
          subtitle: 'Active tracking',
          icon: CupertinoIcons.capsule,
          color: Colors.blueAccent,
        ),
        _FeatureCard(
          title: 'Emergency',
          subtitle: 'Instant alert',
          icon: CupertinoIcons.phone_fill,
          color: Colors.redAccent,
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ActionItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class _VitalInfo extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  const _VitalInfo({required this.label, required this.value, required this.unit, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.secondaryColor.withValues(alpha: 0.6), size: 22),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              TextSpan(text: ' $unit', style: const TextStyle(fontSize: 12, color: Colors.white54)),
            ],
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white30, letterSpacing: 1)),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
