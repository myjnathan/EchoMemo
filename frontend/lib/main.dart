import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const EchoMemoApp());
}

class EchoMemoApp extends StatelessWidget {
  const EchoMemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        title: 'EchoMemo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0891B2),
            brightness: Brightness.light,
            primary: const Color(0xFF0891B2),
            secondary: const Color(0xFF22D3EE),
            tertiary: const Color(0xFF059669),
            surface: const Color(0xFFECFEFF),
            onSurface: const Color(0xFF164E63),
          ),
          scaffoldBackgroundColor: const Color(0xFFECFEFF),
          fontFamily: 'SF Pro Display',
        ),
        home: const MainScreen(),
      ),
    );
  }
}
