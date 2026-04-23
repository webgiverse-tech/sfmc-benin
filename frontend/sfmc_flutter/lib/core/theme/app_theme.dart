import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.danger,
        surface: AppColors.card,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      dividerColor: AppColors.divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          AppColors.accent.withOpacity(0.3),
        ),
        dataRowColor: WidgetStateProperty.all(Colors.white),
        dividerThickness: 1,
        columnSpacing: 20,
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accent,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}

// // lib/core/theme/app_theme.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:google_fonts/google_fonts.dart';

// // -------------------- THÈME PRINCIPAL --------------------
// class AppTheme {
//   // Palette de couleurs SFMC Bénin
//   static const Color primaryColor = Color(0xFF1A3C6E); // Bleu marine
//   static const Color secondaryColor = Color(0xFFF4A41B); // Or/Jaune
//   static const Color accentColor = Color(0xFFE8F0FE); // Bleu clair
//   static const Color successColor = Color(0xFF2E7D32); // Vert
//   static const Color dangerColor = Color(0xFFC62828); // Rouge
//   static const Color backgroundColor = Color(0xFFF5F7FA); // Gris clair
//   static const Color cardColor = Color(0xFFFFFFFF); // Blanc

//   // Configuration du thème Material
//   static ThemeData get lightTheme {
//     return ThemeData(
//       primaryColor: primaryColor,
//       scaffoldBackgroundColor: backgroundColor,
//       cardColor: cardColor,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 2,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryColor,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//       ),
//       textTheme: GoogleFonts.poppinsTextTheme().copyWith(
//         titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//         titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
//         bodyMedium: GoogleFonts.roboto(),
//       ),
//       colorScheme: ColorScheme.fromSwatch().copyWith(
//         primary: primaryColor,
//         secondary: secondaryColor,
//         error: dangerColor,
//       ),
//     );
//   }
// }

// // -------------------- APPLICATION PRINCIPALE --------------------
// void main() => runApp(const SFMCApp());

// class SFMCApp extends StatelessWidget {
//   const SFMCApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'SFMC Bénin',
//       theme: AppTheme.lightTheme,
//       routerConfig: _router,
//     );
//   }

//   // Configuration des routes avec GoRouter
//   static final GoRouter _router = GoRouter(
//     initialLocation: '/dashboard',
//     routes: [
//       GoRoute(
//         path: '/dashboard',
//         builder: (context, state) => const DashboardScreen(),
//       ),
//       // Les autres routes seront ajoutées ultérieurement
//     ],
//   );
// }

// // -------------------- ÉCRAN DASHBOARD --------------------
// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tableau de bord SFMC'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {},
//           ),
//           const CircleAvatar(
//             backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
//           ),
//           const SizedBox(width: 16),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Bonjour, Koffi ADJOVI',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Voici les indicateurs clés du ${_formatDate(DateTime.now())}',
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 24),
//             const KpiCardsSection(),
//             const SizedBox(height: 32),
//             const ChartsSection(),
//             const SizedBox(height: 32),
//             const RecentOrdersSection(),
//             const SizedBox(height: 32),
//             const StockAlertsSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final months = [
//       'janvier',
//       'février',
//       'mars',
//       'avril',
//       'mai',
//       'juin',
//       'juillet',
//       'août',
//       'septembre',
//       'octobre',
//       'novembre',
//       'décembre',
//     ];
//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }
// }

// // -------------------- SECTION KPIs --------------------
// class KpiCardsSection extends StatelessWidget {
//   const KpiCardsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 16,
//       runSpacing: 16,
//       children: const [
//         StatCard(
//           title: 'Commandes',
//           value: '156',
//           icon: Icons.shopping_cart,
//           color: AppTheme.primaryColor,
//           trend: '+12%',
//         ),
//         StatCard(
//           title: 'Stock Global',
//           value: '1 250',
//           icon: Icons.inventory,
//           color: AppTheme.secondaryColor,
//           trend: '-3%',
//         ),
//         StatCard(
//           title: 'Production',
//           value: '328',
//           icon: Icons.factory,
//           color: AppTheme.successColor,
//           trend: '+8%',
//         ),
//         StatCard(
//           title: 'CA Mensuel',
//           value: '2.5M',
//           icon: Icons.monetization_on,
//           color: AppTheme.accentColor,
//           suffix: 'FCFA',
//         ),
//         StatCard(
//           title: 'Alertes Stock',
//           value: '3',
//           icon: Icons.warning,
//           color: AppTheme.dangerColor,
//         ),
//       ],
//     );
//   }
// }

// // -------------------- CARTE STATISTIQUE --------------------
// class StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;
//   final String? trend;
//   final String? suffix;

