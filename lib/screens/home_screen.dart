// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'image_editor_screen.dart';
import 'video_editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Editor'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          // Login / Profile Icon Button
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Login or Sign Up',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Video Editor Button
            ElevatedButton.icon(
              icon: const Icon(Icons.videocam),
              label: const Text('Edit Video'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VideoEditorScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(width: 20), // Spacer between buttons

            // Image Editor Button
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Edit Image'),
              onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImageEditorScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}