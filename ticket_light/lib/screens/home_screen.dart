import 'package:flutter/material.dart';
import 'package:ticket_light/screens/QRScreen.dart';
import 'package:ticket_light/screens/ProfileScreen.dart';
import '../api_service.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? ticket;
  int _selectedIndex = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    fetchTicket();
  }

  void fetchTicket() async {
    var fetchedTicket = await ApiService.getUserTicket(widget.userId);
    if (fetchedTicket != null) {
      setState(() {
        ticket = fetchedTicket;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Список экранов
  List<Widget> get _screens => [
    _buildHomeContent(),
    QRScreen(ticket: ticket ?? {}),
    ProfileScreen(user: ticket ?? {}),
  ];

  String formatFullName(String fullName) {
    List<String> parts = fullName.split(" ");
    if (parts.length < 2) return fullName; // Если только одно слово, оставляем как есть
    String lastNameInitial = parts[0][0]; // Первая буква фамилии
    return "${parts.sublist(1).join(" ")}. $lastNameInitial";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FCFC),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8FCFC),
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            Spacer(),
            Text(
              formatFullName(ticket?["fullName"] ?? "Загрузка..."),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF444444),
              ),
            ),
            SizedBox(width: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
      body: Stack(
        children: [
          /// Основной контент с переключением экранов
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),

          /// Фиксированный `BottomNavigationBar`
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_filled, size: 40),
                    label: "",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code, size: 40),
                    label: "",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline, size: 40),
                    label: "",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
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
        padding: const EdgeInsets.only(top: 20, bottom: 40, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF444444),
                    height: 1,
                  ),
                  children: [
                    TextSpan(text: "Ваши\n"),
                    TextSpan(
                      text: "льготные\n",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF24DA88),
                      ),
                    ),
                    TextSpan(text: "карты"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            if (ticket != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isFlipped = !_isFlipped;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 25,
                        spreadRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: _isFlipped
                      ? _buildCardBack(ticket!)
                      : _buildCardFront(ticket!),
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Билет ещё не одобрен",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

            const SizedBox(height: 55),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Последние новости:",
                style: TextStyle(fontSize: 25, color: Color(0xFF444444)),
              ),
            ),

            const SizedBox(height: 20),
            _buildNewsList(),

            const SizedBox(height: 40),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Обновления:",
                style: TextStyle(fontSize: 25, color: Color(0xFF444444)),
              ),
            ),

            const SizedBox(height: 20),
            _buildNewsList2(),
            const SizedBox(height: 55),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    return Container(
      height: 210,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(
            width: 180,
            height: 500,
            child: _buildNewsItem("lib/assets/news1.png",
                "На дорогах Казахстана могут снизить максимальную скорость зимой"),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 180,
            height: 500,
            child: _buildNewsItem("lib/assets/news2.png",
                "13 тысяч км автодорог отремонтируют в Казахстане"),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList2() {
    return Container(
      height: 210,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(
            width: 180,
            height: 500,
            child: _buildNewsItem("lib/assets/update1.png",
                "Обновление, инновационный способ оплаты, просто покажи \nQR-код"),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 180,
            height: 500,
            child: _buildNewsItem("lib/assets/update2.png",
                "Технические работы на сервере завершены!"),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(Map<String, dynamic> ticket) {
    return Container(
      width: double.infinity, // Растягиваем на всю ширину родителя
      height: 180, // Фиксированная высота карточки
      padding: EdgeInsets.all(5), // Внутренний отступ
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Распределяем элементы равномерно
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Поднимаем fullName выше
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket["fullName"],
                      style: const TextStyle(
                        fontSize: 22, // Чуть увеличенный шрифт
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 55, // Увеличенный размер аватарки
                backgroundImage: AssetImage("lib/assets/avatar.png"),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.centerLeft, // Льготная карта прижата к левому нижнему углу
            child: Text(
              "Льготная карта",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFF444444),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft, // benefitCategory тоже прижимаем к низу
            child: Text(
              ticket["benefitCategory"],
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF24DA88), // Зеленый цвет
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildCardBack(Map<String, dynamic> ticket) {
    // Конвертируем дату в удобный формат
    String formattedDate = DateFormat("dd.MM.yyyy").format(DateTime.parse(ticket["expiryDate"]));

    return Container(
      width: double.infinity,
      height: 180,
      child: Stack(
        children: [
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF24DA88),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// **Основное содержимое**
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// **Генерация штрих-кода**
              BarcodeWidget(
                barcode: Barcode.code128(),
                data: ticket["barcode"], // Код из данных
                width: 200,
                height: 60,
                drawText: false, // Без подписи
                backgroundColor: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                "Действует до: $formattedDate",
                style: TextStyle(fontSize: 16, color: Color(0xFF444444), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(String imagePath, String text) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          /// Градиентный фон (20% высоты — зелёный, дальше прозрачный)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.2, 1.0], // 20% высоты насыщенный цвет, затем прозрачность
                  colors: [
                    Color(0xFF24DA88).withOpacity(1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          /// Текст
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Уменьшенный размер шрифта
                  height: 1, // Оптимальный межстрочный интервал
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
