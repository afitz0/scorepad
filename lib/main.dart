import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:flutter/material.dart';

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
  List<Player> _players;

  // Number of rounds this game has been played. Cooresponds to the number of rows in the "table"
  int _roundsPlayed;

  FocusNode _dialogFocus;

  @override
  void initState() {
    super.initState();
    _dialogFocus = FocusNode();

    _roundsPlayed = 0;
    _players = <Player>[];
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
            itemCount: _players.length + 1,
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
        for (int i = 1; i <= _roundsPlayed; i++)
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
      Player player = _players[index - 1];
      String playerName = player.name;
      columnChildren.add(Text(playerName));

      for (int round = 1; round <= _roundsPlayed; round++) {
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

  /*
  An attempt at a builder for a BidirectionalScrollViewPlugin. It doesn't 
  appear to work with a dynamic list of elements though. :( 
  */
  Widget _buildScorePadFlat() {
    List<Column> columns = <Column>[];

    columns.add(Column(
      children: <Widget>[
        Text("Round"),
        for (int i = 1; i <= _roundsPlayed; i++) Text("$i"),
      ],
    ));

    for (Player player in _players) {
      columns.add(Column(children: <Widget>[
        Text(player.name),
        for (int round = 1; round <= _roundsPlayed; round++)
          Score(
            score: player.getScore(round),
            player: player,
            round: round,
            editCallback: _editScore,
          ),
      ]));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(children: columns),
    );
  }

  void _restartGame() {
    this.setState(() {
      _players.forEach((p) {
        p.reset();
      });

      _roundsPlayed = 0;
    });
  }

  void _newRoundDialog() async {
    // New round
    _roundsPlayed++;

    for (Player player in _players) {
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
            round: _roundsPlayed,
          );
        });
  }

  void _addPlayerScore(Player player, double newScore, int round) {
    this.setState(() {
      _players[player.id].addScore(score: newScore, round: round);
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
      _players.add(Player(
          name: newPlayerName,
          firstRound: _roundsPlayed + 1,
          id: _players.length));
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
