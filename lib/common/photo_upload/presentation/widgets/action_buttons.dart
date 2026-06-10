import 'package:flutter/material.dart';
import 'package:endimata/config/theme/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final String? subSubcategory;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ActionButtons({
    super.key,
    required this.subSubcategory,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.inactiveColor,
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'Отменить',
              style: TextStyle(fontSize: 18, fontFamily: 'SFPro-Medium'),
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ElevatedButton(
            onPressed: subSubcategory != null ? onSave : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Сохранить',
              style: TextStyle(fontSize: 18, fontFamily: 'SFPro-Medium'),
            ),
          ),
        ),
      ],
    );
  }
}
