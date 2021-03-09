import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CounterStateController controller;
  setUp(() {
    controller = CounterStateController();
  });

  tearDown(() {
    controller.dispose();
  });

  ajwahTest<int>(
    'Initial state value should be 2',
    build: () => controller.stream$,
    expect: [2],
  );

  ajwahTest<int>('increment',
      build: () => controller.stream$,
      act: () => controller.increment(),
      expect: [3]);

  ajwahTest<int>('decrement',
      build: () => controller.stream$,
      act: () => controller.decrement(),
      expect: [1]);
}
