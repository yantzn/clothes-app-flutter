import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'router.dart';

class ClothesApp extends StatelessWidget {
  const ClothesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '子ども服装ナビ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
