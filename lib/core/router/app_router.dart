import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_shell.dart';
import '../../features/onboarding/language_select_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/listing/presentation/screens/listing_detail_screen.dart';
import '../../features/seller/presentation/screens/seller_profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/farmer/presentation/screens/farmer_dashboard_screen.dart';
import '../../features/farmer/presentation/screens/create_listing_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/admin/presentation/screens/admin_panel_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/language-select',
    redirect: (context, state) async {
      final path = state.matchedLocation;
      final user = Supabase.instance.client.auth.currentUser;
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('first_launch') ?? true;

      // Skip onboarding if already completed
      if (path == '/language-select' && !isFirstLaunch) return '/';
      if (path == '/onboarding' && !isFirstLaunch) return '/';

      // Farmer routes require auth
      if (path.startsWith('/farmer') && user == null) return '/auth/login';

      // Auth routes redirect to dashboard if already logged in
      if ((path == '/auth/login' || path == '/auth/register') && user != null) {
        return '/farmer/dashboard';
      }

      return null;
    },
    routes: [
      // Onboarding
      GoRoute(
        path: '/language-select',
        builder: (_, __) => const LanguageSelectScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // Auth
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // Admin
      GoRoute(path: '/admin', builder: (_, __) => const AdminPanelScreen()),

      // Listing detail + seller profile
      GoRoute(
        path: '/listing/:id',
        builder: (_, state) =>
            ListingDetailScreen(listingId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/seller/:id',
        builder: (_, state) =>
            SellerProfileScreen(sellerId: state.pathParameters['id'] ?? ''),
      ),

      // Farmer flow
      GoRoute(
        path: '/farmer/listing/new',
        builder: (_, __) => const CreateListingScreen(),
      ),
      GoRoute(
        path: '/farmer/listing/:id/edit',
        builder: (_, state) =>
            CreateListingScreen(listingId: state.pathParameters['id'] ?? ''),
      ),

      // Shell routes (with bottom nav bar)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/farmer/dashboard',
            builder: (_, __) => const FarmerDashboardScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
