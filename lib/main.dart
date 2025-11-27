import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🟦 Inisialisasi Supabase langsung di main.dart
  await Supabase.initialize(
    url: 'https://jevxhhsvretidrfqjltw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpldnhoaHN2cmV0aWRyZnFqbHR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwOTIwOTksImV4cCI6MjA3OTY2ODA5OX0._SzIwIE_4kF7T4xBRp77CZRIKNgE9H3wxhmAmWoR3js',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyTask',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}
