import 'package:hive/hive.dart';
import 'package:novaplay/core/constants/app_constants.dart';

/// Persists retention state — daily streak, missions, achievements, wheel/chest
/// cooldowns — to the Hive `rewards` box. A null [_box] uses an in-memory store
/// (tests), so reads/writes still round-trip.
class RewardsRepository {
  RewardsRepository(this._box);

  final Box<Object>? _box;
  final Map<String, Object> _memory = {};

  Object? _get(String key) => _box != null ? _box.get(key) : _memory[key];

  Future<void> _put(String key, Object value) async {
    if (_box != null) {
      await _box.put(key, value);
    } else {
      _memory[key] = value;
    }
  }

  int _getInt(String key, [int fallback = 0]) => _get(key) as int? ?? fallback;

  // Daily reward / streak.
  int get dailyStreak => _getInt('daily_streak');
  int get dailyLastClaimDay => _getInt('daily_last_claim_day');
  Future<void> setDaily(int streak, int lastClaimDay) async {
    await _put('daily_streak', streak);
    await _put('daily_last_claim_day', lastClaimDay);
  }

  // Missions (per-day counters + claimed ids).
  int get missionDay => _getInt('mission_day');
  int missionCounter(String key) => _getInt('mission_$key');
  List<String> get missionsClaimed =>
      (_get('missions_claimed') as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList();
  Future<void> setMissionDay(int day) => _put('mission_day', day);
  Future<void> setMissionCounter(String key, int value) =>
      _put('mission_$key', value);
  Future<void> setMissionsClaimed(List<String> ids) =>
      _put('missions_claimed', ids);

  // Achievements (claimed ids).
  List<String> get achievementsClaimed =>
      (_get('ach_claimed') as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList();
  Future<void> setAchievementsClaimed(List<String> ids) =>
      _put('ach_claimed', ids);

  // Lucky wheel / chest cooldowns (epoch-day of last free use).
  int get wheelLastDay => _getInt('wheel_last_day');
  Future<void> setWheelLastDay(int day) => _put('wheel_last_day', day);
  int get chestLastDay => _getInt('chest_last_day');
  Future<void> setChestLastDay(int day) => _put('chest_last_day', day);

  // Daily challenge (epoch-day it was last completed).
  int get challengeLastDay => _getInt('challenge_last_day');
  Future<void> setChallengeLastDay(int day) => _put('challenge_last_day', day);

  // In-app review prompt (smart gating — docs/RELEASE_PLAN.md ASO).
  bool get reviewRequested => _getInt('review_requested') == 1;
  int get reviewLastPromptLevel => _getInt('review_last_prompt_level');
  Future<void> setReviewRequested({required bool requested}) =>
      _put('review_requested', requested ? 1 : 0);
  Future<void> setReviewLastPromptLevel(int level) =>
      _put('review_last_prompt_level', level);
}

/// Opens (or reuses) the rewards box, opened at bootstrap.
Box<Object> rewardsBox() => Hive.box<Object>(HiveBoxes.rewards);
