import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/Screens/Otp_Ver_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;
  int? userId;
  double _logoOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _logoOpacity = 1.0;
      });
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = int.tryParse(prefs.getString('user_id') ?? '');
    });
  }

  Future<void> handleForgetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email.')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('user_id');

      if (storedUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please sign up first.'),
          ),
        );
        return;
      }

      final userId = int.tryParse(storedUserId);
      if (userId == null) {
        throw Exception('Invalid User ID format in local storage');
      }

      final uri = Uri.parse(
        'https://lokate.bsite.net/api/user/ForgetPasswordRequest',
      ).replace(queryParameters: {'email': email});

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('OTP sent to your email')));

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OtpVerScreen(userId: userId)),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email is not registered yet.')),
        );
      } else {
        final errorMsg = _extractErrorMessage(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $errorMsg')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request failed: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _extractErrorMessage(String responseBody) {
    try {
      final body = json.decode(responseBody);
      if (body.containsKey('errors')) {
        final errors = body['errors'] as Map<String, dynamic>;
        return errors.entries
            .map((entry) => '${entry.key}: ${(entry.value as List).join(", ")}')
            .join('\n');
      }
      return body['title'] ?? 'An unknown error occurred.';
    } catch (_) {
      return 'An unknown error occurred.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal:
                  screenWidth > 600 ? screenWidth * 0.2 : screenWidth * 0.1,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    const SizedBox(height: 10),
                    const Text(
                      "Forget your Password?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Enter your email address and we'll send you an OTP to reset your password.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Enter your Email Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1A9C8C),
                              Color.fromARGB(255, 2, 51, 164),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : handleForgetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child:
                              isLoading
                                  ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    "Request OTP",
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
