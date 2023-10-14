import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class LevelData {
  final String name;
  final bool isLocked;
  final int starsEarned;
  final int speed;

  LevelData({
    required this.name,
    required this.isLocked,
    required this.starsEarned,
    required this.speed,
  });
}

class DwarforGianLevelSelector extends StatelessWidget {
  DwarforGianLevelSelector({Key? key}) : super(key: key);

  final List<LevelData> levels = [
    LevelData(name: 'Level 1', isLocked: false, starsEarned: 0, speed: 1000),
    LevelData(name: 'Level 2', isLocked: false, starsEarned: 0, speed: 800),
    LevelData(name: 'Level 3', isLocked: false, starsEarned: 0, speed: 600),
    LevelData(name: 'Level 4', isLocked: false, starsEarned: 0, speed: 500),
    LevelData(name: 'Level 5', isLocked: false, starsEarned: 0, speed: 400),
    LevelData(name: 'Level 6', isLocked: false, starsEarned: 0, speed: 300),
    LevelData(name: 'Level 7', isLocked: false, starsEarned: 0, speed: 200),
    LevelData(name: 'Level 8', isLocked: false, starsEarned: 0, speed: 150),
    LevelData(name: 'Level 9', isLocked: false, starsEarned: 0, speed: 100),
    LevelData(name: 'Level 10', isLocked: false, starsEarned: 0, speed: 50),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  child: Image.asset('assets/mainbg.png'),
                ),
                Text(
                  "Focus Finder",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 32.0,
          ),
        ),
        actions: [

        ],
      ),
      body: Stack(
children: [
  Positioned.fill(
    child: Image.asset(
      'assets/dwarforgiant/testbg.jpg', // Path to your background image asset
      fit: BoxFit.cover,
    ),
  ),
  Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < levels.length; i++)
            GestureDetector(
              onTap: () {
                if (!levels[i].isLocked) {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: i < 10 ? Colors.green : Colors.blue,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              levels[i].name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Speed: ${levels[i].speed}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GameScreen(levelData: levels[i]),
                                  ),
                                );
                              },
                              child: Text('Play'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
              child: Column(
                children: [
                  if (i > 0)
                    Container(
                      width: 5,
                      height: 30,
                      color: i < 10 ? Colors.green : Colors.blue,
                    ),
                  Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.green],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!levels[i].isLocked)
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 36,
                            ),
                          SizedBox(height: 5),
                          Text(
                            levels[i].name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
  ),
],
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
    final validValue = widget.value.clamp(0.0, 1.0);

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
  final LevelData levelData;

  GameScreen({required this.levelData});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  double timerValue = 1.0;
  int tries = 10;
  bool isGameOver = false;
  bool isPaused = false;
  String correctAnswer = 'dwarf';
  String currentAnswer = 'dwarf';
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
    _timer = Timer.periodic(Duration(milliseconds: widget.levelData.speed), (timer) {
      if (timerValue <= 0) {
        _timer.cancel();
        endRound();
      } else {
        setState(() {
          timerValue -= 0.01;
        });
      }
    });
  }

  void checkAnswer(String choice) {
    if (isGameOver || isPaused) return;

    setState(() {
      tries--;
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

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
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
                    fontSize: 24.0,
                    fontFamily: 'Comic Sans MS',
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Final Score: $score',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Comic Sans MS',
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    calculateStarRating(score),
                        (index) => Icon(Icons.star, color: Colors.yellow, size: 32.0),
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
                        fontSize: 18.0,
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
    await flutterTts.setSpeechRate(0.5);
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Giant or Dwarf',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                  fontFamily: 'Comic Sans MS',
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Giant means that the character must stand up. Dwarf means that the character must sit down',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
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
                          size: 28.0,
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
                          size: 28.0,
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
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  child: Image.asset('assets/gamelogos/game4.png'),
                ),
                Text(
                  "Dwarf or Giant",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ],
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
          Positioned.fill(
            child: Image.asset(
              'assets/dwarforgiant/main.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Text(
                            '${score}',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Tries',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Text(
                            '${tries}',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20),

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
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          child: Text(
                            'Exit',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              score = 0;
                              tries = 10;
                              isGameOver = false;
                              currentAnswer = getRandomAnswer();
                              timerValue = 1.0;
                              startTimer();
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                          child: Text(
                            'Restart',
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
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

