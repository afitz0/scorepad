class Player {
  // The player's name, arbitrary string.
  // TODO should names have a length limit?
  final String name;

  // This player's unique ID.
  final int id;

  // The round in which this player joined the game. Usually 1, but doesn't have to be. Modifier for all indices in scores.
  int firstRound;

  // This player's current total score. Maintained separately so that we can compute/return in constant time.
  double _totalScore;

  // This player's scores
  Map<int, double> _scores;

  Player({this.name, this.firstRound = 1, this.id}) {
    _scores = {};
    _totalScore = 0;
  }

  void addScore({double score, int round}) {
    assert(score != null, "Score must not be null");
    assert(round != null, "Round must not be null");

    _totalScore += score;
    if (_scores.containsKey(round)) {
      _totalScore -= _scores[round];
    }
    
    _scores[round] = score;
  }

  double getScore(int round) {
    if (_scores.containsKey(round)) {
      return _scores[round];
    } else {
      return null;
    }
  }

  double getTotalScore() {
    return _totalScore;
  }

  void reset() {
    firstRound = 0;
    _totalScore = 0;
    _scores.clear();
  }
}
