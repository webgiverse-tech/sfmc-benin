import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
    this.color,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        color ?? (outlined ? Colors.transparent : AppColors.primary);
    final textColor = outlined ? (color ?? AppColors.primary) : Colors.white;

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        else if (icon != null)
          Icon(icon, color: textColor, size: 20),
        if ((isLoading || icon != null) && text.isNotEmpty)
          const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );

    if (outlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: buttonColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: child,
      ),
    );
  }
}
