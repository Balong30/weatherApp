import 'package:flutter/material.dart';

class UnitToggle extends StatefulWidget {
  final bool isCelsius;
  final ValueChanged<bool> onChanged;
  final Color textColor;

  const UnitToggle({
    super.key,
    required this.isCelsius,
    required this.onChanged,
    required this.textColor,
  });

  @override
  State<UnitToggle> createState() =>
      _UnitToggleState();
}

class _UnitToggleState extends State<UnitToggle> {
  bool _isHoveringC = false;
  bool _isHoveringF = false;

  @override
  Widget build(BuildContext context) {
    final selectedStyle = TextStyle(
      color: widget.textColor,
      fontSize: 16,
    );
    final unselectedStyle = TextStyle(
      color: widget.textColor.withOpacity(0.5),
      fontSize: 16,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          onEnter: (_) =>
              setState(() => _isHoveringC = true),
          onExit: (_) => setState(
            () => _isHoveringC = false,
          ),
          child: GestureDetector(
            onTap: () => widget.onChanged(true),
            child: Text(
              '°C',
              style:
                  widget.isCelsius || _isHoveringC
                  ? selectedStyle
                  : unselectedStyle,
            ),
          ),
        ),
        const SizedBox(width: 16),
        MouseRegion(
          onEnter: (_) =>
              setState(() => _isHoveringF = true),
          onExit: (_) => setState(
            () => _isHoveringF = false,
          ),
          child: GestureDetector(
            onTap: () => widget.onChanged(false),
            child: Text(
              '°F',
              style:
                  !widget.isCelsius ||
                      _isHoveringF
                  ? selectedStyle
                  : unselectedStyle,
            ),
          ),
        ),
      ],
    );
  }
}
