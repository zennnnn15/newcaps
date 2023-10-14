import 'package:capstone_focus/games/find10/find10Splash.dart';
import 'package:capstone_focus/games/spot_the_difference/spotthediffWelcome.dart';
import 'package:capstone_focus/screens/menu/editprofile.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../games/GiantDwarf/dwarforginat.dart';
import '../../games/GiantDwarf/dwarfwelcomescreen.dart';
import '../../games/Tetris/tetriswelcome.dart';


class MenuScreen extends StatefulWidget {
  final String userUID;

  const MenuScreen({Key? key, required this.userUID}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool showAttentionGames = false;
  bool showMindGames = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Text("Focus Finder", style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold
                ),)
              ],
            ),

          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal[800],
        elevation: 0,

      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(
            widget.userUID).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.hasData) {
            var userData = snapshot.data!.data();
            var avatar = userData?['avatarSelected'];
            var username = userData?['username'];


            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.teal[400],
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => EditProfileScreen()));
                        },
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: AssetImage(avatar),
                                ),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      username ?? 'Unknown',
                                      style: TextStyle(fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Games',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          FilterChip(
                            label: Text('Attention'),
                            selected: showAttentionGames,
                            onSelected: (selected) {
                              setState(() {
                                showAttentionGames = selected;
                              });
                            },
                            selectedColor: Colors.lightGreenAccent,
                          ),
                          SizedBox(width: 16),
                          FilterChip(
                            label: Text('Mind'),
                            selected: showMindGames,
                            onSelected: (selected) {
                              setState(() {
                                showMindGames = selected;
                              });
                            },
                            selectedColor: Colors.lightBlueAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    // Adjust the animation duration as needed
                    child: showGamesGrid(),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // Helper function to build the games grid based on the selected categories
  Widget showGamesGrid() {
    final filteredGames = gamesData.where((game) {
      if (!showAttentionGames && !showMindGames) {
        return true; // Show all games when neither category is selected
      }
      return (showAttentionGames && game.category == 'Attention') ||
          (showMindGames && game.category == 'Mind');
    }).toList();

    if (filteredGames.isEmpty) {
      return Center(
        child: Text(
          'No games to display',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        for (final game in filteredGames)
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => game.screen),
              );
            },
            child: buildGameTile(game.imagePath),
          ),
      ],
    );
  }

  // Helper function to build game tiles
  Widget buildGameTile(String imagePath) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.lightBlueAccent,
              Colors.lightGreenAccent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover, // Adjust the fit to cover the entire card
          ),
        ),
      ),
    );
  }
}


class GameInfo {

  final String category;
  final String imagePath;
  final Widget screen;

  GameInfo({

    required this.category,
    required this.imagePath,
    required this.screen,
  });
}

final gamesData = [
  GameInfo(

    category: 'Attention',
    imagePath: 'assets/gamelogos/game1.png',
    screen: DwarforGiant(),
  ),
  GameInfo(

    category: 'Attention',
    imagePath: 'assets/gamelogos/game2.png',
    screen: TetrisWelcomeScreen(),
  ),
  GameInfo(

    category: 'Mind',
    imagePath: 'assets/gamelogos/game3.png',
    screen: TetrisWelcomeScreen(),
  ),
  GameInfo(

    category: 'Mind',
    imagePath: 'assets/gamelogos/game4.png',
    screen: DwarfWelcomeScreen(),
  ),
  GameInfo(

    category: 'Mind',
    imagePath: 'assets/gamelogos/game5.png',
    screen: Find10Welcome (),
  ),
  GameInfo(

    category: 'Mind',
    imagePath: 'assets/gamelogos/game6.png',
    screen: SPDWelcomeScrren(),
  ),
];