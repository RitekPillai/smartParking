import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartparking/pages/homePage.dart';
import 'package:smartparking/pages/roleSelection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  const supabaseUrl = "https://fuboxgorkjpkvreyador.supabase.co";
  const supabaseanonurl =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ1Ym94Z29ya2pwa3ZyZXlhZG9yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2OTQyNzMsImV4cCI6MjA4MDI3MDI3M30.ovTH6ThmcNsTvZOBpHiIDSJcDB7sLEA4-IWJFrOrqEc";

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseanonurl);
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Homepage(),
    );
  }
}
