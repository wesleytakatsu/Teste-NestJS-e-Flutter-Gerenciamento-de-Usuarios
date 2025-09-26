import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class UsersService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UsersService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<List<User>> fetchUsers({String? role, String? name}) async {
    try {
      final response = await _dio.get('/users', queryParameters: {
        if (role != null) 'role': role,
        if (name != null) 'name': name,
      });
      return (response.data as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users');
    }
  }

  Future<User> createUser(User user) async {
    try {
      final response = await _dio.post('/users', data: user.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create user');
    }
  }

  Future<User> updateUser(String id, User user) async {
    try {
      final response = await _dio.patch('/users/$id', data: user.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete('/users/$id');
    } catch (e) {
      throw Exception('Failed to delete user');
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get profile');
    }
  }
}