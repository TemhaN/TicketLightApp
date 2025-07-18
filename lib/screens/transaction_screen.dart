import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TransactionScreen extends StatefulWidget {
  final int userId;

  const TransactionScreen({required this.userId, super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<dynamic> transactions = [];
  bool isLoading = true;
  bool isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocaleAndFetch();
  }

  Future<void> _initializeLocaleAndFetch() async {
    try {
      await initializeDateFormatting('ru', null);
      setState(() => isLocaleInitialized = true);
      await _fetchTransactions();
    } catch (e) {
      setState(() {
        isLoading = false;
        isLocaleInitialized = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка инициализации: $e")),
      );
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      final fetchedTransactions = await ApiService.getWalletTransactions(widget.userId);
      setState(() {
        transactions = fetchedTransactions ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e")),
      );
    }
  }

  Map<String, List<dynamic>> _groupTransactionsByDate() {
    if (!isLocaleInitialized) return {};
    final grouped = <String, List<dynamic>>{};
    for (var transaction in transactions) {
      final date = DateTime.parse(transaction['createdAt']).toLocal();
      final dateKey = DateFormat('dd MMMM yyyy', 'ru').format(date);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }
    return grouped;
  }

  String _translateTransactionType(String type) {
    return type == 'Deposit' ? 'Пополнение' : 'Оплата проезда';
  }

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = _groupTransactionsByDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text("История транзакций"),
        backgroundColor: const Color(0xFF24DA88),
      ),
      body: isLoading || !isLocaleInitialized
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? const Center(child: Text("Нет транзакций"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedTransactions.length,
        itemBuilder: (context, index) {
          final date = groupedTransactions.keys.elementAt(index);
          final transactionsForDate = groupedTransactions[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...transactionsForDate.map((transaction) {
                final isWithdrawal = transaction['transactionType'] == 'Withdrawal';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      "${_translateTransactionType(transaction['transactionType'])} ${transaction['amount']} тг",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isWithdrawal ? Colors.red : const Color(0xFF24DA88),
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('HH:mm', 'ru').format(
                        DateTime.parse(transaction['createdAt']).toLocal(),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    leading: Icon(
                      transaction['transactionType'] == 'Deposit'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: isWithdrawal ? Colors.red : const Color(0xFF24DA88),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}