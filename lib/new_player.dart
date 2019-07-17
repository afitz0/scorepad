import 'package:flutter/material.dart';

class NewPlayerDialog extends StatefulWidget {
  final addPlayerCallback;

  const NewPlayerDialog({Key key, this.addPlayerCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewPlayerDialogState();
}

class NewPlayerDialogState extends State<NewPlayerDialog> {
  TextEditingController _addPlayerTextController;
  bool _userHasEditted;

  @override
  void initState() {
    super.initState();
    _addPlayerTextController = TextEditingController();
    _userHasEditted = false;
    _addPlayerTextController.addListener(_listener);
  }

  void _listener() {
    // On first load, listener gets called. At that time, the field is empty
    // and no changes have been made. The  _very next_ thing the user can do is
    // either (a) cancel/dismiss or (b) make the field not empty. However, they
    // can in the future make it empty again, so we have to check both.

    // See https://github.com/flutter/flutter/issues/18885
    if (_addPlayerTextController.text.isEmpty && !_userHasEditted) return;
    _userHasEditted = true;
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
          hintText: "(must not be blank)",
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
    if (_validatePlayerName(proposedName, submitCheck: true) == null) {
      widget.addPlayerCallback(proposedName);
      _addPlayerTextController.clear();
      Navigator.of(context).pop();
    }
  }

  String _validatePlayerName(String proposedName, {bool submitCheck = false}) {
    if (_userHasEditted || submitCheck) {
      if (proposedName.isEmpty) return "Name must not be blank";
    }
    return null;
  }
}
