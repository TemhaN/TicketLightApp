import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  ProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildButton(context, Icons.settings, "Настройки", () {
                  // Логика перехода в настройки
                }),
                _buildButton(context, Icons.language, "Язык", () {
                  // Логика смены языка
                }),
                _buildButton(context, Icons.location_city, "Мой город", () {
                  // Логика выбора города
                }),
                _buildButton(context, Icons.info, "О приложении", () {
                  // Открытие информации о приложении
                }),
                _buildButton(context, Icons.support_agent, "Служба поддержки", () {
                  // Переход в службу поддержки
                }),

                SizedBox(height: 370), // Добавляем отступ перед кнопкой

                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF24DA88).withOpacity(0.6), // Цвет тени с прозрачностью
                          blurRadius: 30, // Сильное размытие тени
                          spreadRadius: 5, // Распределение тени вокруг кнопки
                          offset: Offset(0, 0), // Смещение вниз
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30), // Скругление тени как у кнопки
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Логика для кнопки "Поделиться с друзьями"
                      },
                      icon: Icon(Icons.share, color: Colors.white),
                      label: Text(
                        "Поделиться с друзьями",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF24DA88), // Цвет кнопки
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 49),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0, // Убираем стандартную тень кнопки
                      ),
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

  Widget _buildButton(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE6F5EC),
          borderRadius: BorderRadius.circular(40),
        ),
        child: ListTile(
          leading: Icon(icon, color: Color(0xFF24DA88)),
          title: Text(text, style: TextStyle(fontSize: 18)),
          trailing: Icon(Icons.arrow_forward_ios, size: 22, color: Colors.grey),
          onTap: onTap, // Логика перехода в соответствующий раздел
        ),
      ),
    );
  }

}
