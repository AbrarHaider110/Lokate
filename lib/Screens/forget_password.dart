import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Forget your Password?",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenheight * 0.02),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text("Enter your email address and we will send"),
                Center(child: Text("you instructions to reset your password")),
              ],
            ),
            SizedBox(height: screenheight * 0.05),
            SizedBox(
              width: screenwidth * 0.8,
              height: screenheight * 0.08,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Enter your Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            SizedBox(
              width: screenwidth * 0.75,
              height: screenheight * 0.06,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.001, 1.0],
                    colors: [
                      Color(0xFF1A9C8C),
                      Color.fromARGB(255, 2, 51, 164),
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Request reset link",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
