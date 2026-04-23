import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';

class OrderTimeline extends StatelessWidget {
  final String currentStatus;

  const OrderTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final statuses = ['pending', 'validated', 'shipped', 'delivered'];
    final labels = ['En attente', 'Validée', 'Expédiée', 'Livrée'];
    final currentIndex = statuses.indexOf(currentStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final isCompleted = index <= currentIndex;
            final isActive = index == currentIndex;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.success : Colors.grey[300],
                      border: isActive
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : Text('${index + 1}'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCompleted ? AppColors.success : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
