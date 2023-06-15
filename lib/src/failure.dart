/// Represents a failure.
abstract interface class Failure implements Exception {
  /// Represents the message of this failure.
  String? get message;

  /// Represents the previous failure / exception / whatever that caused this failure.
  Object? get cause;

  /// Creates a failure with the given [message] and [cause].
  const factory Failure({String? message, Object? cause}) = _Failure;
}

class _Failure implements Failure {
  @override
  final String? message;

  @override
  final Object? cause;

  const _Failure({
    this.message,
    this.cause,
  });
}

extension FailureX on Failure {
  void forEach(
    void Function(Object) action, {
    void Function(Failure failure)? failureAction,
  }) {
    if (failureAction != null) {
      failureAction(this);
    } else {
      action(this);
    }
    Object target = this;
    while (target is Failure && target.cause != null) {
      if (failureAction != null && target.cause is Failure) {
        failureAction(target.cause as Failure);
      } else {
        action(target.cause!);
      }
      target = target.cause!;
    }
  }
}

extension ObjectX on Object {
  Failure fail() {
    return Failure(cause: this);
  }
}
