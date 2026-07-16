import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? id;

  const PlaceholderScreen({super.key, required this.title, this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$title Screen is under construction.',
              style: const TextStyle(fontSize: 16),
            ),
            if (id != null) ...[
              const SizedBox(height: 16),
              Text(
                'Provided ID: $id',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
