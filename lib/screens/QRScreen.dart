import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';
import 'package:camera/camera.dart';

class QRScreen extends StatefulWidget {
  final Map<String, dynamic>? ticket;
  final GlobalKey<QRScreenState> qrKey;
  final int userId;

  const QRScreen({
    required this.ticket,
    required this.qrKey,
    required this.userId,
    super.key,
  });

  @override
  QRScreenState createState() => QRScreenState();
}

class QRScreenState extends State<QRScreen> {
  static const platform = MethodChannel('com.example.screenshot');
  Map<String, dynamic>? _currentTicket;
  Timer? _qrCheckTimer;

  @override
  void initState() {
    super.initState();
    _currentTicket = widget.ticket;
    _disableScreenshots();
    _startQRCheck();
  }

  Future<void> _disableScreenshots() async {
    try {
      await platform.invokeMethod('disableScreenshots');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Скриншоты QR-кода ограничены!")),
      );
    } catch (e) {
      print("🔹 Ошибка блокировки скриншотов: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка блокировки скриншотов: $e")),
      );
    }
  }

  Future<void> _enableScreenshots() async {
    try {
      await platform.invokeMethod('enableScreenshots');
    } catch (e) {
      print("🔹 Ошибка разблокировки скриншотов: $e");
    }
  }

  void _startQRCheck() {
    _qrCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!mounted) return;
      await _refreshQRCode();
    });
  }

  Future<void> _refreshQRCode() async {
    try {
      final newTicket = await ApiService.getUserTicket(widget.userId);
      if (newTicket != null && newTicket['qrCode'] != _currentTicket?['qrCode']) {
        setState(() {
          _currentTicket = newTicket;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR-код обновлён")),
        );
      }
    } catch (e) {
      print("🔹 Ошибка проверки QR-кода: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка проверки QR-кода: $e")),
      );
    }
  }

  @override
  void dispose() {
    _qrCheckTimer?.cancel();
    _enableScreenshots();
    super.dispose();
  }

  void activate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Скриншоты QR-кода ограничены!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasQRCode = _currentTicket != null && _currentTicket!['qrCode']?.isNotEmpty == true;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshQRCode, // Вызывается при "потянуть вниз"
        color: const Color(0xFF24DA88), // Цвет индикатора
        child: Container(
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
          padding: const EdgeInsets.only(top: 20, bottom: 40, left: 15, right: 15),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Для работы RefreshIndicator
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
                        TextSpan(text: "Ваш\n"),
                        TextSpan(
                          text: "льготный QR код\n",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF24DA88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: hasQRCode
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: QrImageView(
                      data: _currentTicket!['qrCode'],
                      version: QrVersions.auto,
                      size: 330.0,
                    ),
                  )
                      : const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Билет ещё не одобрен",
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Новейшая\nтехнология оплаты",
                    style: TextStyle(fontSize: 25, color: Color(0xFF444444)),
                  ),
                ),
                const SizedBox(height: 120),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CameraScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24DA88),
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Сканировать QR",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Используйте старый метод",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
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

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("Камеры не найдены");
      }
      final firstCamera = cameras.first;
      _controller = CameraController(firstCamera, ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("🔹 Ошибка инициализации камеры: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка инициализации камеры: $e")),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializeControllerFuture == null || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканировать QR'),
        backgroundColor: const Color(0xFF24DA88),
        elevation: 10,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка инициализации камеры'));
          } else {
            return Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}