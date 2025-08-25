import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/Screens/Loginscreen.dart';
import 'package:my_app/Screens/verification_code_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_app/provider/password_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  double _logoOpacity = 0.0;
  static const String baseUrl = 'https://lokate.bsite.net/api/user';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _logoOpacity = 1.0;
      });
    });
  }

  Future<void> register() async {
    final fullName = fullNameController.text.trim();
    final userName = userNameController.text.trim();
    final contact = contactController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (fullName.isEmpty ||
        userName.isEmpty ||
        contact.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => isLoading = true);
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'userName': userName,
          'contact': contact,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['userId'] != null) {
        final userId = responseData['userId'].toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        await prefs.setString('username', userName);
        await prefs.setString('fullname', fullName);
        await prefs.setString('contact', contact);
        await prefs.setString('email', email);
        await prefs.setString('password', password);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please verify your email.'),
          ),
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyCodeScreen(userId: int.parse(userId)),
            ),
          );
        }
      } else {
        final errorMessage = _parseErrorMessage(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _parseErrorMessage(String responseBody) {
    try {
      if (responseBody.isEmpty) return 'Registration failed';
      final error = jsonDecode(responseBody);
      return error['message']?.toString() ??
          error['title']?.toString() ??
          'Registration failed';
    } catch (e) {
      return 'Registration failed: ${responseBody.substring(0, responseBody.length > 100 ? 100 : responseBody.length)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordProvider = Provider.of<PasswordVisibilityProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;
            double horizontalPadding =
                screenWidth > 600 ? screenWidth * 0.2 : screenWidth * 0.1;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
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
                      const SizedBox(height: 16),
                      const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Create a new account by submitting your details for access and authentication.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: fullNameController,
                        label: 'Full Name',
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: userNameController,
                        label: 'Username',
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: contactController,
                        label: 'Contact',
                        inputType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: emailController,
                        label: 'Email',
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: passwordProvider.isObscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              passwordProvider.isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black54,
                            ),
                            onPressed:
                                () => passwordProvider.toggleVisibility(),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black87),
                        cursorColor: Colors.black87,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : register,
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
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child:
                                  isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        "Sign Up",
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
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Loginscreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                color: Color.fromARGB(255, 8, 100, 230),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.black87),
      cursorColor: Colors.black87,
    );
  }
}
