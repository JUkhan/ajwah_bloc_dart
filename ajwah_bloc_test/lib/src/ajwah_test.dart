import 'dart:async';

import 'package:meta/meta.dart';
import 'package:test/test.dart' as test;

/// [ajwahStore] must notify it's subscriber with it's current state when subscription
/// point start listening.
///
/// Creates a new test case with the given [description].
/// [ajwahTest] will handle asserting that the `store` emits the [expect]ed
/// states (in order) after [act] is executed.

///
/// [build] should be used for initialization and preparation
/// and must return part of the `stream` under test.
///
/// [act] is an optional callback which will be invoked to dispatch action/s under
/// test.
///
/// [skip] is an optional `int` which can be used to skip any number of states.
/// [skip] defaults to 0.
///
/// [wait] is an optional `Duration` which can be used to wait for
/// async operations within the `store` such as `debounceTime`.
///
/// [expect] is an optional `Iterable` of matchers which is expected to emit after
/// [act] is executed.
///
/// [verify] is an optional callback which is invoked after [expect]
/// and can be used for additional verification/assertions.
/// [verify] is called with the emited `list of state`.
///
/// [tearDown] is an optional callback for clean up if you want.
///
/// [log] is an optional callback which is invoked before [expect].
/// [log] is called with the emited `list of state`.
///
/// ```dart
/// ajwahTest(
///   'CounterState emits [1] when `dispatch('inc')`',
///   build: () => select('counter'),
///   act: () => dispatch('inc'),
///   expect: [0, 1],
/// );
/// ```
///
/// [ajwahTest] can also be used to test the initial state of the `counter` state
/// by omitting [act].
///
/// ```dart
/// ajwahTest(
///   'CounterState emits [0] when nothing is called',
///   build: () => select('counter'),
///   expect: [0],
/// );
/// ```
///
/// [ajwahTest] can also be used to [skip] any number of emitted states
/// before asserting against the expected states.
/// [skip] defaults to 0.
///
/// ```dart
/// ajwahTest(
///   'CounterState emits [2] when dispatch `inc` action twice',
///   build: () => select('counter'),
///   act: () {
///     dispatch('inc');
///     dispatch('inc');
///   },
///   skip: 2,
///   expect: [2],
/// );
/// ```
///
/// [ajwahTest] can also be used to wait for async operations
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// ajwahTest(
///   'CounterState emits [1] when dispatch `inc` action',
///   build: () => select('counter'),
///   act: () => dispatch('inc'),
///   wait: const Duration(milliseconds: 300),
///   expect: [0,1],
/// );
/// ```
///
/// [ajwahTest] can also be used to [verify] internal stream functionality.
///
/// ```dart
/// ajwahTest(
///   'CounterState emits [1] when dispatch `inc` action',
///   build: () => select('counter'),
///   act: () => dispatch('inc'),
///   expect: [0, 1],
///   verify: (_) {
///     verify(repository.someMethod(any)).called(1);
///   }
/// );
/// ```
///
/// **Note:** when using [ajwahTest] with state classes which don't override
/// `==` and `hashCode` you can provide an `Iterable` of matchers instead of
/// explicit state instances.
///
/// ```dart
/// ajwahTest(
///  'emits [CounterModel] when dispatch `inc` action',
///  build: () => select('counter'),
///  act: () =>  dispatch('inc'),
///  expect: [isA<CounterModel>()],
/// );
/// ```
@isTest
void ajwahTest<State>(
  String description, {
  @required Stream<State> Function() build,
  Function act,
  Duration wait,
  int skip = 0,
  Iterable expect,
  Function(List<State> models) verify,
  Iterable errors,
  Function tearDown,
  Function(List<State> models) log,
}) {
  test.test(description, () async {
    await runAjwahTest<State>(
      description,
      build: build,
      act: act,
      wait: wait,
      skip: skip,
      expect: expect,
      verify: verify,
      errors: errors,
      tearDown: tearDown,
      log: log,
    );
  });
}

/// Internal [ajwahTest] runner which is only visible for testing.
/// This should never be used directly -- please use [ajwahTest] instead.
@visibleForTesting
Future<void> runAjwahTest<State>(
  String description, {
  @required Stream<State> Function() build,
  Function act,
  Duration wait,
  int skip = 0,
  Iterable expect,
  Function(List<State> models) verify,
  Iterable errors,
  Function tearDown,
  Function(List<State> models) log,
}) async {
  final unhandledErrors = <Object>[];
  await runZoned(
    () async {
      final states = <State>[];
      final stream = build();
      final subscription = stream.skip(skip).listen(states.add);
      await act?.call();
      if (wait != null) await Future<void>.delayed(wait);
      await Future<void>.delayed(Duration.zero);
      await log?.call(states);
      if (expect != null) test.expect(states, expect);
      await subscription.cancel();
      await verify?.call(states);
      await tearDown?.call();
    },
    onError: (Object error) {
      unhandledErrors.add(error);
    },
  );
  if (errors != null) test.expect(unhandledErrors, errors);
}
