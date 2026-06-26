import 'package:equatable/equatable.dart';

/// Base type for recoverable, user-facing errors crossing the domain/data
/// boundary (docs/ARCHITECTURE.md §15). Never thrown — returned via `Result`.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

/// A failure originating from local storage (Hive / preferences).
class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.cause});
}

/// A failure originating from a network/Firebase call.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause});
}

/// A failure loading or validating bundled level assets.
class LevelDataFailure extends Failure {
  const LevelDataFailure(super.message, {super.cause});
}

/// A catch-all for unexpected errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.cause});
}
