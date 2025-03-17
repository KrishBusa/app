import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class TicTacToeScreen extends StatefulWidget {
  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, '');
  bool isXTurn = true;
  String winner = '';
  int xScore = 0;
  int oScore = 0;
  List<int> winningCells = [];
  bool isSinglePlayer = false;
  bool isHardMode = false;

  void _handleTap(int index) {
    if (board[index] == '' && winner == '') {
      setState(() {
        board[index] = isXTurn ? 'X' : 'O';
        isXTurn = !isXTurn;
        _checkWinner();
      });
      if (isSinglePlayer && !isXTurn && winner == '') {
        Future.delayed(Duration(milliseconds: 500), _aiMove);
      }
    }
  }

  void _aiMove() {
    List<int> emptyCells = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') emptyCells.add(i);
    }
    if (emptyCells.isNotEmpty) {
      int aiIndex;
      if (isHardMode) {
        aiIndex = _bestMove();
      } else {
        aiIndex = emptyCells[Random().nextInt(emptyCells.length)];
      }
      setState(() {
        board[aiIndex] = 'O';
        isXTurn = true;
        _checkWinner();
      });
    }
  }

  int _bestMove() {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = 'O';
        if (_isWinningMove('O')) {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
    }
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = 'X';
        if (_isWinningMove('X')) {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
    }
    return board.indexOf('');
  }

  bool _isWinningMove(String player) {
    List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    for (var combo in winningCombinations) {
      if (board[combo[0]] == player &&
          board[combo[1]] == player &&
          board[combo[2]] == player) {
        return true;
      }
    }
    return false;
  }

  void _checkWinner() {
    List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (var combo in winningCombinations) {
      if (board[combo[0]] != '' &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        setState(() {
          winner = board[combo[0]];
          winningCells = combo;
          if (winner == 'X') xScore++;
          if (winner == 'O') oScore++;
        });
        _autoResetGame();
        return;
      }
    }

    if (!board.contains('')) {
      setState(() {
        winner = 'Draw';
        winningCells = [];
      });
      _autoResetGame();
    }
  }

  void _autoResetGame() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        board = List.filled(9, '');
        isXTurn = true;
        winner = '';
        winningCells = [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 29, 7, 57),
              Color.fromARGB(255, 99, 70, 142)
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ToggleButtons(
              isSelected: [isSinglePlayer, !isSinglePlayer],
              selectedColor: Colors.white,
              fillColor: Colors.purple,
              borderColor: Colors.white,
              onPressed: (index) {
                setState(() {
                  isSinglePlayer = index == 0;
                });
              },
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text('AI Mode')),
                Padding(padding: EdgeInsets.all(8.0), child: Text('1v1 Mode')),
              ],
            ),
            if (isSinglePlayer)
              ToggleButtons(
                isSelected: [isHardMode, !isHardMode],
                selectedColor: Colors.white,
                fillColor: Colors.purple,
                borderColor: Colors.white,
                onPressed: (index) {
                  setState(() {
                    isHardMode = index == 0;
                  });
                },
                children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Hard')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Easy')),
                ],
              ),
            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _handleTap(index),
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: winningCells.contains(index) ? Colors.green : Colors.blueGrey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
