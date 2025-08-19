import 'package:flutter/material.dart';

class GeneratePage extends StatefulWidget {
  @override
  _GeneratePageState createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final TextEditingController promptController = TextEditingController();

  String? generatedImageUrl;
  bool isLoading = false;

  void generateImage() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    // Simulate image generation delay (replace this with real API later)
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isLoading = false;
      generatedImageUrl =
      'https://placehold.co/400x300?text=Image+for:\n${Uri.encodeComponent(prompt)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Your Dream'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: promptController,
              decoration: InputDecoration(
                labelText: 'Enter your dream prompt',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateImage,
              child: Text('Generate Image'),
            ),
            SizedBox(height: 30),
            if (isLoading)
              CircularProgressIndicator()
            else if (generatedImageUrl != null)
              Column(
                children: [
                  Text(
                    'Generated Image:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Image.network(generatedImageUrl!),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
