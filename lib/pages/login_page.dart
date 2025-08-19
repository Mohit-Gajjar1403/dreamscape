import 'package:flutter/material.dart';
import 'package:dreamscape/pages/home_page.dart';
import 'package:dreamscape/pages/register_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Login',
              backgroundColor: Colors.deepPurple,
              textColor: Colors.white,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: () {
                print("Logged in");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: const Text(
                "Don't have an account? Register",
                style: TextStyle(color: Colors.deepPurple),
              ),
            )
          ],
        ),
      ),
    );
  }
}
