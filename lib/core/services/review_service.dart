import 'package:in_app_review/in_app_review.dart';

/// Wraps the platform "rate this app" flow. Swappable so the request can be
/// no-op'd on web/tests and the decision logic (`ReviewGate`) stays pure.
abstract interface class ReviewService {
  /// Shows the in-context review dialog if the OS allows it. The OS owns the
  /// final say (and rate-limits), so this may silently do nothing.
  Future<void> requestReview();

  /// Opens the full store listing (e.g. from a Settings "Rate us" entry).
  Future<void> openStoreListing();
}

/// Real implementation backed by the `in_app_review` plugin.
class InAppReviewService implements ReviewService {
  InAppReviewService([InAppReview? api]) : _api = api ?? InAppReview.instance;

  final InAppReview _api;

  @override
  Future<void> requestReview() async {
    if (await _api.isAvailable()) {
      await _api.requestReview();
    }
  }

  @override
  Future<void> openStoreListing() => _api.openStoreListing();
}

/// No-op used on web and in tests, and until store IDs are configured.
class NoopReviewService implements ReviewService {
  const NoopReviewService();

  @override
  Future<void> requestReview() async {}

  @override
  Future<void> openStoreListing() async {}
}
