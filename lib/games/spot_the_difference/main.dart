import 'package:capstone_focus/games/GiantDwarf/dwarforginat.dart';
import 'package:capstone_focus/games/GiantDwarf/levelselect.dart';
import 'package:capstone_focus/games/Tetris/game/caller.dart';
import 'package:capstone_focus/games/Tetris/game/tetris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:capstone_focus/screens/createprofile/createprofile.dart';

class DwarfWelcomeScreen extends StatelessWidget {
  const DwarfWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DwarforGianLevelSelector()));
      },
      child: SafeArea(
        child: Scaffold(
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
                      Colors.lightBlueAccent,
                      Colors.green,
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
                      width: 300,  // Desired width
                      height: 200, // Desired height
                      child: Image.asset('assets/gamelogos/game5.png'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Spot The Difference',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      style: TextStyle(

                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                      duration: Duration(milliseconds: 500),
                      child: Text('Tap to Start'),
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
                        Colors.green,
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

