import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

class ItSupportPage extends StatelessWidget {
  final String phoneNumber = '+962799378583';
  final String email = 'support@ju.edu.jo';

  void _copyNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Phone number copied')),
    );
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=IT Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint('Could not open email app');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.lightgreen,
        title: Text(
          'IT Support',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact IT Support:',
                style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey[700]),
                SizedBox(width: 10),
                Text(phoneNumber, style: TextStyle(fontSize: 18)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () => _copyNumber(context),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Icon(Icons.email, color: Colors.grey[700]),
                SizedBox(width: 10),
                Text(email, style: TextStyle(fontSize: 18)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendEmail,
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
