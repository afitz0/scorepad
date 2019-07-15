import 'package:flutter/material.dart';

class NewPlayerDialog extends StatefulWidget {
  final addPlayerCallback;
  final existingPlayerNames;

  const NewPlayerDialog(
      {Key key, this.addPlayerCallback, this.existingPlayerNames})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      NewPlayerDialogState(addPlayerCallback, existingPlayerNames);
}

class NewPlayerDialogState extends State<NewPlayerDialog> {
  final addPlayerCallback;
  final existingPlayerNames;

  TextEditingController _addPlayerTextController;

  NewPlayerDialogState(this.addPlayerCallback, this.existingPlayerNames);

  @override
  void initState() {
    super.initState();
    _addPlayerTextController = TextEditingController();
  }

  @override
  void dispose() {
    _addPlayerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Enter new player's name"),
      content: TextFormField(
        decoration: InputDecoration(
          hintText: "New Player Name",
          labelText: "New Player Name",
        ),
        autofocus: true,
        autovalidate: true,
        autocorrect: false,
        validator: _validatePlayerName,
        onFieldSubmitted: (_) => _submit(),
        controller: _addPlayerTextController,
        textInputAction: TextInputAction.done,
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

  void _submit() {
    String proposedName = _addPlayerTextController.text;
    if (_validatePlayerName(proposedName) == null) {
      addPlayerCallback(proposedName);
      _addPlayerTextController.clear();
      Navigator.of(context).pop();
    }
  }

  String _validatePlayerName(String proposedName) {
    if (List.castFrom(existingPlayerNames).contains(proposedName))
      return "Player already exists";
    // TODO this pops error text on first open. How can we not?
    if (proposedName.isEmpty) return "Name must not be blank";
    return null;
  }
}
