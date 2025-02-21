import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:camera/camera.dart'; // Import camera plugin

class QRScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  QRScreen({required this.ticket});

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
        padding: const EdgeInsets.only(top: 20, bottom: 40, left: 15, right: 15),
        child: SingleChildScrollView(
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

              // Enlarged rounded QR code
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: QrImageView(
                    data: ticket["qrCode"] ?? "Нет данных",
                    version: QrVersions.auto,
                    size: 400.0,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Новейшая \nтехнология оплаты",
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
                              builder: (context) => CameraScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF24DA88),
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Сканировать QR",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Используйте старый метод",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Color(0xFF444444)),
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
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller; // Camera controller
  late Future<void> _initializeControllerFuture; // Future to initialize the camera

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  void _initializeCamera() async {
    final cameras = await availableCameras(); // Get available cameras
    final firstCamera = cameras.first; // Select the first camera
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    setState(() {}); // Trigger a rebuild to show the loading indicator
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканировать QR'),
        backgroundColor: Color(0xFF24DA88), // AppBar color
        elevation: 10, // No shadow for the AppBar
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture, // Wait for the camera to be initialized
        builder: (context, snapshot) {
          // Show a loading indicator while initializing
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle error if initialization fails
            return Center(child: Text('Ошибка инициализации камеры'));
          } else {
            // Show camera preview once initialized
            return Stack(
              children: [
                // Full-screen camera preview
                Positioned.fill(
                  child: CameraPreview(_controller),
                ),
                // Centered scanning square
                Center(
                  child: Container(
                    width: 250, // Width of the scanning square
                    height: 250, // Height of the scanning square
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // White border for the square
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