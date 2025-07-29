import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_app/Screens/Bottom_bar_navigation.dart';

class OtpVerScreen extends StatefulWidget {
  const OtpVerScreen({super.key});

  @override
  State<OtpVerScreen> createState() => _OtpVerScreenState();
}

class _OtpVerScreenState extends State<OtpVerScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyOtp() async {
    final String otpCode = otpController.text.trim();

    if (otpCode.isEmpty || otpCode.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit OTP')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://lokate.bsite.net/api/user/vro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"otp": otpCode}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomBarNavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Invalid OTP.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unknown error occurred.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: const Text(
                    "Enter Verification Code",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                const Text("We have sent you a four digit OTP"),
                Center(child: const Text("on your email address")),
                const SizedBox(height: 35),
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 60,
                    fieldWidth: 50,
                    activeFillColor: Colors.white,
                    selectedColor: Colors.blueAccent,
                    activeColor: Colors.green,
                    inactiveColor: Colors.grey,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  controller: otpController,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : verifyOtp,
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
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
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
                                  strokeWidth: 2,
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
                    TextButton(onPressed: () {}, child: const Text("RESEND")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
