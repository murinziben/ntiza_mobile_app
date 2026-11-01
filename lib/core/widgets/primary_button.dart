import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Full-width green button (52px, 13px radius, bold) with the prototype's soft shadow.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showArrow = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: const [
          BoxShadow(color: Color(0x30168A45), blurRadius: 18, offset: Offset(0, 7)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            if (showArrow) ...[
              const SizedBox(width: 8),
              const Text('→', style: TextStyle(fontSize: 20)),
            ],
          ],
        ),
      ),
    );
  }
}
