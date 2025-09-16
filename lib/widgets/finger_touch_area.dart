import 'package:flutter/material.dart';

class FingerTouchArea extends StatefulWidget {
  final Offset position;
  final bool highlight;
  final Color baseColor;
  final bool isFinalSelection;
  final bool isWinner;

  const FingerTouchArea({
    super.key,
    required this.position,
    this.highlight = false,
    required this.baseColor,
    this.isFinalSelection = false,
    this.isWinner = false,
  });

  @override
  State<FingerTouchArea> createState() => _FingerTouchAreaState();
}

class _FingerTouchAreaState extends State<FingerTouchArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulse = Tween<double>(
      begin: 0.9,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 🔧 CORRECTION : Démarrer l'animation immédiatement
    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(FingerTouchArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔧 CORRECTION : Contrôler l'animation selon le statut
    if (widget.isFinalSelection) {
      if (widget.isWinner) {
        // Le vainqueur continue à pulser
        if (!_controller.isAnimating) {
          _controller.repeat(reverse: true);
        }
      } else {
        // Les perdants arrêtent de pulser
        _controller.stop();
        _controller.reset();
      }
    } else {
      // Pendant la sélection, tous pulsent
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
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
    final double size = widget.isWinner ? 160 : 120;
    final bool dimmed = widget.isFinalSelection && !widget.isWinner;

    // Calcul de l’intensité du halo
    double highlightIntensity = 0.0;
    if (widget.isFinalSelection && widget.isWinner) {
      highlightIntensity = 1.0;
    } else if (!widget.isFinalSelection) {
      highlightIntensity = widget.highlight ? 1.0 : 0.3;
    }

    // Couleur contrastée pour le gagnant
    Color effectiveColor = widget.baseColor;
    if (widget.isFinalSelection && widget.isWinner) {
      final luminance = widget.baseColor.computeLuminance();
      effectiveColor = luminance > 0.5 ? Colors.black : Colors.white;
    }

    return Positioned(
      left: widget.position.dx - size / 2,
      top: widget.position.dy - size / 2,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) {
          final scale = 1.0 + ((_pulse.value - 1.0) * highlightIntensity);

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: dimmed ? 0.3 : 1.0,
            child: Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dimmed
                      ? Colors.transparent
                      : (widget.isFinalSelection && widget.isWinner)
                      ? effectiveColor.withAlpha(
                          (200 * highlightIntensity).round(),
                        )
                      : widget.baseColor.withAlpha(
                          (150 * highlightIntensity).round(),
                        ),
                  border: dimmed
                      ? Border.all(
                          color: widget.baseColor.withAlpha(80),
                          width: 1,
                        )
                      : null,
                  boxShadow: dimmed
                      ? []
                      : [
                          BoxShadow(
                            color: (widget.isFinalSelection && widget.isWinner)
                                ? effectiveColor.withAlpha(
                                    (255 * highlightIntensity).round(),
                                  )
                                : widget.baseColor.withAlpha(
                                    (200 * highlightIntensity).round(),
                                  ),
                            blurRadius:
                                (widget.isWinner ? 40 : 20) *
                                highlightIntensity,
                            spreadRadius:
                                (widget.isWinner ? 20 : 8) * highlightIntensity,
                          ),
                        ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}