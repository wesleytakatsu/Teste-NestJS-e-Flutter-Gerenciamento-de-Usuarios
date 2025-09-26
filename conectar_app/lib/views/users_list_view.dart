import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/users_controller.dart';
import '../models/user.dart';

class UsersListView extends StatefulWidget {
  const UsersListView({super.key});

  @override
  _UsersListViewState createState() => _UsersListViewState();
}

class _UsersListViewState extends State<UsersListView> {
  final AuthController authController = Get.find();
  final UsersController usersController = Get.find();
  final TextEditingController nameController = TextEditingController();
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (authController.currentUser.value?.role == 'admin') {
          return Column(
            children: [
              ExpansionTile(
                title: const Text('Filters'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Search by name'),
                        ),
                        DropdownButton<String>(
                          value: selectedRole,
                          hint: const Text('Select role'),
                          items: ['admin', 'user'].map((role) {
                            return DropdownMenuItem(value: role, child: Text(role));
                          }).toList(),
                          onChanged: (value) => setState(() => selectedRole = value),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                usersController.fetchUsers(
                                  name: nameController.text.isEmpty ? null : nameController.text,
                                  role: selectedRole,
                                );
                              },
                              child: const Text('Filter'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                nameController.clear();
                                setState(() => selectedRole = null);
                                usersController.fetchUsers();
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Obx(() {
                  if (usersController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: usersController.users.length,
                    itemBuilder: (context, index) {
                      User user = usersController.users[index];
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text('${user.email} - ${user.role}'),
                        onTap: () => Get.toNamed('/user-form', arguments: user),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${authController.currentUser.value!.name}'),
                Text('Email: ${authController.currentUser.value!.email}'),
                Text('Role: ${authController.currentUser.value!.role}'),
                Text('Created At: ${authController.currentUser.value!.createdAt}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/user-form', arguments: authController.currentUser.value),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          );
        }
      }),
      floatingActionButton: Obx(() {
        if (authController.currentUser.value?.role == 'admin') {
          return FloatingActionButton(
            onPressed: () => Get.toNamed('/user-form'),
            child: const Icon(Icons.add),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}