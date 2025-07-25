import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart'; 


void main() {
  // Ensures that widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Sets preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Editor',
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Set HomeScreen as the starting page
    );
  }
}