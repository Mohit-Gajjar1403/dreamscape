import 'package:flutter/material.dart';
import '../pages/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await AuthService.login(username, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome back, ${data['username']}")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CustomTextField(
              controller: usernameController,
              hintText: 'Username',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: _isLoading ? 'Logging in...' : 'Login',
              backgroundColor: Colors.deepPurple,
              textColor: Colors.white,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: _isLoading ? () {} : _login,
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
