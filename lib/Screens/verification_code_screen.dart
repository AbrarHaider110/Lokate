import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:my_app/Screens/Bottom_bar_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyCodeScreen extends StatefulWidget {
  final int userId;

  const VerifyCodeScreen({super.key, required this.userId});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  late final TextEditingController _pinController;
  bool isLoading = false;
  double _logoOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    setState(() {
      _logoOpacity = 1.0;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> verifyPin() async {
    final pin = _pinController.text.trim();

    if (pin.isEmpty || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      _showSnackBar('Invalid PIN format (must be 4 digits)', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final uri = Uri.parse(
        'https://lokate.bsite.net/api/user/VerifyAccount?userId=${widget.userId}&pin=$pin',
      );

      final response = await http.post(
        uri,
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_verified', true);

        _showSnackBar(data['message'] ?? 'Account verified!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomBarNavigation()),
        );
      } else {
        final pinError = data['errors']?['pin']?[0];
        final message = pinError ?? data['message'] ?? 'Verification failed';
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding =
        screenWidth > 600 ? screenWidth * 0.2 : screenWidth * 0.1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 30,
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _logoOpacity,
                  duration: const Duration(seconds: 1),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/authimg.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Text(
                  "Verify Your Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter the 4-digit verification PIN sent to you",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 30),

                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 60,
                    fieldWidth: 50,
                    activeFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    inactiveFillColor: Colors.grey[100],
                    activeColor: Colors.blue,
                    selectedColor: Colors.blue,
                    inactiveColor: Colors.grey,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  enableActiveFill: true,
                  onChanged: (_) {},
                  onCompleted: (_) => verifyPin(),
                  beforeTextPaste:
                      (text) =>
                          text != null && RegExp(r'^\d{4}$').hasMatch(text),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : verifyPin,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1A9C8C),
                            Color.fromARGB(255, 2, 51, 164),
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                                : const Text(
                                  'Verify Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
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

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
