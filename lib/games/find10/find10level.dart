import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() {
  runApp(MaterialApp(
    home: Find10LevelSelector(),
  ));
}

class Ball {
  final int number;
  bool selected;

  Ball(this.number, this.selected);
}

class Find10LevelSelector extends StatefulWidget {
  const Find10LevelSelector({Key? key}) : super(key: key);

  @override
  _Find10LevelSelectorState createState() => _Find10LevelSelectorState();
}

class _Find10LevelSelectorState extends State<Find10LevelSelector> {
  List<Ball> balls = [];
  Timer? ballSpawnTimer;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<int> selectedBallIndices = [];
  double ballSize = 80.0;
  bool isPaused = false;

  Timer? screenTimer;
  int elapsedScreenTimeInSeconds = 0;

  @override
  void initState() {
    super.initState();
    initializeElapsedTimeFromFirestore();
    startGame();
  }

  @override
  void dispose() {
    ballSpawnTimer?.cancel();
    screenTimer?.cancel();
    super.dispose();
  }

  void initializeElapsedTimeFromFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Get the current user
    final User? user = auth.currentUser;

    if (user != null) {
      final uid = user.uid;

      final DocumentReference timeSpentRef = firestore.collection('users')
          .doc(uid) // Use the current user's UID
          .collection('parents')
          .doc('games')
          .collection('time_spent')
          .doc('find10');

      timeSpentRef.get().then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          final existingElapsedTime = data['elapsed_time'] as int;

          setState(() {
            elapsedScreenTimeInSeconds = existingElapsedTime;
          });
        }
      });
    }
  }

  void startGame() {


    generateRandomBalls();
    ballSpawnTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!isPaused) {
        if (balls.length < 66) {
          generateRandomBall();
        } else {
          timer.cancel();
          showGameOverDialog();
        }
        setState(() {});
      }
    });

    // Initialize the screen timer
    screenTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused) {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final FirebaseAuth auth = FirebaseAuth.instance;

        // Get the current user
        final User? user = auth.currentUser;

        setState(() {
          elapsedScreenTimeInSeconds++;
          final uid = user?.uid;

          // Send the elapsed screen time to Firestore
          firestore.collection('users')
              .doc(uid)
              .collection('parents')
              .doc('games')
              .collection('time_spent')
              .doc('find10')
              .set({'elapsed_time': elapsedScreenTimeInSeconds});
        });
      }
    });
  }

  void generateRandomBall() {
    final random = Random();
    final newBall = Ball(random.nextInt(9) + 1, false);
    balls.add(newBall); // Add a new ball to the list.
  }

  void generateRandomBalls() {
    balls.clear();
    for (int i = 0; i < 9; i++) {
      generateRandomBall();
    }
  }

  bool isPairSumTen(int firstIndex, int secondIndex) {
    return balls[firstIndex].number + balls[secondIndex].number == 10;
  }

  void removePair(int firstIndex, int secondIndex) {
    balls.removeAt(secondIndex);
    balls.removeAt(firstIndex);
  }

  void deselectBalls() {
    for (int index in selectedBallIndices) {
      balls[index].selected = false;
    }
    selectedBallIndices.clear();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Game Over",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "The grid is full. Do you want to retry?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
              child: Text(
                "Retry",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  void restartGame() {
    balls.clear();
    generateRandomBalls();
    startGame();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
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
        backgroundColor: Colors.teal,

      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/find10/testbg10.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.transparent, // Make the container transparent
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pause Button and Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isPaused = !isPaused;
                            });
                          },
                          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                        ),
                        Center(
                          child: Text(
                            "Choose Two Numbers that Make 10 in Total.              ",
                            style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(
                      height: 70,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          child: GridView.count(
                            crossAxisCount: 6,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 1.0, // Set the aspect ratio to 1.0 for a square shape
                            children: List.generate(balls.length, (index) {
                              final ball = balls[index];
                              return GestureDetector(
                                onTap: () {
                                  if (!isPaused && selectedBallIndices.length < 2) {
                                    setState(() {
                                      ball.selected = !ball.selected;

                                      if (ball.selected) {
                                        selectedBallIndices.add(index);
                                      } else {
                                        selectedBallIndices.remove(index);
                                      }

                                      if (selectedBallIndices.length == 2) {
                                        final firstIndex = selectedBallIndices[0];
                                        final secondIndex = selectedBallIndices[1];
                                        if (isPairSumTen(firstIndex, secondIndex)) {
                                          removePair(firstIndex, secondIndex);
                                          selectedBallIndices.clear();
                                        } else {
                                          deselectBalls();
                                        }
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  width: ballSize,
                                  height: ballSize,
                                  decoration: BoxDecoration(
                                    color: ball.selected ? Colors.yellow : Colors.transparent,
                                    shape: BoxShape.circle, // Make it circular
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/find10/${ball.number}.png',
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
