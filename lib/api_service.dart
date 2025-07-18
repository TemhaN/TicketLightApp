import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://192.168.223.86:7113/api";

  static Future<Map<String, dynamic>?> registerUser(
      String fullName, String email, String password, String categoryId, String phoneNumber, String? iin) async {
    try {
      String url = "$baseUrl/users/register?categoryId=$categoryId";
      Map<String, dynamic> requestBody = {
        "fullName": fullName,
        "email": email,
        "passwordHash": password,
        "phoneNumber": phoneNumber,
        "iin": iin,
        "registrationDate": DateTime.now().toIso8601String(),
        "role": "User",
      };
      print("🔹 Отправка запроса на: $url");
      print("🔹 Данные запроса: ${jsonEncode(requestBody)}");
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      print("🔹 Код ответа: ${response.statusCode}");
      print("🔹 Ответ сервера: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Ошибка регистрации: ${response.body}");
      }
    } catch (e) {
      print("🔹 Ошибка: $e");
      throw Exception("Ошибка: $e");
    }
  }

  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"Email": email, "PasswordHash": password}),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Response Data: $data");
      return data;
    }
    return null;
  }

  static Future<List<dynamic>?> getCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/users/categories"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getUserApplication(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/users/$userId/application"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getUserTicket(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/users/$userId/ticket"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getUserById(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/users/$userId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<List<dynamic>?> getWalletTransactions(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/wallets/$userId/transactions"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> depositWallet(int userId, double amount) async {
    final response = await http.post(
      Uri.parse("$baseUrl/wallets/$userId/deposit"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(amount),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getWallet(int userId) async {
    try {
      print("🔹 Запрос кошелька для userId: $userId");
      final response = await http.get(Uri.parse("$baseUrl/wallets/$userId"))
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception("Таймаут сервера");
      });
      print("🔹 Код ответа: ${response.statusCode}, тело: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception("Ошибка сервера: ${response.statusCode}, ${response.body}");
    } catch (e) {
      print("🔹 Ошибка запроса кошелька: $e");
      throw Exception("Ошибка: $e");
    }
  }
}