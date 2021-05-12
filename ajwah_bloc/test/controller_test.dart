import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import 'package:test/test.dart';

import 'counterController.dart';

void main() {
  CounterStateController? controller;
  setUp(() {
    controller = CounterStateController();
  });

  tearDown(() {
    controller?.dispose();
  });

  ajwahTest<int>(
    'Initial state',
    build: () => controller!.stream$,
    expect: [isA<int>()],
    verify: (state) {
      expect(state[0], 0);
    },
  );

  ajwahTest<int>(
    'increment',
    build: () => controller!.stream$,
    act: () => controller?.increment(),
    skip: 1,
    expect: [isA<int>()],
    verify: (state) {
      expect(state[0], 1);
    },
  );

  ajwahTest<int>(
    'decrement',
    build: () => controller!.stream$,
    act: () => controller?.decrement(),
    skip: 1,
    expect: [isA<int>()],
    verify: (state) {
      expect(state[0], -1);
    },
  );
}
