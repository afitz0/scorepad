import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// TODO implemet new round.
// TODO text internationalization?
// TODO use mediaquery for text sizing?
// TODO bidirectional scrolling?
// TODO extra padding around table's cells?
// TODO what would this look like using slivers?

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
  var _scores;

  // Number of rounds this game has been played. Cooresponds to the number of rows in the "table"
  int _rounds;

  // Controller for the "add new player" dialog.
  TextEditingController _addPlayerTextController;

  FocusNode _dialogFocus;

  @override
  void initState() {
    super.initState();
    _addPlayerTextController = TextEditingController();
    _dialogFocus = FocusNode();

    _rounds = 0;
    _scores = {
      // TODO what if multiple players have same name??
      // Player Name  :  [scores]
    };
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
        floatingActionButton: _buildFab());
  }

  Widget _buildFab() {
    return ScorePadFab(
      newRoundCallback: _newRoundDialog,
      newPlayerCallback: _newPlayerDialog,
      restartGameCallback: _restartGame,
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
    // showDialog(
    //     context: this.context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Text("Enter new player's name"),
    //         content: TextFormField(
    //           decoration: InputDecoration(
    //             hintText: "New Player Name",
    //             labelText: "New Player Name",
    //           ),
    //           autofocus: true,
    //           autovalidate: true,
    //           validator: _validatePlayerName,
    //           onFieldSubmitted: _handleNewPlayerInput,
    //           controller: _addPlayerTextController,
    //           keyboardType:
    //               TextInputType.numberWithOptions(signed: true, decimal: true),
    //         ),
    //         actions: <Widget>[],
    //       );
    //     });

    this.setState(() {
      _rounds++;
      _scores.forEach((playerName, playerScores) {
        playerScores.add(0);
      });
    });
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
      child: Column(children: columnChildren),
    );
  }

  void _newPlayerDialog() {
    showDialog(
        context: this.context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter new player's name"),
            content: TextFormField(
              decoration: InputDecoration(
                hintText: "New Player Name",
                labelText: "New Player Name",
              ),
              autofocus: true,
              autovalidate: true,
              validator: _validatePlayerName,
              onFieldSubmitted: _handleNewPlayerInput,
              controller: _addPlayerTextController,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              new FlatButton(
                child: new Text('Add'),
                onPressed: () =>
                    _handleNewPlayerInput(_addPlayerTextController.text),
              )
            ],
          );
        });
  }

  String _validatePlayerName(String proposedName) {
    if (_scores.containsKey(proposedName)) return "Player already exists";
    // TODO this pops error text on first open. How can we not?
    if (proposedName.isEmpty) return "Name must not be blank";
    return null;
  }

  void _handleNewPlayerInput(String newPlayerName) {
    if (_validatePlayerName(newPlayerName) != null) {
      return;
    }

    this.setState(() {
      _scores[newPlayerName] = [for (var i = 0; i < _rounds; i++) 0];
    });

    Navigator.of(this.context).pop();
    _addPlayerTextController.clear();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _addPlayerTextController.dispose();
    _dialogFocus.dispose();

    super.dispose();
  }
}

class ScorePadFab extends StatefulWidget {
  final newRoundCallback;
  final newPlayerCallback;
  final restartGameCallback;

  const ScorePadFab(
      {Key key,
      this.newRoundCallback,
      this.newPlayerCallback,
      this.restartGameCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ScorePadFabState(
      newRoundCallback, newPlayerCallback, restartGameCallback);
}

class ScorePadFabState extends State<ScorePadFab> {
  final newRoundCallback;
  final newPlayerCallback;
  final restartGameCallback;

  ScorePadFabState(
      this.newRoundCallback, this.newPlayerCallback, this.restartGameCallback);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      closeManually: true,
      // TODO create custom animated icon
      animatedIcon: AnimatedIcons.menu_arrow,
      children: [
        SpeedDialChild(
          child: Icon(Icons.person),
          label: 'Player',
          onTap: newPlayerCallback,
        ),
        SpeedDialChild(
          child: Icon(Icons.plus_one),
          label: 'Round',
          onTap: newRoundCallback,
        ),
        SpeedDialChild(
          child: Icon(Icons.refresh),
          label: 'Restart Game',
          onTap: restartGameCallback,
        ),
      ],
    );
  }
}
