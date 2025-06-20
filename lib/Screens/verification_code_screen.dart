import 'package:flutter/material.dart';
import 'package:my_app/Screens/Bottom_bar_navigation.dart';

class Vercodescreen extends StatelessWidget {
  const Vercodescreen({super.key});

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
              "Enter Verification Code",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenheight * 0.02),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("We have sent you a four digit OTP"),
                Text("on your email address"),
              ],
            ),
            SizedBox(height: screenheight * 0.05),
            SizedBox(
              width: screenwidth * 0.8,
              height: screenheight * 0.08,
              child: const TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Verification Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenheight * 0.02),

            // Gradient Button
            SizedBox(
              width: screenwidth * 0.8,
              height: screenheight * 0.06,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BottomBarScreen()),
                  );
                },
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
                      stops: [0.001, 1.0],
                      colors: [
                        Color(0xFF1A9C8C),
                        Color.fromARGB(255, 2, 51, 164),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
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

            SizedBox(height: screenheight * 0.02),
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
    );
  }
}
