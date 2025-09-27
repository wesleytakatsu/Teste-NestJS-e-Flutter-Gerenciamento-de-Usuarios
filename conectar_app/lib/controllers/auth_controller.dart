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
    try {
      String? token = await _storage.read(key: 'token');
      if (token != null && token.isNotEmpty) {
        // Token existe, tentar buscar o perfil do usuário para validar
        try {
          var profile = await _authService.getProfile();
          currentUser.value = User.fromJson(profile);
          isLoggedIn.value = true;
        } catch (e) {
          // Token inválido ou expirado, remover e marcar como deslogado
          await _storage.delete(key: 'token');
          isLoggedIn.value = false;
          currentUser.value = null;
        }
      } else {
        isLoggedIn.value = false;
      }
    } catch (e) {
      // Se houver erro na leitura, considerar como não logado
      isLoggedIn.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      var response = await _authService.login(email, password);
      
      // Armazenar o token JWT no flutter_secure_storage
      await _storage.write(key: 'token', value: response['access_token']);
      
      // Atualizar o estado do usuário
      currentUser.value = User.fromJson(response['user']);
      isLoggedIn.value = true;
      
      // O GoRouter irá automaticamente redirecionar para /home baseado no estado isLoggedIn
    } catch (e) {
      print('Erro no login: $e');
      // Aqui você pode adicionar um snackbar ou outro método de notificação se necessário
    }
  }

  Future<void> logout() async {
    try {
      // Remover o token do armazenamento seguro
      await _storage.delete(key: 'token');
      
      // Limpar o estado
      isLoggedIn.value = false;
      currentUser.value = null;
      
      // O GoRouter irá automaticamente redirecionar para /login baseado no estado isLoggedIn
    } catch (e) {
      print('Erro no logout: $e');
      // Mesmo se houver erro, ainda limpar o estado
      isLoggedIn.value = false;
      currentUser.value = null;
    }
  }
}