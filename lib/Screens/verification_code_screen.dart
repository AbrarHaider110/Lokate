import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:my_app/Screens/Bottom_bar_navigation.dart';

class VerifyCodeScreen extends StatefulWidget {
  final int userId;
  final String pin;

  const VerifyCodeScreen({super.key, required this.userId, required this.pin});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  TextEditingController _pinController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyAccount() async {
    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the verification PIN")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://lokate.bsite.net/api/user/VerifyAccount'),
        body: {'userId': widget.userId.toString(), 'pin': pin},
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomBarNavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Verification failed'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Enter Verification Code",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                "We have sent you a four digit OTP on your email address.",
              ),
              const SizedBox(height: 35),
              PinCodeTextField(
                controller: _pinController,
                appContext: context,
                length: 4,
                onChanged: (value) {},
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.blue,
                  activeColor: Colors.green,
                ),
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
                    child: Center(
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Continue",
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the Email?"),
                  TextButton(
                    onPressed: () {
                      // Implement resend logic here
                    },
                    child: const Text("RESEND"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
