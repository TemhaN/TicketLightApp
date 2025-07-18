import 'package:flutter/material.dart';
import 'package:ticket_light/screens/login_screen.dart';
import '../api_service.dart';
import 'registration_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<dynamic> categories = [];
  String? selectedCategory;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      var fetchedCategories = await ApiService.getCategories();
      if (fetchedCategories != null && fetchedCategories.isNotEmpty) {
        setState(() {
          categories = fetchedCategories;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Нет доступных категорий";
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = "Ошибка загрузки категорий: $error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FCFC), // Светлый фон
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: EdgeInsets.all(25),
            height: 500, // Увеличенная высота контейнера
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Билет",
                        style: TextStyle(
                          fontSize: 38, // Увеличенный размер шрифта
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF444444),
                        ),
                      ),

                      TextSpan(
                        text: "Лайт",
                        style: TextStyle(
                          fontSize: 38, // Увеличенный размер шрифта
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF24DA88),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(text: "Программа выдачи "),
                      TextSpan(
                        text: "льготных\n",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF24DA88),
                        ),
                      ),
                      TextSpan(text: "проездных билетов"),
                    ],
                  ),
                ),
                SizedBox(height: 70),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Выберите категорию:",
                    style: TextStyle(fontSize: 16, color: Color(0xFF444444)),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFE6F5EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text("Выберите категорию"),
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category["categoryId"].toString(),
                          child: Text(category["categoryName"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: selectedCategory != null
                      ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegistrationScreen(
                                  categoryId: selectedCategory!)))
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF24DA88),
                    padding: EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Начать регистрацию",
                    style:
                    TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerRight, // Выравнивание вправо
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "Есть аккаунт?",
                      style: TextStyle(fontSize: 16, color: Color(0xFF444444), fontWeight: FontWeight.w400),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
