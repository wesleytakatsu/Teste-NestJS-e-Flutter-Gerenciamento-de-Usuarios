import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${user.name}'),
              Text('Email: ${user.email}'),
              Text('Role: ${user.role}'),
              Text('Created At: ${user.createdAt}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.toNamed('/user-form', arguments: user),
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        );
      }),
    );
  }
}