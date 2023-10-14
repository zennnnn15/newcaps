import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'tetris.dart';


class TetApp extends StatefulWidget {
  const TetApp({Key? key});

  @override
  _TetAppState createState() => _TetAppState();
}

class _TetAppState extends State<TetApp> {
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    loadBackgroundMusic();

  }

  Future<void> loadBackgroundMusic() async {
    try {
      final assetAudio = AudioSource.asset('assets/tetris/tet.mp3'); // Replace with your music file path in assets
      await audioPlayer.setAudioSource(assetAudio);
      await audioPlayer.setSpeed(1.5);
      await audioPlayer.setLoopMode(LoopMode.one); // Loop the background music
      await audioPlayer.play();

      // Listen for audio completion to loop it
      audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          audioPlayer.seek(Duration.zero); // Rewind to the beginning
          audioPlayer.play(); // Start playing again
        }
      });
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark).copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        dividerColor: const Color(0xFF2F2F2F),
        dividerTheme: const DividerThemeData(thickness: 10),
        textTheme: const TextTheme(
          bodyText2: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/tetris/tetbg.png', // Replace with your image asset path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Tetris Game
          Tetris(),
        ],
      ),
    );
  }
}
