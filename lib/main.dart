import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'SplashScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://jwdraaanhbjdjgnehbqu.supabase.co', // Replace with your Supabase project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp3ZHJhYWFuaGJqZGpnbmVoYnF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcwMzQ3NzgsImV4cCI6MjA1MjYxMDc3OH0.S2m5Ro6Z5SzgplSnN0OkonsPx7Feno_jMxXT_YyPTV8', // Replace with your Supabase public API key
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