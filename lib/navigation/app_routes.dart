import 'package:tripify/views/home_view.dart';
import 'package:tripify/views/accommodation_requirement_view.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/accommodation',
        builder: (context, state) => const AccommodationRequirementView(),
      ),
    ],
  );
}
