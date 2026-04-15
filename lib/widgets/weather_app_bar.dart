import 'package:flutter/material.dart';
import 'package:weather_app/theme/app_colors.dart';

class WeatherAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Color textColor;

  const WeatherAppBar({
    super.key,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textColor),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.menu,
            color: AppColors.primaryWhite,
          ),
          onPressed: () {
            // TODO: Implement menu action
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}
