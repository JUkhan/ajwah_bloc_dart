import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CounterStateController controller;
  setUp(() {
    controller = CounterStateController();
  });

  tearDown(() {});

  ajwahTest<int>(
    'Initial state value should be 2',
    build: () => controller.stream$,
    expect: [isA<int>()],
    verify: (state) {
      expect(2, state[0]);
    },
  );

  ajwahTest<int>(
    'increment',
    build: () => controller.stream$,
    act: () => controller.increment(),
    expect: [isA<int>()],
    verify: (state) {
      expect(3, state[0]);
    },
  );

  ajwahTest<int>(
    'decrement',
    build: () => controller.stream$,
    act: () => controller.decrement(),
    expect: [isA<int>()],
    verify: (state) {
      expect(1, state[0]);
    },
  );
}
