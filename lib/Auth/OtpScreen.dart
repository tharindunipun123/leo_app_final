import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ProfileCreationScreen.dart';



class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String otp;

  OtpScreen({required this.phoneNumber, required this.otp});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      _focusNodes[i].addListener(() {
        if (_controllers[i].text.length == 1) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
      });
    }
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  Future<void> updatePhoneNumber() async {
    final url = Uri.parse('http://145.223.21.62:8090/api/collections/users/records');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phonenumber': int.parse(widget.phoneNumber.replaceAll('+', '')),
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      String userId = responseData['id'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileCreationScreen(userId: userId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update phone number. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[700]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Hero(
                            tag: 'logo',
                            child: Image.asset(
                              'assets/otp.png',
                              width: constraints.maxWidth * 0.8,
                              height: constraints.maxHeight * 0.3,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Enter verification code',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We\'ve sent a code to ${widget.phoneNumber}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[600],
                          ),
                        ),
                        SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            6,
                                (index) => SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  if (value.length == 1 && index < 5) {
                                    FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Resend OTP logic
                              print('Resending OTP: ${widget.otp}');
                            },
                            child: Text(
                              'Didn\'t receive the code? Resend',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ),
                        ),
                        Spacer(),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              String enteredOtp = _controllers.map((controller) => controller.text).join();
                              if (enteredOtp == widget.otp) {
                                updatePhoneNumber();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invalid OTP. Please try again.')),
                                );
                              }
                            },
                            child: Text(
                              'Verify',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}