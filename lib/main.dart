import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ticket_light/screens/category_selection_screen.dart';
import 'package:flutter/services.dart'; // Импорт для управления системным UI
import 'package:intl/date_symbol_data_local.dart';

// Класс для отключения проверки SSL-сертификатов
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();  // Отключаем проверку сертификатов
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // Полноэкранный режим
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'БилетЛайт',
      theme: ThemeData(
        primarySwatch: Colors.green, // Основной зеленый цвет
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green, // Зеленый цвет для AppBar
          foregroundColor: Colors.white, // Белый цвет текста AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Зеленые кнопки
            foregroundColor: Colors.white, // Белый текст на кнопках
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green, // Зеленый текст на кнопках
          ),
        ),
      ),
      home: CategorySelectionScreen(), // Ваш стартовый экран
    );
  }
}