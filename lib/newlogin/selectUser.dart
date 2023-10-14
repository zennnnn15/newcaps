import 'package:capstone_focus/parentsManagement/parentMainScreen.dart';
import 'package:capstone_focus/screens/menu/mainmenu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstone_focus/screens/hello.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Account App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: UserSelectionScreen(),
    );
  }
}

class UserSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Who's Playing?"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Who's Playing?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              padding: EdgeInsets.all(20),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                UserSelectionTile(
                  userType: 'Parent',
                  onPressed: () {
                    _showPINModal(context, user?.uid);
                  },
                ),
                UserSelectionTile(
                  userType: 'Child',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MenuScreen(userUID: user!.uid)));
                  },
                ),
                // Add more UserSelectionTile widgets for additional user types
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPINModal(BuildContext context, String? userUid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String errorMessage = ''; // Initialize an error message
        String enteredPin = '';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Enter Parent PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PinEntryWidget(
                    userUid: userUid,
                    onPinChanged: (pin) {
                      setState(() {
                        enteredPin = pin;
                      });
                    },
                  ),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    String? pinEntered = await validatePIN(userUid);
                    print('PIN from Firebase: $pinEntered');
                    print('Entered PIN: $enteredPin');
                    if (pinEntered != null && pinEntered == enteredPin) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ParentMainScreen(),
                        ),
                      );
                    } else {
                      setState(() {
                        errorMessage = 'Incorrect PIN. Please try again.';
                      });
                    }
                  },
                  child: Text('Submit'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> validatePIN(String? userUid) async {
    if (userUid == null) {
      return null;
    }

    try {
      String parentDocPath = '/users/$userUid/parents/password';
      DocumentSnapshot parentDoc =
          await FirebaseFirestore.instance.doc(parentDocPath).get();

      if (parentDoc.exists) {
        String pin = parentDoc['pin'].toString();
        print('PIN from Firebase: $pin'); // Print the PIN
        return pin;
      } else {
        return null;
      }
    } catch (e) {
      print('Error validating PIN: $e');
      return null;
    }
  }
}

class UserSelectionTile extends StatelessWidget {
  final String userType;
  final VoidCallback onPressed;

  UserSelectionTile({
    required this.userType,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
        onPrimary: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          userType,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class PinEntryWidget extends StatefulWidget {
  final String? userUid;
  final ValueChanged<String> onPinChanged;

  PinEntryWidget({required this.userUid, required this.onPinChanged});

  @override
  _PinEntryWidgetState createState() => _PinEntryWidgetState();
}

class _PinEntryWidgetState extends State<PinEntryWidget> {
  List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  String enteredPin = '';

  @override
  void dispose() {
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 4; i++)
          Expanded(
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      if (i < 3) {
                        _focusNodes[i + 1].requestFocus();
                      }
                      enteredPin += value;
                      if (enteredPin.length > 4) {
                        // Limit the PIN to 4 digits
                        enteredPin = enteredPin.substring(0, 4);
                      }
                    } else {
                      if (enteredPin.isNotEmpty) {
                        // Handle backspacing
                        enteredPin =
                            enteredPin.substring(0, enteredPin.length - 1);
                      }
                      if (i > 0) {
                        _focusNodes[i - 1].requestFocus();
                      }
                    }
                    widget.onPinChanged(enteredPin);
                  },
                  focusNode: _focusNodes[i],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
