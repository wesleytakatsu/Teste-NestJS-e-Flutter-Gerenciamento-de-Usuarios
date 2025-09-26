import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw Exception('Login failed');
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
}