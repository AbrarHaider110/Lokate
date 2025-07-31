import 'package:flutter/material.dart';
import 'package:my_app/Screens/Bottom_bar_navigation.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class OtpVerScreen extends StatefulWidget {
  final int userId;

  const OtpVerScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<OtpVerScreen> createState() => _OtpVerScreenState();
}

class _OtpVerScreenState extends State<OtpVerScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool isLoading = false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> verifyAccount() async {
    final String pin = _pinController.text.trim();

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      _showErrorSnackBar('Invalid PIN format (must be 4 digits)');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('https://lokate.bsite.net/api/user/VerifyPin'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'userId': widget.userId, 'pin': pin}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BottomBarNavigation()),
            (route) => false,
          );
        }
      } else {
        final errorMsg = responseData['message'] ?? 'Verification failed';
        _showErrorSnackBar(errorMsg);
      }
    } on TimeoutException {
      _showErrorSnackBar('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      _showErrorSnackBar('Network error: ${e.message}');
    } on FormatException {
      _showErrorSnackBar('Invalid server response');
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred');
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                  onChanged: (value) {},
                  onCompleted: (pin) => verifyAccount(),
                  beforeTextPaste:
                      (text) =>
                          text?.length == 4 && int.tryParse(text!) != null,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : verifyAccount,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                                )
                                : const Text(
                                  'Verify',
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
}
