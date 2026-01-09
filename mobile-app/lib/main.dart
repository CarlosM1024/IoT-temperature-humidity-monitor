import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Tarea02_ESP32/login_screen.dart'; // Importa la nueva pantalla
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 temp & humid App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const LoginScreen(title: 'ESP32 temp & humid App'),
      debugShowCheckedModeBanner: false,
    );
  }
}
