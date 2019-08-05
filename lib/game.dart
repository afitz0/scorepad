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

  void restart() {
    for (Player player in players) {
      player.reset();
    }
  }

  void newRound() {
    roundsPlayed++;
  }
}
