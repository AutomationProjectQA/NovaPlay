/// One ranked row in a leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.isPlayer,
  });

  final int rank;
  final String name;
  final int score;
  final bool isPlayer;
}

/// App-owned leaderboard interface (docs/CONCEPT.md §8). The local implementation
/// ranks the player against a fixed field; a Firestore-backed implementation
/// replaces it when the backend is connected (see SETUP.md).
// Interface kept for the local/Firestore swap (see SETUP.md), not collapsed.
// ignore: one_member_abstracts
abstract interface class LeaderboardService {
  /// Returns the ranked board with the player inserted by [playerScore].
  List<LeaderboardEntry> board({
    required int playerScore,
    required String playerName,
  });
}

/// A deterministic local leaderboard: the player ranked among a fixed field of
/// rivals. Lets the feature ship and demo without a backend.
class LocalLeaderboardService implements LeaderboardService {
  static const List<(String, int)> _rivals = [
    ('Nova Prime', 300),
    ('Cosmo', 240),
    ('Lyra', 195),
    ('Orion', 160),
    ('Vega', 130),
    ('Astra', 100),
    ('Comet', 72),
    ('Pixel', 48),
    ('Nyx', 24),
  ];

  @override
  List<LeaderboardEntry> board({
    required int playerScore,
    required String playerName,
  }) {
    final rows = [
      ..._rivals.map((r) => (name: r.$1, score: r.$2, isPlayer: false)),
      (name: playerName, score: playerScore, isPlayer: true),
    ]..sort((a, b) => b.score.compareTo(a.score));

    return [
      for (var i = 0; i < rows.length; i++)
        LeaderboardEntry(
          rank: i + 1,
          name: rows[i].name,
          score: rows[i].score,
          isPlayer: rows[i].isPlayer,
        ),
    ];
  }
}
