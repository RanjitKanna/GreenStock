import 'package:flutter/material.dart';
import '../utils/currency_cubit.dart';
import 'tappable_scale.dart';

class CurrencyToggle extends StatefulWidget {
  final CurrencyType currentType;
  final VoidCallback onToggle;

  const CurrencyToggle({
    super.key,
    required this.currentType,
    required this.onToggle,
  });

  @override
  State<CurrencyToggle> createState() => _CurrencyToggleState();
}

class _CurrencyToggleState extends State<CurrencyToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thumbAlignment;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _thumbAlignment = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    if (widget.currentType == CurrencyType.inr) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CurrencyToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentType != oldWidget.currentType) {
      if (widget.currentType == CurrencyType.inr) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TappableScale(
      onTap: widget.onToggle,
      scale: 0.94,
      child: Container(
        width: 60,
        height: 30,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final alignment = Alignment.lerp(
              Alignment.centerLeft,
              Alignment.centerRight,
              _thumbAlignment.value,
            )!;

            return Stack(
              children: [
                Align(
                  alignment: alignment,
                  child: Container(
                    width: 22,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                child!,
              ],
            );
          },
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: _FlagIcon(
                    type: CurrencyType.usd,
                    isSelected: widget.currentType == CurrencyType.usd,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _FlagIcon(
                    type: CurrencyType.inr,
                    isSelected: widget.currentType == CurrencyType.inr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlagIcon extends StatelessWidget {
  final CurrencyType type;
  final bool isSelected;

  const _FlagIcon({required this.type, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final assetPath = type == CurrencyType.usd
        ? 'assets/images/usa_flag.png'
        : 'assets/images/india_flag.png';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isSelected ? 1.0 : 0.2,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.05),
            width: 0.5,
          ),
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
