import 'package:flutter/material.dart';
import 'package:endimata/config/theme/app_colors.dart';

class UnderlinePainter extends CustomPainter {
  final Color color;
  final double thickness;

  UnderlinePainter({required this.color, this.thickness = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WardrobeProductsFilterWidget extends StatelessWidget {
  final List<String> subSubcategories;
  final String selectedSubSubcategory;
  final Function(String) onSubSubcategorySelected;

  const WardrobeProductsFilterWidget({
    super.key,
    required this.subSubcategories,
    required this.selectedSubSubcategory,
    required this.onSubSubcategorySelected,
  });

  double _calculateTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14,
      fontFamily: 'SFPro-Light',
      color: Theme.of(context).colorScheme.onSurface,
    );

    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: SizedBox(
        height: 30,
        child: Stack(
          children: [
            Positioned(
              bottom: 2,
              child: CustomPaint(
                painter: UnderlinePainter(
                  color: Theme.of(context).colorScheme.onSurface,
                  thickness: 2,
                ),
                size: Size(MediaQuery.of(context).size.width - 2 * 20, 2),
              ),
            ),
            ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 0),
              itemCount: subSubcategories.length + 1,
              itemBuilder: (context, index) {
                if (index == subSubcategories.length) {
                  return const SizedBox(width: 0);
                }

                final subSubcategory = subSubcategories[index];
                final isSelected = subSubcategory == selectedSubSubcategory;
                final textWidth = _calculateTextWidth(
                  subSubcategory,
                  textStyle,
                );

                return GestureDetector(
                  onTap: () => onSubSubcategorySelected(subSubcategory),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subSubcategory, style: textStyle),
                        const SizedBox(height: 6),
                        CustomPaint(
                          painter: UnderlinePainter(
                            color:
                                isSelected
                                    ? AppColors.primaryColor
                                    : Theme.of(context).colorScheme.onSurface,
                            thickness: 2,
                          ),
                          size: Size(textWidth, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
