import 'dart:async';
import 'package:capstone_focus/games/spot_the_difference/levelSeleectstd.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'level_2_screen.dart';

class GameScreen1 extends StatefulWidget {
  @override
  _GameScreen1State createState() => _GameScreen1State();
}

class _GameScreen1State extends State<GameScreen1> {
  int score = 0;
  int timeLeft = 60; // Initial time left in seconds

  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    // Start the game timer
    startTimer();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer timer) {
        if (timeLeft == 0) {
          // Game over, stop the timer
          timer.cancel();
          setState(() {
            isGameOver = true;
          });
        } else {
          setState(() {
            timeLeft--;
          });
        }
      },
    );
  }

  bool isCorrectImage() {
    // Replace with your logic to determine if the correct image is tapped
    // For simplicity, we'll assume the first image is the correct one
    return true;
  }



  void wrongImageTap(String tappedImage) {
    // Check which image was tapped
    if (tappedImage == "assets/spotthedif/lvl1/wrong.png") {
      // Deduct a life only if "soccer2.png" is tapped
      // setState(() {
      //   lives--;
      // });
      WrongImage();
    } else {
      WrongImage();
    }
  }

  void correctImageTap(String tappedImage) {
    // Check which image was tapped
    if (tappedImage == "assets/spotthedif/lvl1/correct.png") {
      // Deduct a life only if "soccer2.png" is tapped
      setState(() {
        score++;
      });
      CorrectImage();
    } else {
      WrongImage();
    }
  }

  void CorrectImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Increment the user's progress in Firebase Firestore
        final FirebaseAuth _auth = FirebaseAuth.instance;
        final CollectionReference userLevels = FirebaseFirestore.instance.collection('user_levels');
        final User? user = _auth.currentUser;
        if (user != null) {
          userLevels.doc(user.uid).set({
            'level_1': false, // Mark Level 1 as completed
          }, SetOptions(merge: true)); // Merge with existing data if any
        }

        return AlertDialog(
          title: Text('Correct Image'),
          content: Text('Congratulations! You tapped the correct image.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen2(initialScore: 2,
                    ),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void WrongImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wrong Image'),
          content: Text('You picked the wrong image, Try Again.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Your Score: $score'),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  resetGame();
                },
                child: Text('Play Again'),
              ),
            ],
          ),
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
      timeLeft = 60;
      // lives = 3;
      isGameOver = false;
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Spot the Difference"),
      // ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Score Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/spotthedif/score.png",
                          width: 60,
                          height: 40,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          " $score",
                          style: TextStyle(fontSize: 24.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "LEVEL 1",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
            ),

            // Timer Display
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Time Left: $timeLeft seconds",
                style: TextStyle(fontSize: 20.0),
              ),
            ),

            // Images
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (isCorrectImage()) {
                        WrongImage();
                      } else {
                        wrongImageTap("assets/spotthedif/lvl1/wrong.png");
                      }
                    },
                    child: Image.asset(
                      "assets/spotthedif/lvl1/wrong.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isCorrectImage()) {
                        WrongImage();
                      } else {
                        wrongImageTap("assets/spotthedif/lvl1/wrong.png");
                      }
                    },
                    child: Image.asset(
                      "assets/spotthedif/lvl1/wrong.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isCorrectImage()) {
                        setState(() {
                          score++;
                        });
                        CorrectImage();
                      } else {
                        correctImageTap("assets/spotthedif/lvl1/correct.png");
                      }
                    },
                    child: Image.asset(
                      "assets/spotthedif/lvl1/correct.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (isCorrectImage()) {
                        // setState(() {
                        //   lives--;
                        // });
                        WrongImage();
                      } else {
                        wrongImageTap("assets/spotthedif/lvl1/wrong.png");
                      }
                    },
                    child: Image.asset(
                      "assets/spotthedif/lvl1/wrong.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isCorrectImage()) {
                        WrongImage();
                      } else {
                        wrongImageTap("assets/spotthedif/lvl1/wrong.png");
                      }
                    },
                    child: Image.asset(
                      "assets/spotthedif/lvl1/wrong.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isCorrectImage()) {
                        WrongImage();
                      } else {
                        wrongImageTap("assets/spotthedif/lvl1/wrong.png");
                      }
                    },
                    child: Image.asset(
                      "assets/spotthedif/lvl1/wrong.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (isCorrectImage()) {
                        // setState(() {
                        //   lives--;
                        // });
                        WrongImage();
                      } else {
                        wrongImageTap("assets/spotthedif/lvl1/wrong.png");
                      }
                    },
                    child: Image.asset(
                      "assets/spotthedif/lvl1/wrong.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isCorrectImage()) {
                        WrongImage();
                      } else {
                        wrongImageTap("assets/spotthedif/lvl1/wrong.png");
                      }
                    },
                    child: Image.asset(
                      "assets/spotthedif/lvl1/wrong.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isCorrectImage()) {
                        WrongImage();
                      } else {
                        wrongImageTap("assets/spotthedif/lvl1/wrong.png");
                      }
                    },
                    child: Image.asset(
                      "assets/spotthedif/lvl1/wrong.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                ],
              ),
            ),

            // Game Over Message
            if (isGameOver)
              ElevatedButton(
                onPressed: () {
                  showGameOverDialog();
                },
                child: Text("View Score"),
              ),
          ],
        ),
      ),
    );
  }
}
