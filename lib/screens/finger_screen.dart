import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../widgets/finger_touch_area.dart';
import 'package:audioplayers/audioplayers.dart';

class FingerScreen extends StatefulWidget {
  final int expectedFingers;
  const FingerScreen({super.key, required this.expectedFingers});

  @override
  State<FingerScreen> createState() => _FingerScreenState();
}

class _FingerScreenState extends State<FingerScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final Map<int, Offset> activeFingers = {};
  final Map<int, Color> fingerColors = {};
  int? selectedIndex;
  int? winnerPointerId;
  Color? winnerColor;

  bool isSelecting = false;
  bool selectionCancelled = false;

  final List<Color> vibrantColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];
  int colorIndex = 0;

  Color getNextColor() {
    final color = vibrantColors[colorIndex % vibrantColors.length];
    colorIndex++;
    return color;
  }

  void _triggerHaptic({bool long = false}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: long ? 150 : 50);
    }
  }

  void _startSelection() async {
    if (isSelecting) return;
    isSelecting = true;
    selectionCancelled = false;

    final rand = Random();
    final total = activeFingers.length;
    int current = rand.nextInt(total);
    int turns = rand.nextInt(10) + 12;

    // 🔧 CORRECTION : Calculer le vainqueur final dès le début
    final finalIndex = (current + turns) % total;
    final fingersList = activeFingers.keys.toList();
    final finalWinnerPointerId = fingersList[finalIndex];
    final finalWinnerColor = fingerColors[finalWinnerPointerId];

    for (int i = 0; i < turns; i++) {
      if (selectionCancelled) {
        setState(() {
          selectedIndex = null;
          winnerPointerId = null;
          winnerColor = null;
          isSelecting = false;
        });
        return;
      }

      setState(() => selectedIndex = (current + i) % total);
      _triggerHaptic();
      audioPlayer.play(AssetSource('sounds/tick.mp3'), volume: 1.0);
      await Future.delayed(const Duration(milliseconds: 120));
    }

    if (!selectionCancelled) {
      // 🔧 CORRECTION : Utiliser les valeurs calculées au début
      setState(() {
        selectedIndex = finalIndex;
        winnerPointerId = finalWinnerPointerId;
        winnerColor = finalWinnerColor;
      });
      _triggerHaptic(long: true);
      audioPlayer.play(AssetSource('sounds/select.mp3'), volume: 1.0);
    }

    isSelecting = false;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (isSelecting) return;
    if (activeFingers.length < widget.expectedFingers &&
        !activeFingers.containsKey(event.pointer)) {
      setState(() {
        activeFingers[event.pointer] = event.position;
        fingerColors[event.pointer] = getNextColor();
      });

      if (activeFingers.length == widget.expectedFingers) {
        _startSelection();
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (activeFingers.containsKey(event.pointer)) {
      setState(() {
        activeFingers[event.pointer] = event.position;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() {
      activeFingers.remove(event.pointer);
      fingerColors.remove(event.pointer);

      if (isSelecting) {
        selectionCancelled = true;
      }

      // 🔧 CORRECTION : Reset complet quand il n'y a plus assez de doigts
      if (activeFingers.length < widget.expectedFingers) {
        selectedIndex = null;
        winnerPointerId = null;
        winnerColor = null;
        isSelecting = false;
        selectionCancelled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = activeFingers.entries.toList();
    final isFinal = winnerPointerId != null && !selectionCancelled;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: isFinal && winnerColor != null ? winnerColor! : Colors.black,
        child: Listener(
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerUp,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Text(
                  "Posez vos doigts sur l'écran",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ),
              ...entries.asMap().entries.map((entry) {
                final index = entry.key;
                final pointerId = entry.value.key;
                final pos = entry.value.value;
                final color = fingerColors[pointerId] ?? Colors.blue;

                final isSelected = selectedIndex == index;
                final isWinner = pointerId == winnerPointerId;

                return FingerTouchArea(
                  position: pos,
                  highlight: isSelected || isWinner,
                  baseColor: color,
                  isFinalSelection: isFinal,
                  isWinner: isWinner,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}