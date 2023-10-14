import 'package:capstone_focus/newlogin/selectUser.dart';
import 'package:capstone_focus/screens/createprofile/createprofile.dart';
import 'package:capstone_focus/screens/loginscreen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

import 'menu/mainmenu.dart';


class SplaschScreen extends StatefulWidget {
  const SplaschScreen({Key? key}) : super(key: key);

  @override
  _SplaschScreenState createState() => _SplaschScreenState();
}

class _SplaschScreenState extends State<SplaschScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 18.0, end: 24.0).animate(_controller!);
    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller!.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller!.forward();
      }
    });
    _controller!.forward();

    // Check if the user is already logged in
    checkLoggedInUser();
  }

  Future<void> checkLoggedInUser() async {
    await Future.delayed(Duration.zero); // Delay the navigation to the next frame
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, navigate to the main menu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserSelectionScreen(),
        ),
      );
    } else {
      // User is not logged in, navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }




  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
       },
      child: SafeArea(

        child: Scaffold(
          // backgroundColor: Colors.teal[100],
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(120.0),
            child: ClipPath(
              clipper: WaveClipperTwo(reverse: false),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal,
                      Colors.blue,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 175, // Set your desired width here
                      height: 300, // Set your desired height here
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Image.asset('assets/mainbg.png')),
                    ),
                    SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      style: TextStyle(
                        fontSize: _animation!.value,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                      duration: Duration(milliseconds: 100),
                      child: Text('Focus Finder'),
                    ),
                  ],
                ),
              ),
              ClipPath(
                clipper: WaveClipperTwo(reverse: true),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.teal,
                        Colors.lightBlueAccent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
