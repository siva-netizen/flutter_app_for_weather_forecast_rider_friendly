import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  // Function to parse QR code data and validate it
  bool validateQRCode(String qrData) {
    try {
      final Map<String, dynamic> data = jsonDecode(qrData);
      final sessionId = data['session_id'];
      final timestamp = DateTime.parse(data['timestamp']);
      final token = data['token'];
      final studentId = data['student_id'];

      // Example: Check if timestamp is within 20 seconds
      final currentTime = DateTime.now();
      if (currentTime.difference(timestamp).inSeconds > 2000) {
        print('QR Code expired');
        return false;
      }

      // Further validation can be added here (e.g., token validation)
      print('Session ID: $sessionId');
      print('Student ID: $studentId');
      return true;
    } catch (e) {
      print('Invalid QR Code format');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SCAN QR"),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: true,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;

          for (final barcode in barcodes) {
            final qrData = barcode.rawValue ?? "";
            print('Barcode found: $qrData');
            if (validateQRCode(qrData)) {
              // Proceed with session verification and log entry
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Valid QR Code'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (image != null) Image.memory(image),
                        const SizedBox(height: 8.0),
                        Text('QR Code Data: $qrData'),
                      ],
                    ),
                  );
                },
              );
            } else {
              print('Invalid or expired QR Code');
            }
          }
        },
      ),
    );
  }
}
