import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
  State<StatefulWidget> createState() => ScorePadFabState();
}

class ScorePadFabState extends State<ScorePadFab> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      closeManually: true,
      // TODO create custom animated icon?
      animatedIcon: AnimatedIcons.menu_arrow,
      children: [
        SpeedDialChild(
          child: Icon(Icons.person),
          label: 'Player',
          onTap: widget.newPlayerCallback,
        ),
        SpeedDialChild(
          child: Icon(Icons.plus_one),
          label: 'Round',
          onTap: widget.newRoundCallback,
        ),
        SpeedDialChild(
          child: Icon(Icons.refresh),
          label: 'Restart Game',
          onTap: widget.restartGameCallback,
        ),
      ],
    );
  }
}
