import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import 'levelselect.dart';

void main() {
  runApp(DwarforGiant());
}

class DwarforGiant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.orange),
      ),
    );
  }
}

class AnimatedTimerBar extends StatefulWidget {
  final double value;

  AnimatedTimerBar({required this.value});

  @override
  _AnimatedTimerBarState createState() => _AnimatedTimerBarState();
}

class _AnimatedTimerBarState extends State<AnimatedTimerBar> {
  @override
  Widget build(BuildContext context) {
    final validValue = widget.value.clamp(0.0, 1.0); // Ensure value is between 0.0 and 1.0

    return Container(
      width: double.infinity,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: validValue,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final LevelData levelData; // Add this line

  GameScreen({required this.levelData}); // Add this constructor

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  double timerValue = 1.0; // Ranges from 0 to 1
  int tries = 10; // Maximum number of tries
  bool isGameOver = false;
  bool isPaused = false;
  String correctAnswer = 'dwarf';
  String currentAnswer = 'dwarf'; // Initial value
  FlutterTts flutterTts = FlutterTts();
  late Timer _timer;

  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingMusic = false;

  int calculateStarRating(int score) {
    if (score >= 10) {
      return 3;
    } else if (score >= 4 && score <= 9) {
      return 2;
    } else {
      return 1;
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: widget.levelData.speed), (
        timer) { // Use widget.levelData.speed
      if (timerValue <= 0) {
        _timer.cancel();
        endRound();
      } else {
        setState(() {
          timerValue -=
          0.01; // Adjust the decrement value for the desired speed
        });
      }
    });
  }

  void checkAnswer(String choice) {
    if (isGameOver || isPaused) return;

    setState(() {
      tries--; // Decrease the number of tries
    });

    String spokenWord = currentAnswer == 'dwarf' ? 'Dwarf' : 'Giant';
    if (spokenWord.toLowerCase() == choice.toLowerCase()) {
      setState(() {
        score++;
      });
    }

    endRound();
  }

  void endRound() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    if (timerValue <= 0) {
      setState(() {
        tries--;
      });
    }

    if (score >= 10 || tries <= 0) {
      setState(() {
        isGameOver = true;
      });

      //save to firebase the score
      //1. get the stage level and update
      //2. unlock the next satage
      //3. redirect to the level select
      //4.check if conditions unlocked

      showDialog(
        context: context,
        builder: (context) =>
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlue[100], // Child-friendly color
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Game Over',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0, // Larger font size for kids
                        fontFamily: 'Comic Sans MS', // Playful font
                        color: Colors.blue, // Fun color
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Final Score: $score',
                      style: TextStyle(
                        fontSize: 18.0, // Slightly larger font size
                        fontFamily: 'Comic Sans MS',
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        calculateStarRating(score),
                            (index) =>
                            Icon(Icons.star, color: Colors.yellow,
                                size: 32.0), // Smaller star icons
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        exitGame();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Exit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0, // Larger font size
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    } else {
      setState(() {
        currentAnswer = getRandomAnswer();
        timerValue = 1;


      });

      speak(currentAnswer == 'dwarf' ? 'Dwarf' : 'Giant');

      startTimer();
    }
  }

  Future<void> speak(String word) async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.5); // Adjust the speech rate as needed
    await flutterTts.speak(word);
  }

  String getRandomAnswer() {
    final random = Random();
    return random.nextBool() ? 'dwarf' : 'giant';
  }

  void pauseGame() {
    setState(() {
      isPaused = true;
      _audioPlayer.pause();
    });

    _timer.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevent closing the dialog with a tap outside
      builder: (context) =>
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100], // Child-friendly color
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'UP AND DOWN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0, // Larger font size for kids
                      fontFamily: 'Comic Sans MS', // Playful font
                      color: Colors.blue, // Fun color
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Giant means that the character must stand up. Dwarf means that the character must sit down',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0, // Smaller font size for readability
                      fontFamily: 'Comic Sans MS',
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            resumeGame();
                            _audioPlayer.play();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.lightGreen,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 48.0,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            exitGame();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.exit_to_app,
                              color: Colors.white,
                              size: 48.0,
                            ),
                          ),
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

  void resumeGame() {
    setState(() {
      isPaused = false;
    });
    startTimer();
  }

  void exitGame() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    // Load and play background music
    playBackgroundMusic();

    startTimer();
    currentAnswer = getRandomAnswer();
  }

  Future<void> playBackgroundMusic() async {
    try {
      await _audioPlayer.setAsset('assets/bg.mp3');
      await _audioPlayer.play();
      setState(() {
        _isPlayingMusic = true;
      });
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    flutterTts.stop();
    _audioPlayer.stop(); // Stop background music
    _audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dwarf or Giant ',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 24.0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: pauseGame,
            icon: Icon(
              Icons.pause,
              color: Colors.white,
              size: 32.0,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0, // Place the timer at the top
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.blue, // Timer background color
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Timer', // Add a label for the timer
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                      SizedBox(width: 10), // Add spacing
                      Text(
                        '${(timerValue * 100).toStringAsFixed(0)}%', // Display timer value as a percentage
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Score: $score',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                      SizedBox(width: 10), // Add spacing
                      Text(
                        'Tries left: $tries',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/dwarforgiant/main.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: $score',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontFamily: 'Comic Sans MS',
                      ),
                    ),
                    Text(
                      'Tries left: $tries',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontFamily: 'Comic Sans MS',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

              
              AnimatedTimerBar(value: timerValue),


          SizedBox(height: 20),
                Expanded(
                  flex: 4,
                  child: Image.asset(
                    'assets/dwarforgiant/$currentAnswer.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => checkAnswer('dwarf'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple,
                      ),
                      child: Text(
                        'Dwarf',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => checkAnswer('giant'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                      ),
                      child: Text(
                        'Giant',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                    ),
                  ],
                ),
                if (isGameOver)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Game Over! Final Score: $score',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontFamily: 'Comic Sans MS',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
