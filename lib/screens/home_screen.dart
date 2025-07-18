import 'package:flutter/material.dart';
import 'package:ticket_light/screens/QRScreen.dart';
import 'package:ticket_light/screens/ProfileScreen.dart';
import '../api_service.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({required this.userId, super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? ticket;
  Map<String, dynamic>? user;
  int _selectedIndex = 0;
  bool _isFlipped = false;
  bool isLoading = true;
  String? errorMessage;

  final GlobalKey<QRScreenState> _qrScreenKey = GlobalKey<QRScreenState>();

  @override
  void initState() {
    super.initState();
    fetchUserAndTicket();
  }

  Future<void> fetchUserAndTicket() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      var fetchedUser = await ApiService.getUserById(widget.userId);
      var fetchedTicket = await ApiService.getUserTicket(widget.userId);

      setState(() {
        user = fetchedUser;
        ticket = fetchedTicket;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Ошибка загрузки данных: ${e.toString()}";
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1 && _qrScreenKey.currentState != null) {
      _qrScreenKey.currentState!.activate();
    }
  }

  List<Widget> get _screens => [
    RefreshIndicator(
      onRefresh: fetchUserAndTicket, // Обновление при "потянуть вниз"
      color: const Color(0xFF24DA88),
      child: _buildHomeContent(),
    ),
    QRScreen(
      ticket: ticket,
      qrKey: _qrScreenKey,
      userId: widget.userId,
    ),
    ProfileScreen(user: user ?? {}),
  ];

  String formatFullName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return "Пользователь";
    List<String> parts = fullName.split(" ");
    if (parts.length < 2) return fullName;
    String lastNameInitial = parts[0][0];
    return "${parts.sublist(1).join(" ")}. $lastNameInitial";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FCFC),
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            const Spacer(),
            Text(
              isLoading ? "Загрузка..." : formatFullName(user?["fullName"]),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF444444),
              ),
            ),
            const SizedBox(width: 20),
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
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.person, size: 50, color: Colors.black),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Center(
                child: Text(errorMessage!,
                    style: const TextStyle(fontSize: 18, color: Colors.red)))
          else
            IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, -5),
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
      physics: const AlwaysScrollableScrollPhysics(), // Для работы RefreshIndicator
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
            if (ticket != null && ticket!.isNotEmpty)
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
            child: _buildNewsItem(
                "lib/assets/news1.png",
                "На дорогах Казахстана могут снизить максимальную скорость зимой"),
          ),
          const SizedBox(width: 20),
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
          const SizedBox(width: 20),
          SizedBox(
            width: 180,
            height: 500,
            child: _buildNewsItem(
                "lib/assets/update2.png",
                "Технические работы на сервере завершены!"),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(Map<String, dynamic> ticket) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket["fullName"] ?? "Неизвестно",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage("lib/assets/avatar.png"),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.centerLeft,
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
            alignment: Alignment.centerLeft,
            child: Text(
              ticket["benefitCategory"] ?? "Не указана",
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF24DA88),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Map<String, dynamic> ticket) {
    String formattedDate = ticket["expiryDate"] != null
        ? DateFormat("dd.MM.yyyy").format(DateTime.parse(ticket["expiryDate"]))
        : "Не указана";

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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BarcodeWidget(
                barcode: Barcode.code128(),
                data: ticket["barcode"] ?? "Нет данных",
                width: 200,
                height: 60,
                drawText: false,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                "Действует до: $formattedDate",
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF444444),
                    fontWeight: FontWeight.w500),
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
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.2, 1.0],
                  colors: [
                    const Color(0xFF24DA88).withOpacity(1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}