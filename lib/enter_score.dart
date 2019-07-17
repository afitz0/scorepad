import 'package:flutter/material.dart';

import 'player.dart';

class EnterScoreDialog extends StatefulWidget {
  final Function(Player, double, int) addPlayerScoreCallback;
  final Player player;
  final int round;

  const EnterScoreDialog(
      {Key key, this.addPlayerScoreCallback, this.player, this.round})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => EnterScoreDialogState();
}

class EnterScoreDialogState extends State<EnterScoreDialog> {
  TextEditingController _newScoreTextController;

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
      title:
          Text("Enter ${widget.player.name}'s score for round ${widget.round}"),
      content: TextFormField(
        decoration: InputDecoration(
          hintText: "0.0",
          labelText: "${widget.player.name}'s score",
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
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        ),
        new FlatButton(
          child: new Text('Submit'),
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

    widget.addPlayerScoreCallback(widget.player, newScore, widget.round);
    _newScoreTextController.clear();
    Navigator.of(context, rootNavigator: true).pop(false);
  }
}
