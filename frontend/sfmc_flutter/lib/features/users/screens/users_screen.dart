import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/widgets/loading_widget.dart';
import 'package:sfmc_flutter/features/users/providers/user_provider.dart';
import 'package:sfmc_flutter/features/users/widgets/user_table.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Utilisateurs')),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          return RefreshIndicator(
            onRefresh: provider.fetchUsers,
            child: UserTable(users: provider.users),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ajouter utilisateur
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
