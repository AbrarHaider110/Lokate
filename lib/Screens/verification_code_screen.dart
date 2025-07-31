import 'dart:convert';
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
  int remainingAttempts = 3;
  bool showAttemptsWarning = false;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
  }

  Future<void> verifyAccount() async {
    final pin = _pinController.text.trim();

    if (pin.isEmpty || pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 4-digit PIN")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      showAttemptsWarning = false;
    });

    try {
      final response = await http
          .post(
            Uri.parse('https://lokate.bsite.net/api/user/VerifyAccount'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': widget.userId, 'enteredCode': pin}),
          )
          .timeout(const Duration(seconds: 30));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_verified', true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Verification successful'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomBarNavigation()),
        );
      } else {
        setState(() {
          remainingAttempts--;
          showAttemptsWarning = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Verification failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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

                if (showAttemptsWarning && remainingAttempts > 0)
                  Text(
                    '$remainingAttempts attempts remaining',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 10),

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
                  onChanged: (value) {},
                  beforeTextPaste: (text) {
                    return text?.length == 4 && int.tryParse(text!) != null;
                  },
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        isLoading || remainingAttempts <= 0
                            ? null
                            : verifyAccount,
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
                                : Text(
                                  remainingAttempts <= 0
                                      ? 'No Attempts Left'
                                      : 'Verify Account',
                                  style: const TextStyle(
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
