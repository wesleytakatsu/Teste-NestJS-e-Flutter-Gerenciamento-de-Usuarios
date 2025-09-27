import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/users_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController());
  Get.put(UsersController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Obx(() {
      final router = GoRouter(
        routes: AppRoutes.routes,
        initialLocation: authController.isLoggedIn.value ? '/home' : '/login',
        redirect: (context, state) {
          final isLoggedIn = authController.isLoggedIn.value;
          final isLoginRoute = state.matchedLocation == '/login';

          if (!isLoggedIn && !isLoginRoute) {
            return '/login';
          }
          if (isLoggedIn && isLoginRoute) {
            return '/home';
          }
          return null;
        },
      );

      return GetMaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        title: 'Conectar App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      );
    });
  }
}
