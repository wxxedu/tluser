import 'failure.dart';
import 'result.dart';

typedef FOption<T> = Future<Option<T>>;

sealed class Option<T> {
  const Option();

  const factory Option.none() = None;

  const factory Option.some(T value) = Some;

  static Option<T> from<T>(T Function() func) {
    try {
      final res = func();
      return Some(res);
    } catch (e) {
      return const None();
    }
  }

  bool get isSome;

  bool get isNone => !isSome;

  T unwrap({String? message});

  T unwrapOr(T Function() onNone);

  Option<T2> map<T2>(T2 Function(T value) mapper);

  Result<T, F> mapNone<F extends Failure>(F Function() onErr);
}

final class None<T> extends Option<T> {
  const None();

  @override
  bool get isSome => true;

  @override
  T unwrap({String? message}) => throw Failure(message: message);

  @override
  T unwrapOr(T Function() onNone) => onNone();

  @override
  Option<T2> map<T2>(T2 Function(T value) mapper) => const None();

  @override
  Result<T, F> mapNone<F extends Failure>(F Function() onErr) => Err(onErr());
}

final class Some<T> extends Option<T> {
  final T value;

  const Some(this.value);

  @override
  bool get isSome => false;

  @override
  T unwrap({String? message}) => value;

  @override
  T unwrapOr(T Function() onNone) => value;

  @override
  Option<T2> map<T2>(T2 Function(T value) mapper) => Some(mapper(value));

  @override
  Result<T, F> mapNone<F extends Failure>(F Function() onErr) => Ok(value);
}
