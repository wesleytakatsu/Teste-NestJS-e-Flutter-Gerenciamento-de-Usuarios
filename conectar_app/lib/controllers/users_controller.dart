import 'package:get/get.dart';
import '../models/user.dart';
import '../services/users_service.dart';

class UsersController extends GetxController {
  final UsersService _usersService = UsersService();
  RxList<User> users = <User>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers({String? role, String? name}) async {
    isLoading.value = true;
    try {
      var fetchedUsers = await _usersService.fetchUsers(role: role, name: name);
      users.assignAll(fetchedUsers);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(User user) async {
    try {
      await _usersService.createUser(user);
      fetchUsers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create user');
    }
  }

  Future<void> updateUser(String id, User user) async {
    try {
      await _usersService.updateUser(id, user);
      fetchUsers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _usersService.deleteUser(id);
      fetchUsers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user');
    }
  }
}