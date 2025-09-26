import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/users_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/user.dart';

class UserFormView extends StatefulWidget {
  const UserFormView({super.key});

  @override
  _UserFormViewState createState() => _UserFormViewState();
}

class _UserFormViewState extends State<UserFormView> with TickerProviderStateMixin {
  final UsersController usersController = Get.find();
  final AuthController authController = Get.find();
  late TabController _tabController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole;
  User? editingUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    editingUser = Get.arguments as User?;
    if (editingUser != null) {
      nameController.text = editingUser!.name;
      emailController.text = editingUser!.email;
      selectedRole = editingUser!.role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editingUser == null ? 'Create User' : 'Edit User'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dados Cadastrais'),
            Tab(text: 'Informações Internas'),
            Tab(text: 'Usuários'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDadosCadastraisTab(),
          const Center(child: Text('Informações Internas - Placeholder')),
          const Center(child: Text('Usuários - Placeholder')),
        ],
      ),
    );
  }

  Widget _buildDadosCadastraisTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome na Fachada'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            if (authController.currentUser.value?.role == 'admin')
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['admin', 'user'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) => setState(() => selectedRole = value),
              ),
            if (editingUser == null)
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUser,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveUser() {
    if (editingUser == null) {
      User newUser = User(
        id: '',
        name: nameController.text,
        email: emailController.text,
        role: selectedRole ?? 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      usersController.createUser(newUser);
    } else {
      User updatedUser = User(
        id: editingUser!.id,
        name: nameController.text,
        email: emailController.text,
        role: selectedRole ?? editingUser!.role,
        createdAt: editingUser!.createdAt,
        updatedAt: DateTime.now(),
      );
      usersController.updateUser(editingUser!.id, updatedUser);
    }
    Get.back();
  }
}