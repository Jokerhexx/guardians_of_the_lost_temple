import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(GuardiansOfTheLostTemple());
}

class GuardiansOfTheLostTemple extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardians of the Lost Temple',
      theme: ThemeData.dark(),
      home: MainScreen(),
    );
  }
}

// Main Screen
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/temple_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Guardians of the Lost Temple',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameScreen()),
                  );
                },
                child: Text('Start', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Story Screen
class StoryScreen extends StatelessWidget {
  final String storyText;
  final VoidCallback onContinue;

  StoryScreen({required this.storyText, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/temple_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  storyText,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, offset: Offset(2, 2))]),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: onContinue,
                child: Text('Continue', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Game Screen
class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Map<String, dynamic>> levels = [];
  int currentLevel = 0;
  List<List<String?>> grid = [];
  int playerRow = 0;
  int playerCol = 0;
  bool gameOver = false;
  int movesOnSpike = 0;

  @override
  void initState() {
    super.initState();
    loadLevels();
  }

  Future<void> loadLevels() async {
    final String response = await rootBundle.loadString('assets/levels.json');
    setState(() {
      levels = List<Map<String, dynamic>>.from(jsonDecode(response));
      loadLevel(currentLevel);
      showStory();
    });
  }

  void loadLevel(int levelIndex) {
    grid = List<List<String?>>.from(
        levels[levelIndex]['grid'].map((row) => List<String?>.from(row)));
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] == 'P') {
          playerRow = i;
          playerCol = j;
        }
      }
    }
  }

  void showStory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryScreen(
          storyText: levels[currentLevel]['story'],
          onContinue: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void nextLevel() {
    if (currentLevel < levels.length - 1) {
      setState(() {
        currentLevel++;
        loadLevel(currentLevel);
      });
      showStory();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You reached the Stone of Fate! What will you do?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showEnding('You used the Stone of Fate... The future is yours.');
              },
              child: Text('Use the Stone'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showEnding('You destroyed the Stone... The world is safe.');
              },
              child: Text('Destroy the Stone'),
            ),
          ],
        ),
      );
    }
  }

  void showEnding(String endingText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('The End'),
        content: Text(endingText),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Back to Menu'),
          ),
        ],
      ),
    );
  }

  void movePlayer(String direction) {
    if (gameOver) return;

    setState(() {
      int newRow = playerRow;
      int newCol = playerCol;

      if (direction == 'up') newRow--;
      if (direction == 'down') newRow++;
      if (direction == 'left') newCol--;
      if (direction == 'right') newCol++;

      if (newRow >= 0 &&
          newRow < grid.length &&
          newCol >= 0 &&
          newCol < grid[0].length &&
          grid[newRow][newCol] != 'W') {
        if (grid[newRow][newCol] == '🔥') {
          gameOver = true;
          showGameOverDialog();
          return;
        }

        if (grid[newRow][newCol] == '🗡️') {
          movesOnSpike++;
          if (movesOnSpike > 1) {
            gameOver = true;
            showGameOverDialog();
            return;
          }
        } else {
          movesOnSpike = 0;
        }

        if (grid.any((row) => row.contains('👻'))) {
          int ghostRow = 0, ghostCol = 0;
          for (int i = 0; i < grid.length; i++) {
            for (int j = 0; j < grid[i].length; j++) {
              if (grid[i][j] == '👻') {
                ghostRow = i;
                ghostCol = j;
              }
            }
          }
          if (ghostRow == newRow || ghostCol == newCol) {
            int newGhostRow = ghostRow;
            int newGhostCol = ghostCol;
            if (ghostRow < newRow) newGhostRow++;
            if (ghostRow > newRow) newGhostRow--;
            if (ghostCol < newCol) newGhostCol++;
            if (ghostCol > newCol) newGhostCol--;
            if (grid[newGhostRow][newGhostCol] != 'W' &&
                grid[newGhostRow][newGhostCol] != 'B') {
              grid[ghostRow][ghostCol] = null;
              grid[newGhostRow][newGhostCol] = '👻';
              if (newGhostRow == newRow && newGhostCol == newCol) {
                gameOver = true;
                showGameOverDialog();
                return;
              }
            }
          }
        }

        if (grid[newRow][newCol] == 'B') {
          int blockNewRow = newRow + (newRow - playerRow);
          int blockNewCol = newCol + (newCol - playerCol);
          if (blockNewRow >= 0 &&
              blockNewRow < grid.length &&
              blockNewCol >= 0 &&
              blockNewCol < grid[0].length &&
              (grid[blockNewRow][blockNewCol] == null ||
                  grid[blockNewRow][blockNewCol] == 'E')) {
            if (grid[blockNewRow][blockNewCol] != '🔥') {
              grid[blockNewRow][blockNewCol] = 'B';
              grid[newRow][newCol] = 'P';
              grid[playerRow][playerCol] = null;
              playerRow = newRow;
              playerCol = newCol;
            }
          }
        } else {
          grid[newRow][newCol] = 'P';
          grid[playerRow][playerCol] = null;
          playerRow = newRow;
          playerCol = newCol;
        }

        if (grid.any((row) => row.contains('B') && row.contains('E'))) {
          nextLevel();
        }
      }
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('You fell into a trap!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                gameOver = false;
                movesOnSpike = 0;
                loadLevel(currentLevel);
              });
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${currentLevel + 1}: ${levels.isNotEmpty ? levels[currentLevel]['chapter'] : ''}'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/temple_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: grid.isNotEmpty ? grid[0].length : 5,
              ),
              itemCount: grid.isNotEmpty ? grid.length * grid[0].length : 25,
              itemBuilder: (context, index) {
                int row = index ~/ (grid.isNotEmpty ? grid[0].length : 5);
                int col = index % (grid.isNotEmpty ? grid[0].length : 5);
                String? cell = grid[row][col];
                return Container(
                  margin: EdgeInsets.all(2),
                  color: cell == 'W'
                      ? Colors.grey
                      : cell == 'P'
                          ? Colors.blue
                          : cell == 'B'
                              ? Colors.brown
                              : cell == 'E'
                                  ? Colors.green
                                  : cell == '🔥'
                                      ? Colors.red
                                      : cell == '🗡️'
                                          ? Colors.black
                                          : cell == '👻'
                                              ? Colors.purple
                                              : Colors.black12,
                  child: Center(
                    child: Text(
                      cell == 'P'
                          ? '🧙'
                          : cell == 'B'
                              ? '🪨'
                              : cell == 'E'
                                  ? '🚪'
                              : cell ?? '',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => movePlayer('up'), child: Text('Up')),
                ElevatedButton(
                    onPressed: () => movePlayer('down'), child: Text('Down')),
                ElevatedButton(
                    onPressed: () => movePlayer('left'), child: Text('Left')),
                ElevatedButton(
                    onPressed: () => movePlayer('right'), child: Text('Right')),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        gameOver = false;
                        movesOnSpike = 0;
                        loadLevel(currentLevel);
                      });
                    },
                    child: Text('Reload')),
                SizedBox(width: 10),
                ElevatedButton(onPressed: () {}, child: Text('Solution')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
