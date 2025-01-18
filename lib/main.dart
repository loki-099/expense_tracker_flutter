import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'SplashScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ofkpaicinrgrznegomrr.supabase.co', // Replace with your Supabase project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ma3BhaWNpbnJncnpuZWdvbXJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcwODI4MjksImV4cCI6MjA1MjY1ODgyOX0.6kpp85_J-YStD_Qyeizx4zIdK70MDk6IdVOjcgf-x_w', // Replace with your Supabase public API key
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login with Supabase',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}