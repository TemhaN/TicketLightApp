import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://192.168.8.158:7113/api/users";

  // static const String baseUrl = "https://192.168.176.86:7113/api/users";


  // 🔹 Регистрация пользователя
  static Future<Map<String, dynamic>?> registerUser(
      String fullName, String email, String password, String categoryId, String phoneNumber) async {
    try {
      String url = "$baseUrl/register?categoryId=$categoryId";

      Map<String, dynamic> requestBody = {
        "fullName": fullName,
        "email": email,
        "passwordHash": password, // Пароль
        "phoneNumber": phoneNumber, // Телефон
        "registrationDate": DateTime.now().toIso8601String(), // Текущая дата
        "role": "User", // Роль по умолчанию
      };

      // 🔹 Вывод в консоль перед отправкой
      print("🔹 Отправка запроса на: $url");
      print("🔹 Данные запроса: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      // 🔹 Вывод ответа в консоль
      print("🔹 Код ответа: ${response.statusCode}");
      print("🔹 Ответ сервера: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Ошибка регистрации");
      }
    } catch (e) {
      print("🔹 Ошибка: $e");
      throw Exception("Ошибка: $e");
    }
  }


  // 🔹 Авторизация пользователя
  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"Email": email, "PasswordHash": password}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Response Data: $data"); // Debug the response
      return data;
    }

    return null;
  }


  // 🔹 Получение категорий льгот
  static Future<List<dynamic>?> getCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/categories"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // 🔹 Просмотр заявки
  static Future<Map<String, dynamic>?> getUserApplication(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/$userId/application"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // 🔹 Получение билета
  static Future<Map<String, dynamic>?> getUserTicket(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/$userId/ticket"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
