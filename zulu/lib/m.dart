import 'package:flutter/material.dart';
import 'registration_login_page.dart';
import 'package:animate_do/animate_do.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication System',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(198, 53, 52, 51), // Medium gray
              Color.fromARGB(255, 17, 16, 16), // Darker gray
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20, // Adjust top position as needed
              left: 20, // Adjust left position as needed
              child: Image.asset(
                'Zulu.png', // Replace 'Zulu.png' with the image path
                width: 100, // Adjust width as needed
                height: 100, // Adjust height as needed
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 170, // Adjust the height of your header
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'H.png'), // Replace 'head.png' with the image path
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Left Container for Icon Image
                          Transform.translate(
                            offset: Offset(-10, -50), // Move image left and up
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Image with Slow FadeIn animation
                                FadeIn(
                                  duration: Duration(
                                      milliseconds:
                                          2000), // Slow fade-in animation duration
                                  child: Image.asset(
                                    'icon.png',
                                    // Replace 'icon.png' with the image path
                                    width: 850, // Increased width by 100 pixels
                                    height:
                                        445, // Adjust the height of the image
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right Container for Login and Signup Buttons
                          Container(
                            margin: EdgeInsets.fromLTRB(
                                10, 170, 70, 10), // Adjust margins as needed
                            padding:
                                EdgeInsets.all(20), // Adjust padding as needed

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FadeInUp(
                                  duration: Duration(milliseconds: 1600),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      MaterialButton(
                                        minWidth:
                                            MediaQuery.of(context).size.width /
                                                3.9,
                                        height: 60,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RegistrationLoginPage(
                                                      isRegistration: false),
                                            ),
                                          );
                                        },
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: const Color.fromARGB(
                                                255, 240, 235, 235),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Text(
                                              "Login",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                color:
                                                    Colors.white, // Text color
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Container(
                                        padding:
                                            EdgeInsets.only(top: 3, left: 3),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border(
                                            bottom: BorderSide(
                                                color: const Color.fromARGB(
                                                    255, 240, 235, 235)),
                                            top: BorderSide(
                                                color: const Color.fromARGB(
                                                    255, 240, 235, 235)),
                                            left: BorderSide(
                                                color: const Color.fromARGB(
                                                    255, 240, 235, 235)),
                                            right: BorderSide(
                                                color: const Color.fromARGB(
                                                    255, 240, 235, 235)),
                                          ),
                                          color: Colors.yellow,
                                        ),
                                        child: MaterialButton(
                                          minWidth: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.9,
                                          height: 60,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RegistrationLoginPage(
                                                        isRegistration: true),
                                              ),
                                            );
                                          },
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Text(
                                            "Sign up",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              color: Colors.white, // Text color
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}