//   const StatCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//     this.trend,
//     this.suffix,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         width: 180,
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(icon, color: color, size: 28),
//                 if (trend != null)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: trend!.startsWith('+')
//                           ? AppTheme.successColor.withOpacity(0.1)
//                           : AppTheme.dangerColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Text(
//                       trend!,
//                       style: TextStyle(
//                         color: trend!.startsWith('+')
//                             ? AppTheme.successColor
//                             : AppTheme.dangerColor,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (suffix != null) ...[
//                   const SizedBox(width: 4),
//                   Text(
//                     suffix!,
//                     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                   ),
//                 ],
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // -------------------- SECTION GRAPHIQUES --------------------
// class ChartsSection extends StatelessWidget {
//   const ChartsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Évolution des ventes (6 derniers mois)',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               height: 250,
//               child: LineChart(
//                 LineChartData(
//                   gridData: FlGridData(show: true, drawVerticalLine: false),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 40,
//                         getTitlesWidget: (value, meta) {
//                           return Text(
//                             '${value.toInt()}k',
//                             style: const TextStyle(fontSize: 12),
//                           );
//                         },
//                       ),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) {
//                           const months = [
//                             'Jan',
//                             'Fév',
//                             'Mar',
//                             'Avr',
//                             'Mai',
//                             'Juin',
//                           ];
//                           if (value >= 0 && value < months.length) {
//                             return Text(months[value.toInt()]);
//                           }
//                           return const Text('');
//                         },
//                       ),
//                     ),
//                     rightTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     topTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: const [
//                         FlSpot(0, 120),
//                         FlSpot(1, 250),
//                         FlSpot(2, 480),
//                         FlSpot(3, 620),
//                         FlSpot(4, 890),
//                         FlSpot(5, 1100),
//                       ],
//                       isCurved: true,
//                       color: AppTheme.primaryColor,
//                       barWidth: 3,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: AppTheme.primaryColor.withOpacity(0.1),
//                       ),
//                       dotData: FlDotData(show: true),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // -------------------- SECTION COMMANDES RÉCENTES --------------------
// class RecentOrdersSection extends StatelessWidget {
//   const RecentOrdersSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Commandes récentes',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 TextButton(onPressed: () {}, child: const Text('Voir tout')),
//               ],
//             ),
//             const SizedBox(height: 16),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columnSpacing: 30,
//                 columns: const [
//                   DataColumn(label: Text('N°')),
//                   DataColumn(label: Text('Client')),
//                   DataColumn(label: Text('Date')),
//                   DataColumn(label: Text('Montant')),
//                   DataColumn(label: Text('Statut')),
//                 ],
//                 rows: _getRecentOrders().map((order) {
//                   return DataRow(
//                     cells: [
//                       DataCell(Text(order['id']!)),
//                       DataCell(Text(order['client']!)),
//                       DataCell(Text(order['date']!)),
//                       DataCell(Text(order['amount']!)),
//                       DataCell(_buildStatusChip(order['status']!)),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusChip(String status) {
//     Color bgColor;
//     Color textColor;
//     switch (status) {
//       case 'Livrée':
//         bgColor = AppTheme.successColor.withOpacity(0.1);
//         textColor = AppTheme.successColor;
//         break;
//       case 'En cours':
//         bgColor = AppTheme.secondaryColor.withOpacity(0.1);
//         textColor = AppTheme.secondaryColor;
//         break;
//       case 'En attente':
//         bgColor = Colors.orange.withOpacity(0.1);
//         textColor = Colors.orange;
//         break;
//       default:
//         bgColor = Colors.grey.withOpacity(0.1);
//         textColor = Colors.grey;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(
//           color: textColor,
//           fontWeight: FontWeight.w500,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   List<Map<String, String>> _getRecentOrders() {
//     return [
//       {
//         'id': '#1001',
//         'client': 'SOTRAB',
//         'date': '22/04/2026',
//         'amount': '650 000 FCFA',
//         'status': 'Livrée',
//       },
//       {
//         'id': '#1002',
//         'client': 'BTP Services',
//         'date': '21/04/2026',
//         'amount': '1 250 000 FCFA',
//         'status': 'En cours',
//       },
//       {
//         'id': '#1003',
//         'client': 'M. HOUNKPE',
//         'date': '20/04/2026',
//         'amount': '125 000 FCFA',
//         'status': 'En attente',
//       },
//       {
//         'id': '#1004',
//         'client': 'Ets AYIVI',
//         'date': '19/04/2026',
//         'amount': '875 000 FCFA',
//         'status': 'Livrée',
//       },
//     ];
//   }
// }

// // -------------------- SECTION ALERTES STOCK --------------------
// class StockAlertsSection extends StatelessWidget {
//   const StockAlertsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Alertes de stock',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: AppTheme.dangerColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '3 produits sous seuil',
//                     style: TextStyle(
//                       color: AppTheme.dangerColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ..._getAlerts()
//                 .map(
//                   (alert) => ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: alert['critique'] == 'true'
//                           ? AppTheme.dangerColor.withOpacity(0.2)
//                           : Colors.orange.withOpacity(0.2),
//                       child: Icon(
//                         Icons.warning,
//                         color: alert['critique'] == 'true'
//                             ? AppTheme.dangerColor
//                             : Colors.orange,
//                       ),
//                     ),
//                     title: Text(alert['product']!),
//                     subtitle: Text(
//                       'Stock: ${alert['stock']} ${alert['unit']} | Seuil: ${alert['threshold']} ${alert['unit']}',
//                     ),
//                     trailing: ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.primaryColor,
//                         foregroundColor: Colors.white,
//                       ),
//                       child: const Text('Commander'),
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Map<String, String>> _getAlerts() {
//     return [
//       {
//         'product': 'Ciment Portland 50kg',
//         'stock': '50',
//         'threshold': '100',
//         'unit': 'sacs',
//         'critique': 'true',
//       },
//       {
//         'product': 'Fer à béton 10mm',
//         'stock': '200',
//         'threshold': '500',
//         'unit': 'barres',
//         'critique': 'false',
//       },
//       {
//         'product': 'Gravier 5/15',
//         'stock': '3',
//         'threshold': '10',
//         'unit': 'tonnes',
//         'critique': 'true',
//       },
//     ];
//   }
// }
