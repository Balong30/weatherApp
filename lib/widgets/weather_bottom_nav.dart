import 'dart:ui';
import 'package:flutter/material.dart';

class WeatherBottomNav extends StatefulWidget {
  final Color textColor;
  final List<Color> gradientColors;
  final Function(int) onIndexChanged;
  final int initialIndex;

  const WeatherBottomNav({
    super.key,
    required this.textColor,
    required this.gradientColors,
    required this.onIndexChanged,
    this.initialIndex = 0,
  });

  @override
  State<WeatherBottomNav> createState() => _WeatherBottomNavState();
}

class _WeatherBottomNavState extends State<WeatherBottomNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onIndexChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    // Get a vibrant accent color from the gradient
    final accentColor = widget.gradientColors.first;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                    isSelected: _selectedIndex == 0,
                    textColor: widget.textColor,
                    accentColor: accentColor,
                    onTap: _onItemTapped,
                  ),
                  _NavItem(
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search,
                    label: 'Search',
                    index: 1,
                    isSelected: _selectedIndex == 1,
                    textColor: widget.textColor,
                    accentColor: accentColor,
                    onTap: _onItemTapped,
                  ),
                  _NavItem(
                    icon: Icons.location_on_outlined,
                    activeIcon: Icons.location_on,
                    label: 'Locations',
                    index: 2,
                    isSelected: _selectedIndex == 2,
                    textColor: widget.textColor,
                    accentColor: accentColor,
                    onTap: _onItemTapped,
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings',
                    index: 3,
                    isSelected: _selectedIndex == 3,
                    textColor: widget.textColor,
                    accentColor: accentColor,
                    onTap: _onItemTapped,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final bool isSelected;
  final Color textColor;
  final Color accentColor;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.textColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      splashColor: accentColor.withOpacity(0.2),
      highlightColor: accentColor.withOpacity(0.1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: accentColor.withOpacity(0.15),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? accentColor
                    : textColor.withOpacity(0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? accentColor
                    : textColor.withOpacity(0.4),
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}