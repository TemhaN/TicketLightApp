import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';
import 'transaction_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _wallet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWallet();
  }

  Future<void> _fetchWallet() async {
    if (widget.user['userId'] == null) {
      setState(() {
        _wallet = {'balance': 0, 'walletId': null, 'userId': null, 'createdAt': null};
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка: ID пользователя недоступен")),
      );
      return;
    }

    print("🔹 Начало загрузки кошелька для userId: ${widget.user['userId']}");
    setState(() => _isLoading = true);
    try {
      final wallet = await ApiService.getWallet(widget.user['userId']);
      setState(() {
        _wallet = wallet ?? {'balance': 0, 'walletId': null, 'userId': widget.user['userId'], 'createdAt': null};
        _isLoading = false;
      });
      print("🔹 Кошелёк загружен: $_wallet");
    } catch (e) {
      setState(() {
        _isLoading = false;
        _wallet = {'balance': 0, 'walletId': null, 'userId': widget.user['userId'], 'createdAt': null};
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка загрузки кошелька: $e")),
      );
      print("🔹 Ошибка загрузки кошелька: $e");
    }
  }

  Future<void> _deposit(BuildContext context) async {
    final userId = widget.user['userId'];
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка: ID пользователя недоступен")),
      );
      return;
    }

    final amountController = TextEditingController();
    String? selectedPaymentMethod;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Пополнить кошелёк"),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Сумма (тг)"),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                hint: const Text("Выберите способ оплаты"),
                value: selectedPaymentMethod,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: "card", child: Text("Банковская карта")),
                  DropdownMenuItem(value: "mobile", child: Text("Мобильный платёж")),
                ],
                onChanged: (value) {
                  setDialogState(() => selectedPaymentMethod = value);
                },
              ),
              if (selectedPaymentMethod == "card") ...[
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: const InputDecoration(labelText: "Номер карты"),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: const InputDecoration(labelText: "MM/ГГ"),
                        inputFormatters: [ExpiryDateInputFormatter()],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        decoration: const InputDecoration(labelText: "CVV"),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Введите корректную сумму")),
                );
                return;
              }
              if (selectedPaymentMethod == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Выберите способ оплаты")),
                );
                return;
              }

              Navigator.pop(dialogContext);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Обработка платежа..."),
                    ],
                  ),
                ),
              );

              try {
                final result = await ApiService.depositWallet(userId, amount);
                Navigator.pop(context);
                if (result != null) {
                  setState(() {
                    _wallet = {
                      'walletId': result['walletId'] ?? _wallet?['walletId'],
                      'userId': userId,
                      'balance': result['balance'] ?? (_wallet?['balance'] ?? 0) + amount,
                      'createdAt': result['createdAt'] ?? _wallet?['createdAt'],
                    };
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Кошелёк пополнен на $amount тг")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ошибка пополнения")),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Ошибка: $e")),
                );
              }
            },
            child: const Text("Оплатить"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Баланс: ${_wallet?['balance'] ?? 0} тг",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF24DA88),
                    ),
                  ),
                ),
                _buildButton(context, Icons.account_balance_wallet, "Пополнить кошелёк", () => _deposit(context)),
                _buildButton(context, Icons.history, "Транзакции", () {
                  if (widget.user['userId'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ошибка: ID пользователя недоступен")),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionScreen(userId: widget.user['userId']),
                    ),
                  );
                }),
                _buildButton(context, Icons.settings, "Настройки", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                }),
                _buildButton(context, Icons.location_city, "Мой город", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CityScreen()),
                  );
                }),
                _buildButton(context, Icons.info, "О приложении", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                }),
                _buildButton(context, Icons.support_agent, "Служба поддержки", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SupportScreen()),
                  );
                }),
                const SizedBox(height: 140),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF24DA88).withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text(
                        "Поделиться с друзьями",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24DA88),
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
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
          color: const Color(0xFFE6F5EC),
          borderRadius: BorderRadius.circular(40),
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF24DA88)),
          title: Text(text, style: const TextStyle(fontSize: 18)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 22, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String formattedText = '';
    if (newText.isNotEmpty) {
      if (newText.length <= 2) {
        formattedText = newText;
      } else {
        String month = newText.substring(0, 2);
        String year = newText.substring(2, newText.length.clamp(2, 4));
        formattedText = '$month/$year';
      }
    }
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

bool isValidExpiryDate(String input) {
  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(input)) return false;
  try {
    final parts = input.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);
    if (month < 1 || month > 12) return false;
    final currentYear = DateTime.now().year % 100;
    if (year < currentYear || year > 99) return false;
    return true;
  } catch (e) {
    return false;
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("О приложении"),
        backgroundColor: const Color(0xFF24DA88),
        foregroundColor: Colors.white,
      ),
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
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "О нашем приложении",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Это приложение создано, чтобы упростить ваши финансовые операции. Пополняйте кошелёк, совершайте платежи и отслеживайте транзакции в одном месте. Мы стремимся к максимальному удобству и безопасности.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Версия приложения: 1.0.0",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Разработчик: xAI Team",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Контакты: support@xai.com",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24DA88),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Проверить обновления",
                      style: TextStyle(fontSize: 18, color: Colors.white),
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

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _messageController = TextEditingController();
  String? _selectedIssue;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Служба поддержки"),
        backgroundColor: const Color(0xFF24DA88),
        foregroundColor: Colors.white,
      ),
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
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Свяжитесь с нами",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  hint: const Text("Выберите проблему"),
                  value: _selectedIssue,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "payment", child: Text("Проблема с платежом")),
                    DropdownMenuItem(value: "account", child: Text("Проблема с аккаунтом")),
                    DropdownMenuItem(value: "other", child: Text("Другое")),
                  ],
                  onChanged: (value) => setState(() => _selectedIssue = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Опишите проблему",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedIssue == null || _messageController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Заполните все поля")),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Сообщение отправлено")),
                      );
                      _messageController.clear();
                      setState(() => _selectedIssue = null);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24DA88),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Отправить",
                      style: TextStyle(fontSize: 18, color: Colors.white),
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

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  _CityScreenState createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  String? _selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мой город"),
        backgroundColor: const Color(0xFF24DA88),
        foregroundColor: Colors.white,
      ),
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
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Выберите ваш город",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  hint: const Text("Выберите город"),
                  value: _selectedCity,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "almaty", child: Text("Алматы")),
                    DropdownMenuItem(value: "astana", child: Text("Астана")),
                    DropdownMenuItem(value: "shymkent", child: Text("Шымкент")),
                    DropdownMenuItem(value: "karaganda", child: Text("Караганда")),
                  ],
                  onChanged: (value) => setState(() => _selectedCity = value),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedCity == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Выберите город")),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Город $_selectedCity сохранён")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24DA88),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Сохранить",
                      style: TextStyle(fontSize: 18, color: Colors.white),
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
        backgroundColor: const Color(0xFF24DA88),
        foregroundColor: Colors.white,
      ),
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
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Настройки приложения",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Уведомления", style: TextStyle(fontSize: 18)),
                  value: _notificationsEnabled,
                  activeColor: const Color(0xFF24DA88),
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                ),
                SwitchListTile(
                  title: const Text("Тёмная тема", style: TextStyle(fontSize: 18)),
                  value: _darkMode,
                  activeColor: const Color(0xFF24DA88),
                  onChanged: (value) => setState(() => _darkMode = value),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  hint: const Text("Язык приложения"),
                  value: _selectedLanguage,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "ru", child: Text("Русский")),
                    DropdownMenuItem(value: "kz", child: Text("Қазақша")),
                    DropdownMenuItem(value: "en", child: Text("English")),
                  ],
                  onChanged: (value) => setState(() => _selectedLanguage = value),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Настройки сохранены")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24DA88),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Сохранить",
                      style: TextStyle(fontSize: 18, color: Colors.white),
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