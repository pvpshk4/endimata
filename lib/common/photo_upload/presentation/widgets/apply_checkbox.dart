import 'package:flutter/material.dart';
import 'package:endimata/config/theme/app_colors.dart';

class ApplyCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;

  const ApplyCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
        ),
        Text(
          'Применить сразу после добавления',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'SFPro-Light',
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
