import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final String categoryId;
  RegistrationScreen({required this.categoryId});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String fullName = "", email = "", password = "", confirmPassword = "", phoneNumber = "", iin = "";
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool isLoading = false;
  String errorMessage = "";

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return "Введите email";
    String pattern = r'\w+@\w+\.\w+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) return 'Введите корректный email';
    return null;
  }

  String? _iinValidator(String? value) {
    if (value == null || value.isEmpty) return "Введите ИИН";
    String pattern = r'^\d{12}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) return 'ИИН должен содержать ровно 12 цифр';
    return null;
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = "";
      });

      if (password != confirmPassword) {
        setState(() {
          isLoading = false;
          errorMessage = "Пароли не совпадают";
        });
        return;
      }

      if (fullName.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty || iin.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Все поля должны быть заполнены";
        });
        return;
      }

      try {
        var result = await ApiService.registerUser(fullName, email, password, widget.categoryId, phoneNumber, iin);
        setState(() {
          isLoading = false;
        });

        if (result != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userId: result["user"]["userId"])),
          );
        } else {
          setState(() {
            errorMessage = "Ошибка регистрации";
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = "Ошибка: ${e.toString()}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FCFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: EdgeInsets.all(25),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Билет",
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF444444),
                          ),
                        ),
                        TextSpan(
                          text: "Лайт",
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF24DA88),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Программа выдачи льготных проездных билетов",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputField("ФИО", (value) => fullName = value),
                        _buildInputField("Email", (value) => email = value, validator: _emailValidator),
                        _buildInputField("Номер телефона", (value) => phoneNumber = value),
                        _buildInputField("ИИН", (value) => iin = value, validator: _iinValidator, isIIN: true),
                        _buildPasswordField("Пароль", (value) => password = value, _isPasswordVisible, () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        }),
                        _buildPasswordField("Подтвердить пароль", (value) => confirmPassword = value, _isConfirmPasswordVisible, () {
                          setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF24DA88),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Зарегистрироваться",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen())
                        );
                      },
                      child: Text(
                        "Есть аккаунт?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF444444),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, Function(String) onChanged, {String? Function(String?)? validator, bool isIIN = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0xFFE6F5EC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,
            contentPadding: EdgeInsets.all(10),
          ),
          onChanged: onChanged,
          validator: validator ?? (value) => value!.isEmpty ? "Заполните поле" : null,
          maxLength: isIIN ? 12 : null,
          inputFormatters: isIIN ? [FilteringTextInputFormatter.digitsOnly] : null,
          keyboardType: isIIN ? TextInputType.number : TextInputType.text,
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, Function(String) onChanged, bool isVisible, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0xFFE6F5EC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,
            contentPadding: EdgeInsets.all(10),
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleVisibility,
            ),
          ),
          obscureText: !isVisible,
          onChanged: onChanged,
          validator: (value) => value!.length < 6 ? "Минимум 6 символов" : null,
        ),
      ),
    );
  }
}