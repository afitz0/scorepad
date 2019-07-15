import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:flutter/material.dart';

import 'enter_score.dart';
import 'new_player.dart';
import 'scorepad_fab.dart';

// TODO bidirectional scrolling?
// TODO what would this look like using slivers?
// TODO return focus to text field on playername validation
// TODO maintain textfield focus while adding scores
// TODO save game state -- i.e., store history of games played
// TODO add "save game" or "close and record to history"
// TODO make order of player names matter (right now, storing in map means they're effectively unordered from user perspective)
// TODO text internationalization?
// TODO use mediaquery for text sizing?
// TODO fix issue when list reaches bottom of screen (currently ~ 30 rounds, depending on screen size.)

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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "ScorePad",
      )),
      body: Center(
        child: RaisedButton(
          child: Text('New Game'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlayerScores()),
            );
          },
        ),
      ),
    );
  }
}

class PlayerScores extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PlayerScoresState();
}

// TODO does this "state" class do too much?
class PlayerScoresState extends State<PlayerScores> {
  // The map containing each player's score list.
  Map<String, List<double>> _scores;

  // Number of rounds this game has been played. Cooresponds to the number of rows in the "table"
  int _rounds;

  FocusNode _dialogFocus;

  @override
  void initState() {
    super.initState();
    _dialogFocus = FocusNode();

    _rounds = 0;
    _scores = {
      // TODO what if multiple players have same name??
      // Player Name  :  [scores]
    };
  }

  @override
  void dispose() {
    _dialogFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("New Game")),
        body: ListView.builder(
            padding: EdgeInsets.all(8.0),
            scrollDirection: Axis.horizontal,
            itemCount: _scores.length + 1,
            itemBuilder: _buildScorePad),
        // FIXME Why doesn't this work?
        // body: BidirectionalScrollViewPlugin(
        //   child: _buildScorePadFlat(),
        //   velocityFactor: 2.0,
        // ),
        floatingActionButton: ScorePadFab(
          newRoundCallback: _newRoundDialog,
          newPlayerCallback: _newPlayerDialog,
          restartGameCallback: _restartGame,
        ));
  }

  Widget _buildScorePad(BuildContext context, int index) {
    List<Widget> columnChildren = <Widget>[];

    if (index == 0) {
      columnChildren = <Widget>[
        Text("Round"),
        for (int i = 1; i <= _rounds; i++)
          Score(
            score: i.toDouble(),
            editable: false,
          ),
        Container(
          padding: EdgeInsets.all(8.0),
          child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ];
    } else {
      String playerName = _scores.keys.toList()[index - 1];
      columnChildren.add(Text(playerName));

      List<double> playerScores = _scores[playerName];
      double totalScore = 0.0;

      for (int round = 0; round < playerScores.length; round++) {
        double score = playerScores[round];
        totalScore += score;

        columnChildren.add(Score(
          score: score,
          playerName: playerName,
          round: round + 1,
          editCallback: _editScore,
        ));
      }

      columnChildren.add(Score(
        score: totalScore,
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

  /*
  An attempt at a builder for a BidirectionalScrollViewPlugin. It doesn't 
  appear to work with a dynamic list of elements though. :( 
  */
  Widget _buildScorePadFlat() {
    List<Column> columns = <Column>[];

    columns.add(Column(
      children: <Widget>[
        Text("Round"),
        for (int i = 1; i <= _rounds; i++) Text("$i"),
      ],
    ));

    for (String playerName in _scores.keys) {
      columns.add(Column(children: <Widget>[
        Text(playerName),
        for (double score in _scores[playerName]) Text(score.toString()),
      ]));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(children: columns),
    );
  }

  void _restartGame() {
    this.setState(() {
      _scores.forEach((playerName, playerScores) {
        _scores[playerName] = [];
      });

      _rounds = 0;
    });
  }

  void _newRoundDialog() {
    // New round
    _rounds++;

    for (String playerName in _scores.keys) {
      showDialog(
          context: this.context,
          builder: (context) {
            return EnterScoreDialog(
              addPlayerScoreCallback: _addPlayerScore,
              playerName: playerName,
              round: _rounds,
            );
          });
    }
  }

  void _addPlayerScore(String playerName, double newScore, int round) {
    this.setState(() {
      if (_scores[playerName].length < round) {
        _scores[playerName].add(newScore);
      } else {
        _scores[playerName][round - 1] = newScore;
      }
    });
  }

  void _newPlayerDialog() {
    showDialog(
        context: this.context,
        builder: (context) {
          return NewPlayerDialog(
            addPlayerCallback: _addPlayer,
            existingPlayerNames: _scores.keys.toList(),
          );
        });
  }

  void _addPlayer(String newPlayerName) {
    this.setState(() {
      _scores[newPlayerName] = [for (int i = 0; i < _rounds; i++) 0.0];
    });
  }

  void _editScore(String playerName, int round) {
    showDialog(
        context: this.context,
        builder: (context) {
          return EnterScoreDialog(
            addPlayerScoreCallback: _addPlayerScore,
            playerName: playerName,
            round: round,
          );
        });
  }
}

// TODO (to learn?) does this need to be a stateful widget?
class Score extends StatelessWidget {
  final double score;
  final bool editable;
  final String playerName;
  final int round;
  final Function(String, int) editCallback;
  final TextStyle textStyle;

  final double _padding = 8.0;

  const Score(
      {Key key,
      @required this.score,
      this.editable = true,
      this.editCallback,
      this.playerName,
      this.round, 
      this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String scoreFormatted =
        score.toStringAsFixed(score.truncateToDouble() == score ? 0 : 2);
    Container scoreText = Container(
      padding: EdgeInsets.all(_padding),
      child: Text(scoreFormatted, style: textStyle),
    );

    if (editable) {
      return InkWell(
          onTap: () {
            editCallback(playerName, round);
          },
          child: scoreText);
    } else {
      return scoreText;
    }
  }
}
