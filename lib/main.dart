import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lleiuchgukmblykhhduz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsZWl1Y2hndWttYmx5a2hoZHV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2MjU1MzYsImV4cCI6MjA2MzIwMTUzNn0.TolJDNpew7JVGe2tP9ngx3BHR97LNNvyZNTALE-cDT8',
  );

  runApp(const MyApp());
}

String currentUserRole = ''; // GLOBAL role user

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Warda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginPage(),
    );
  }
}
