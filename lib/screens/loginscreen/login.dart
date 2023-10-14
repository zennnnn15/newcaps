import 'package:capstone_focus/newlogin/selectUser.dart';
import 'package:capstone_focus/screens/createprofile/createprofile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capstone_focus/screens/menu/mainmenu.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _isLoggingIn = false;
  String _errorMessage = ''; // Store error message
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginButtonPressed() async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Fetch the currently logged in user
      User? user = _auth.currentUser;
      if (user != null) {
        // Navigate to the MenuScreen and pass the user UID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserSelectionScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error logging in: $e');
      // Handle login error, show a dialog, etc.

      setState(() {
        _isLoggingIn = false;
        if (e is FirebaseAuthException) {
          // Handle specific Firebase Authentication exceptions
          if (e.code == 'user-not-found') {
            _errorMessage = 'No user found with this email.';
          } else if (e.code == 'wrong-password') {
            _errorMessage = 'Oops! That password is incorrect. Please try again.';
          } else {
            _errorMessage = 'Oops! Something went wrong. Please try again later.';
          }
        } else {
          // Handle generic error
          _errorMessage = 'Oops! Something went wrong. Please try again later.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  child: Image.asset('assets/mainbg.png'),
                ),
                Text("Focus Finder",style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold
                ),)
              ],
            ),

          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text("Login with your current account in focus finder buddy.",style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22
                    ),),
                    SizedBox(height: 30,),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    if (_errorMessage.isNotEmpty)
                      ErrorBubble(errorMessage: _errorMessage),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _isLoggingIn ? null : _onLoginButtonPressed,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orange,
                        padding:
                        EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      ),
                      child: _isLoggingIn
                          ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 200,),
                    Text("Be a focus finder buddy!",style: TextStyle(
                      fontWeight: FontWeight.w300
                    ),),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orangeAccent[100],
                        padding:
                        EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateProfileScreen(),
                          ),
                        );
                      },
                      child: Text("Create"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorBubble extends StatelessWidget {
  final String errorMessage;

  ErrorBubble({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
