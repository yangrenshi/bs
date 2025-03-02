/*
 * @Author: yangrenshi yangrenshi@gmail.com
 * @Date: 2025-02-27 15:10:33
 * @LastEditors: yangrenshi yangrenshi@gmail.com
 * @LastEditTime: 2025-03-02 17:00:14
 * @FilePath: \bs\lib\main.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import 'package:flutter/material.dart';
import 'pages/ai_models_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI辅助液压教学',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 2,
          shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          titleTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w500),
        ),
        cardTheme: CardTheme(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: const AIModelsPage(),
    );
  }
}
