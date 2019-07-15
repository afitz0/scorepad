import 'package:flutter/material.dart';

class NewRoundDialog extends StatefulWidget {
  final addPlayerScoreCallback;
  final playerName;
  final round;

  const NewRoundDialog(
      {Key key, this.addPlayerScoreCallback, this.playerName, this.round})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      NewRoundDialogState(addPlayerScoreCallback, playerName, round);
}

class NewRoundDialogState extends State<NewRoundDialog> {
  final addPlayerScoreCallback;
  final playerName;
  final round;

  TextEditingController _newScoreTextController;

  NewRoundDialogState(this.addPlayerScoreCallback, this.playerName, this.round);

  @override
  void initState() {
    super.initState();
    _newScoreTextController = TextEditingController();
  }

  @override
  void dispose() {
    _newScoreTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Enter $playerName's score for round $round"),
      content: TextFormField(
        decoration: InputDecoration(
          hintText: "0.0",
          labelText: "$playerName's score",
        ),
        autofocus: true,
        autovalidate: true,
        autocorrect: false,
        validator: _validateNewScore,
        onFieldSubmitted: (_) => _submit(),
        controller: _newScoreTextController,
        textInputAction: TextInputAction.done,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: true),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        new FlatButton(
          child: new Text('Add'),
          onPressed: () => _submit(),
        )
      ],
    );
  }

  String _validateNewScore(String input) {
    // Allow blank input as a score of zero
    if (input == null || input.isEmpty) input = "0";
    if (double.tryParse(input) == null) return "Score must be a number";
    return null;
  }

  void _submit() {
    String newScoreStr = _newScoreTextController.text;

    if (newScoreStr == null || newScoreStr.isEmpty) {
      newScoreStr = "0";
    }

    double newScore = double.parse(newScoreStr);

    addPlayerScoreCallback(playerName, newScore, round);
    _newScoreTextController.clear();
    Navigator.of(context).pop();
  }
}
