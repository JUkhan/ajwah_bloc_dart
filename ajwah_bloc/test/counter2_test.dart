import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import 'package:test/test.dart';

import 'counterController.dart';

void main() {
  Counter2State? controller;
  setUp(() {
    controller = Counter2State();
  });

  tearDown(() {
    controller?.dispose();
  });

  ajwahTest<String>(
    'Initial state counter2 controller',
    build: () => controller!.count$,
    expect: [isA<String>()],
    verify: (state) {
      expect(state[0], '0');
    },
  );
  ajwahTest<String>(
    'inc',
    build: () => controller!.count$,
    act: () => controller?.inc(),
    expect: [isA<String>()],
    skip: 1,
    verify: (state) {
      expect(state[0], '1');
    },
  );
  ajwahTest<String>(
    'dec',
    build: () => controller!.count$,
    act: () => controller?.dec(),
    expect: [isA<String>()],
    skip: 1,
    verify: (state) {
      expect(state[0], '-1');
    },
  );
  ajwahTest<String>(
    'async inc',
    build: () => controller!.count$,
    act: () => controller?.asyncInc(),
    //expect: [isA<String>(), isA<String>()],
    skip: 1,
    wait: const Duration(milliseconds: 10),

    verify: (state) {
      expect(state[0], 'loading...');
      expect(state[1], '1');
    },
  );
}
