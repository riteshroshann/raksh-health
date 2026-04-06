import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:raksh_health/config/supabase_config.dart';
import 'package:raksh_health/config/app_theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:raksh_health/screens/splash_screen.dart';
import 'package:raksh_health/screens/home/home_screen.dart';
import 'package:raksh_health/repositories/auth_repository.dart';
import 'package:raksh_health/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize Google Sign In
  try {
    await GoogleSignIn.instance.initialize(
      clientId: 'YOUR_IOS_CLIENT_ID',
      serverClientId: 'YOUR_WEB_CLIENT_ID',
    );
  } catch (e) {
    debugPrint("Google Sign In initialization failed: $e");
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(
    const ProviderScope(
      child: RakshHealthApp(),
    ),
  );
}

class RakshHealthApp extends ConsumerWidget {
  const RakshHealthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Raksh Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: authState.when(
        data: (state) {
          if (state.session != null) {
            return const HomeScreen();
          }
          return const SplashScreen(); // Splash will timer-transition to Login
        },
        loading: () => const SplashScreen(),
        error: (e, stack) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}
