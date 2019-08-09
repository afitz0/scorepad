import 'package:flutter/material.dart';

import 'game.dart';
import 'player.dart';
import 'enter_score.dart';
import 'new_player.dart';
import 'scorepad_fab.dart';

// TODO bidirectional scrolling?
// TODO what would this look like using slivers?
// TODO save game state -- i.e., store history of games played
// TODO text internationalization?
// TODO use mediaquery for text sizing?
// TODO fix issue when list reaches bottom of screen (currently ~ 23 rounds, depending on screen size.)
// TODO bug: when use hits back (or accidentally swipes from side of screen on ios), game is entirely lost.

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _resumableGame = false;
  Game _previousGame;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "ScorePad",
      )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('New Game'),
              onPressed: () => _getGameResults(context, null),
            ),
            RaisedButton(
              child: Text('Resume Game'),
              onPressed: _resumableGame ? () => _getGameResults(context, _previousGame) : null,
            ),
          ],
        ),
      ),
    );
  }

  void _getGameResults(BuildContext context, Game previousGame) async {
    final Game game = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlayerScores(previousGame)),
    );

    if (game != null && game.isInProgress()) {
      _resumableGame = true;
      _previousGame = game;
    } else {
      _resumableGame = false;
      _previousGame = null;
    }
  }
}

class PlayerScores extends StatefulWidget {
  final Game previousGame;

  PlayerScores(this.previousGame);
  
  @override
  State<StatefulWidget> createState() => PlayerScoresState();
}

// TODO does this "state" class do too much?
class PlayerScoresState extends State<PlayerScores> {
  Game game;
  
  @override
  void initState() {
    super.initState();
    game = widget.previousGame ?? Game();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress)
          return false;
        else
          return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("New Game"),
          // Override the back button so that we can return the scoresheet
        // (allowing resume game)
        leading:  IconButton(
          icon: BackButtonIcon(),
          onPressed: () => Navigator.pop(context, game),
        ),
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(8.0),
          scrollDirection: Axis.horizontal,
          itemCount: game.getPlayerNames().length + 1,
          itemBuilder: _buildScorePad),
      floatingActionButton: ScorePadFab(
        newRoundCallback: _newRoundDialog,
        newPlayerCallback: _newPlayerDialog,
        restartGameCallback: _restartGame,
      ),
    );
  }

  Widget _buildScorePad(BuildContext context, int index) {
    List<Widget> columnChildren = <Widget>[];

    if (index == 0) {
      columnChildren = <Widget>[
        Text("Round"),
        for (int i = 1; i <= game.roundsPlayed; i++)
          Score(
            score: i.toDouble(),
            editable: false,
          ),
        Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Total",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ];
    } else {
      Player player = game.getPlayerByIndex(index - 1);
      String playerName = player.name;
      columnChildren.add(Text(playerName));

      for (int round = 1; round <= game.roundsPlayed; round++) {
        columnChildren.add(Score(
          score: player.getScore(round),
          player: player,
          round: round,
          editCallback: _editScore,
        ));
      }

      columnChildren.add(Score(
        score: player.getTotalScore(),
        editable: false,
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: columnChildren,
      ),
    );
  }

  void _restartGame() {
    this.setState(() =>  game.restart());
  }

  void _newRoundDialog() async {
    // New round
    game.newRound();

    for (Player player in game.players) {
      bool dialogCanceled = await _showEditScoreDialog(player);

      if (dialogCanceled == null || dialogCanceled) break;
    }
  }

  Future<bool> _showEditScoreDialog(Player player) async {
    return showDialog<bool>(
        context: this.context,
        builder: (context) {
          return EnterScoreDialog(
            addPlayerScoreCallback: _addPlayerScore,
            player: player,
            round: game.roundsPlayed,
          );
        });
  }

  void _addPlayerScore(Player player, double newScore, int round) {
    this.setState(() {
      player.addScore(score: newScore, round: round);
    });
  }

  void _newPlayerDialog() {
    showDialog(
        context: this.context,
        builder: (context) {
          return NewPlayerDialog(
            addPlayerCallback: _addPlayer,
          );
        });
  }

  void _addPlayer(String newPlayerName) {
    this.setState(() {
      game.players.add(Player(
          name: newPlayerName,
          firstRound: game.roundsPlayed + 1,
          id: game.players.length));
    });
  }

  void _editScore(Player player, int round) {
    showDialog(
        context: this.context,
        builder: (context) {
          return EnterScoreDialog(
            addPlayerScoreCallback: _addPlayerScore,
            player: player,
            round: round,
          );
        });
  }
}

// TODO (to learn?) does this need to be a stateful widget?
class Score extends StatelessWidget {
  final double score;
  final bool editable;
  final Player player;
  final int round;
  final Function(Player, int) editCallback;
  final TextStyle textStyle;

  final double _padding = 8.0;

  const Score(
      {Key key,
      @required this.score,
      this.editable = true,
      this.editCallback,
      this.player,
      this.round,
      this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String scoreFormatted;
    if (score == null) {
      scoreFormatted = "-";
    } else {
      scoreFormatted =
          score.toStringAsFixed(score.truncateToDouble() == score ? 0 : 2);
    }

    Container scoreText = Container(
      padding: EdgeInsets.all(_padding),
      child: Text(scoreFormatted, style: textStyle),
    );

    if (editable) {
      return InkWell(
          onTap: () {
            editCallback(player, round);
          },
          child: scoreText);
    } else {
      return scoreText;
    }
  }
}
