import 'package:flutter/material.dart';
import 'package:dreamscape/pages/generate_page.dart';
import 'package:dreamscape/pages/login_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome to Dreamscape! 🌌',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigation to your generate page here (add import too)
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>GeneratePage()));
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'Generate Dream Image',
                  style: TextStyle(
                    color: Colors.blue,           // Text color
                    fontSize: 24,                 // Font size
                    fontWeight: FontWeight.bold, // Font weight
                    fontStyle: FontStyle.italic, // Font style
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
