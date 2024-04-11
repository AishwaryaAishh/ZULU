import 'dart:async';
import 'package:flutter/material.dart';
import 'registration_login_page.dart';
import 'package:animate_do/animate_do.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication System',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late Timer _timer;

  final List<String> imagePaths = [
    'img1.png',
    'img2.png',
    'img3.png',
    'img4.png'
  ];
  final List<String> imageTexts = ["HOVERBEE", "RECON90", "  DRAP", "VOLUME35"];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % 4; // Assuming you have 4 images
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color.fromARGB(255, 110, 106, 106), // Darker medium grey
                Colors.grey[900]!, // Even darker grey
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 60,
                top: 200,
                child: Text(
                  "Welcome to Zulu Defence System's",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 250,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: "Drone Navigation ",
                      ),
                      TextSpan(
                        text: "System",
                        style: TextStyle(
                          color: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(
                    70, -15), // Adjust the offset as per your requirement
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'Zulu.png',
                      height: 200, // Adjust height as per your requirement
                      width: 200, // Adjust width as per your requirement
                    ),
                    Positioned(
                      top: -100, // Move the text 100 pixels upwards
                      child: Text(
                        imageTexts[0],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    200, 350), // Adjust the offset as per your requirement
                child: Image.asset(
                  'icon.png',
                  height: 250, // Adjust height as per your requirement
                  width: 250, // Adjust width as per your requirement
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Transform.translate(
                    offset: Offset(800, 380),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        FadeInUp(
                          duration: Duration(milliseconds: 1800),
                          child: Container(
                            padding: EdgeInsets.all(
                                8), // Add padding to create space around the image
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 70, 65,
                                  65), // Set the background color to white
                              shape: BoxShape.circle, // Make it circular
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.3), // Add a shadow
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'user.png',
                              height: 30,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        FadeInUp(
                          duration: Duration(milliseconds: 1800),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(50), // Make it round
                              color: Colors
                                  .white, // Set the background color to white
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.3), // Add a shadow
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width / 6,
                              height: 60,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegistrationLoginPage(
                                      isRegistration: false,
                                    ),
                                  ),
                                );
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        FadeInUp(
                          duration: Duration(milliseconds: 2000),
                          child: Container(
                            padding: EdgeInsets.only(top: 3, left: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border(
                                bottom: BorderSide(color: Colors.black),
                                top: BorderSide(color: Colors.black),
                                left: BorderSide(color: Colors.black),
                                right: BorderSide(color: Colors.black),
                              ),
                              color: Colors.yellow,
                            ),
                            child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width / 6,
                              height: 60,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegistrationLoginPage(
                                      isRegistration: true,
                                    ),
                                  ),
                                );
                              },
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.black,
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
                  SizedBox(height: 20),
                  Transform.translate(
                    offset: Offset(380, -60),
                    child: FadeIn(
                      duration: Duration(
                          milliseconds:
                              300), // Change the duration to 200 milliseconds
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            imagePaths[_currentIndex],
                            height: 350,
                            width: 350,
                          ),
                          Positioned(
                            left: 138,
                            top: 10, // Move the text 100 pixels upwards
                            child: Text(
                              imageTexts[_currentIndex],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold, // Make the text bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
