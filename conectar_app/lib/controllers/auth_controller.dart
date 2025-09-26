import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  RxBool isLoggedIn = false.obs;
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    String? token = await _storage.read(key: 'token');
    if (token != null) {
      // Validate token or fetch user
      isLoggedIn.value = true;
      // Fetch user profile
    }
  }

  Future<void> login(String email, String password) async {
    try {
      var response = await _authService.login(email, password);
      await _storage.write(key: 'token', value: response['access_token']);
      currentUser.value = User.fromJson(response['user']);
      isLoggedIn.value = true;
      Get.offAllNamed('/users');
    } catch (e) {
      Get.snackbar('Error', 'Login failed');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    isLoggedIn.value = false;
    currentUser.value = null;
    Get.offAllNamed('/login');
  }
}