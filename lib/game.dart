import 'player.dart';

class Game {
  List<Player> players;

  int roundsPlayed;

  Game() {
    init();
  }

  void init() {
    players = <Player>[];
    roundsPlayed = 0;
  }

  List<String> getPlayerNames() {
    List<String> playerNames = <String>[];
    for (Player player in players) {
      playerNames.add(player.name);
    }
    return playerNames;
  }

  Player getPlayerByIndex(int index) {
    return players[index];
  }

  void restart() {
    for (Player player in players) {
      player.reset();
    }
  }

  void newRound() {
    roundsPlayed++;
  }

  /// Checks to see whether we can consider this game to be "in progress"
  /// or otherwise resumable. A game that was never played is not resumable.
  bool isInProgress() {
    return players.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
        'players': List.generate(players.length, (int index) => {
          players[index].toJson()
        }),
        'roundsPlayed': roundsPlayed,
      };

  Game.fromJson(Map<String, dynamic> json)
      : roundsPlayed = json['roundsPlayed'],
        players = json['players'];
}
