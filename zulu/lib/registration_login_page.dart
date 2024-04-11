import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;

import 'protected_page.dart';

class RegistrationLoginPage extends StatelessWidget {
  final bool isRegistration;

  RegistrationLoginPage({required this.isRegistration});

  @override
  Widget build(BuildContext context) {
    return isRegistration ? RegistrationPage() : LoginPage();
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    const String url = 'https://localhost:3000/register';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'user': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      String token = data['token'];
      _navigateToProtectedPage(context, token);
    } else {
      throw Exception('Failed to register user');
    }
  }

  void _navigateToProtectedPage(BuildContext context, String token) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProtectedPage(token: token)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FadeInUp(
                        duration: Duration(milliseconds: 1000),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Create a new account",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: <Widget>[
                            FadeInUp(
                              duration: Duration(milliseconds: 1200),
                              child: makeInput(
                                label: "Username",
                                controller: _usernameController,
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1300),
                              child: makeInput(
                                label: "Email",
                                controller: _emailController,
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1400),
                              child: makeInput(
                                label: "Password",
                                obscureText: true,
                                controller: _passwordController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInUp(
                        duration: Duration(milliseconds: 1500),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 50,
                          child: MaterialButton(
                            onPressed: () => _register(context),
                            color: Colors.yellow,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1200),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                      //image: DecorationImage(
                      //image: AssetImage('assets/image.png'),
                      //fit: BoxFit.cover,
//),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget makeInput({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.yellow), // Change to desired color
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    const String url = 'https://localhost:3000/login';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      String token = data['token'];

      _navigateToProtectedPage(context, token);
    } else {
      throw Exception('Failed to login user');
    }
  }

  void _navigateToProtectedPage(BuildContext context, String token) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProtectedPage(token: token)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FadeInUp(
                        duration: Duration(milliseconds: 1000),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Login to your account",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: <Widget>[
                            FadeInUp(
                              duration: Duration(milliseconds: 1300),
                              child: makeInput(
                                label: "Email",
                                controller: _emailController,
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1400),
                              child: makeInput(
                                label: "Password",
                                obscureText: true,
                                controller: _passwordController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInUp(
                        duration: Duration(milliseconds: 1500),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 50,
                          child: MaterialButton(
                            onPressed: () => _login(context),
                            color: Colors.yellow,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1200),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                      //image: DecorationImage(
                      //image: AssetImage('assets/image.png'),
                      //fit: BoxFit.cover,
                      ),
                ),
              ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget makeInput({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.yellow), // Change to desired color
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}