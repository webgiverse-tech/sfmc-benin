import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/features/auth/providers/auth_provider.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/navigation/routes.dart';

class SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.email ?? 'Utilisateur'),
            accountEmail: Text(user?.role ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            decoration: const BoxDecoration(color: AppColors.primary),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  index: 0,
                  icon: Icons.dashboard,
                  title: 'Tableau de bord',
                  route: Routes.dashboard,
                ),
                _buildDrawerItem(
                  context,
                  index: 1,
                  icon: Icons.inventory,
                  title: 'Produits',
                  route: Routes.products,
                ),
                _buildDrawerItem(
                  context,
                  index: 2,
                  icon: Icons.warehouse,
                  title: 'Stocks',
                  route: Routes.inventory,
                ),
                _buildDrawerItem(
                  context,
                  index: 3,
                  icon: Icons.shopping_cart,
                  title: 'Commandes',
                  route: Routes.orders,
                ),
                _buildDrawerItem(
                  context,
                  index: 4,
                  icon: Icons.factory,
                  title: 'Production',
                  route: Routes.production,
                ),
                _buildDrawerItem(
                  context,
                  index: 5,
                  icon: Icons.receipt,
                  title: 'Facturation',
                  route: Routes.billing,
                ),
                _buildDrawerItem(
                  context,
                  index: 6,
                  icon: Icons.bar_chart,
                  title: 'Reporting',
                  route: Routes.reporting,
                ),
                if (user?.role == 'admin')
                  _buildDrawerItem(
                    context,
                    index: 7,
                    icon: Icons.people,
                    title: 'Utilisateurs',
                    route: Routes.users,
                  ),
                _buildDrawerItem(
                  context,
                  index: 8,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  route: Routes.notifications,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Déconnexion'),
                  onTap: () {
                    authProvider.logout();
                    context.go(Routes.login);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : null),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.accent.withOpacity(0.3),
      onTap: () {
        onItemSelected(index);
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
