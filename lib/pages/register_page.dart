import 'package:flutter/material.dart';
import '../pages/auth_service.dart';
import 'login_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.register(username, email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered successfully! Please login.")),
      );

      // Redirect to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CustomTextField(controller: usernameController, hintText: "Username"),
            const SizedBox(height: 16),
            CustomTextField(controller: emailController, hintText: "Email"),
            const SizedBox(height: 16),
            CustomTextField(controller: passwordController, hintText: "Password", obscureText: true),
            const SizedBox(height: 24),
            CustomButton(
              text: _isLoading ? 'Registering...' : 'Register',
              backgroundColor: Colors.deepPurple,
              textColor: Colors.white,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: _isLoading ? () {} : _register,
            ),
          ],
        ),
      ),
    );
  }
}
