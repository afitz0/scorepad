import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:flutter/material.dart';

import 'new_round.dart';
import 'new_player.dart';
import 'scorepad_fab.dart';

// TODO bidirectional scrolling?
// TODO what would this look like using slivers?
// TODO return focus to text field on playername validation
// TODO allow editing past scores
// TODO show total scores
// TODO save game state -- i.e., store history of games played
// TODO add "save game" or "close and record to history"
// TODO make order of player names matter (right now, storing in map means they're effectively unordered from user perspective)
// TODO text internationalization?
// TODO use mediaquery for text sizing?

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
        for (var i = 1; i <= _rounds; i++) Text("$i"),
      ];
    } else {
      var playerName = _scores.keys.toList()[index - 1];
      columnChildren.add(Text(playerName));

      var playerScores = _scores[playerName];

      for (var score in playerScores) {
        columnChildren.add(Text(score.toString()));
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: <Widget>[
          for (var c in columnChildren)
            Padding(
              padding: EdgeInsets.all(4.0),
              child: c,
            )
        ],
      ),
    );
  }

  /*
  An attempt at a builder for a BidirectionalScrollViewPlugin. It doesn't 
  appear to work with a dynamic list of elements though. :( 
  */
  Widget _buildScorePadFlat() {
    print("_buildScorePadFlat ");
    List<Column> columns = <Column>[];

    columns.add(Column(
      children: <Widget>[
        Text("Round"),
        for (var i = 1; i <= _rounds; i++) Text("$i"),
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
            return NewRoundDialog(
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
      _scores[newPlayerName] = [for (var i = 0; i < _rounds; i++) 0.0];
    });
  }
}
