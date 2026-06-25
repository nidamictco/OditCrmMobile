import 'package:flutter/material.dart';

class AppColors {
  // static const Color background = Color(0xFF0F1E2E);
  static const Color backgroundBlue = Color(0xFFd2e8f9);
  static const Color bottomNavBlue = Color(0xFF002660);
  static const Color skyBlue = Color(0xFF2b85c7);
  static const Color red = Color(0xFFb66158);
  static const Color lightRed = Color(0xFFb66158);
  static const Color orange = Color(0xFFff9700);
  static const Color yellow = Color(0xFFfec51d);
  static const Color violet = Color(0xFFa43bb4);
  static const Color teal = Color(0xFF179b95);
  static const Color green = Color(0xFF60b563);
  // gradient

  static const List<Color> blueGradient = [
    Color(0xFF2a83c5),
    Color(0xFF1b5d91),
  ];

  static const List<Color> lightblueGradient = [
    Color(0xFFb9ddf9),
    Color(0xFFcce7fc),
  ];

  static const List<Color> lightRedGradient = [
    Color(0xFFfee6e4),
    Color(0xFFfdf3f2),
  ];

  static const List<Color> lightVioletGradient = [
    Color(0xFFf2e1f4),
    Color(0xFFf9f2fa),
  ];

  static const List<Color> lightGreenGradient = [
    Color(0xFFdcf0ee),
    Color(0xFFeff9fa),
  ];

  // opacity
  static Color get opacityprimarycolor =>
      const Color(0xFFF7931E).withOpacity(0.10);

  static Color get opacitySecondary =>
      const Color(0xFFE56B0F).withOpacity(0.35);
  static Color get opacityerror => const Color(0xFFE74C3C).withOpacity(0.14);
  static Color get opacitysuccess => const Color(0xff2ECC71).withOpacity(0.14);
}

Color getStatusColor(String stage) {
  switch (stage.toLowerCase()) {
    case 'new':
      return AppColors.skyBlue;
    case 'followup':
      return const Color(0xFFF59E0B);
    case 'transferred':
      return AppColors.teal;
    case 'closed':
      return const Color(0xFF22C55E);
    case 'rejected':
      return const Color(0xFFE74C3C);
    default:
      return Colors.grey;
  }
}

Color getPriorityColor(String priority) {
  switch (priority) {
    case 'High':
      return const Color(0xffEF4444);
    case 'Normal':
      return const Color(0xff22C55E);
    case 'Low':
      return Color.fromARGB(255, 226, 249, 22);
    case 'Negative':
      return const Color(0xff9CA3AF);

    default:
      return Colors.grey;
  }
}
