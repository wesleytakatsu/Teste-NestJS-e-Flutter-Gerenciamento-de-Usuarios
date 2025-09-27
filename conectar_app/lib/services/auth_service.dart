import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService() {
    _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    
    // Interceptor para adicionar automaticamente o token JWT às requisições
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      return response.data;
    } catch (e) {
      if (e is DioException) {
        // Erro específico para problemas de CORS/rede no Flutter web
        if (e.message?.contains('XMLHttpRequest') == true || 
            e.message?.contains('network layer') == true ||
            e.message?.contains('CORS') == true) {
          throw Exception('Erro de conexão: Verifique se o backend está rodando em http://localhost:3000 e configurado para CORS');
        }
        throw Exception('Login failed: ${e.response?.data?['message'] ?? e.message}');
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      return response.data;
    } catch (e) {
      throw Exception('Registration failed');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get profile');
    }
  }
}