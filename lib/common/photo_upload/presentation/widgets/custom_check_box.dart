import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

class CustomCheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? AppColors.primaryColor : Colors.transparent,
          border: Border.all(
            color: value ? AppColors.primaryColor : Colors.white,
            width: 2,
          ),
        ),
        child:
            value
                ? const Center(
                  child: Icon(Icons.circle, size: 12, color: Colors.white),
                )
                : null,
      ),
    );
  }
}
