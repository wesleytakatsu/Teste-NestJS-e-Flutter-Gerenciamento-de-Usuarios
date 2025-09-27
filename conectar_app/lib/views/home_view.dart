import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conectar - Home'),
        backgroundColor: const Color(0xFF2ecc71),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.logout();
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Olá',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2ecc71),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => Text(
              authController.currentUser.value?.name != null
                  ? 'Bem-vindo, ${authController.currentUser.value!.name}!'
                  : 'Bem-vindo ao Conectar!',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 40),
            // Botões de navegação opcionais
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                Obx(() {
                  if (authController.currentUser.value?.role == 'admin') {
                    return ElevatedButton.icon(
                      onPressed: () => Get.toNamed('/users'),
                      icon: const Icon(Icons.people),
                      label: const Text('Gerenciar Usuários'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ecc71),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/profile'),
                  icon: const Icon(Icons.person),
                  label: const Text('Meu Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ecc71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}