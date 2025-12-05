import 'package:flutter/material.dart';
import 'package:smartparking/pages/auth/authChecker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  const supabaseUrl = "https://fuboxgorkjpkvreyador.supabase.co";
  const supabaseanonurl =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ1Ym94Z29ya2pwa3ZyZXlhZG9yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2OTQyNzMsImV4cCI6MjA4MDI3MDI3M30.ovTH6ThmcNsTvZOBpHiIDSJcDB7sLEA4-IWJFrOrqEc";

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseanonurl);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const AuthGate(),
    );
  }
}
