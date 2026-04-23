import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/utils/formatters.dart';
import 'package:sfmc_flutter/core/widgets/data_table_widget.dart';
import 'package:sfmc_flutter/features/users/models/user_profile_model.dart';

class UserTable extends StatelessWidget {
  final List<UserProfile> users;

  const UserTable({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final columns = ['Nom', 'Prénom', 'Email', 'Téléphone', 'Rôle', 'Statut'];

    final rows = users.map((user) {
      return DataRow(cells: [
        DataCell(Text(user.nom)),
        DataCell(Text(user.prenom)),
        DataCell(Text(user.email)),
        DataCell(Text(user.telephone ?? '-')),
        DataCell(_buildRoleChip(user.role)),
        DataCell(_buildStatusChip(user.actif)),
      ]);
    }).toList();

    return AppDataTable(
      columns: columns,
      rows: rows,
    );
  }

  Widget _buildRoleChip(String role) {
    Color color;
    switch (role) {
      case 'admin':
        color = AppColors.danger;
        break;
      case 'operateur':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.success;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        Formatters.capitalize(role),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusChip(bool actif) {
    final color = actif ? AppColors.success : AppColors.textSecondary;
    final label = actif ? 'Actif' : 'Inactif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}