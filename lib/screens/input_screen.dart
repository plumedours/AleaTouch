import 'package:flutter/material.dart';
import 'finger_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final controller = TextEditingController();

  void _validate() {
    final number = int.tryParse(controller.text);
    if (number != null && number > 0 && number <= 10) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FingerScreen(expectedFingers: number),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un nombre entre 1 et 10')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nombre de participants")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Entrez le nombre de participants"),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validate,
              child: const Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }
}
