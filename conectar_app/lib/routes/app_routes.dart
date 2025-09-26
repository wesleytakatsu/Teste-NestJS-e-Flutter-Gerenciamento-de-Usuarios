import 'package:go_router/go_router.dart';
import '../views/login_view.dart';
import '../views/users_list_view.dart';
import '../views/user_form_view.dart';
import '../views/profile_view.dart';

class AppRoutes {
  static final routes = [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => const UsersListView(),
    ),
    GoRoute(
      path: '/user-form',
      builder: (context, state) => const UserFormView(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileView(),
    ),
  ];
}