import 'package:ajwah_bloc/src/action.dart';
import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import 'package:test/test.dart';

import 'counterController.dart';

void main() {
  new RemoteController();
  CounterStateController? controller;
  setUp(() {
    controller = CounterStateController();
  });

  tearDown(() {
    controller?.dispose();
  });

  ajwahTest<CounterState>(
    'Initial state',
    build: () => controller!.stream$,
    expect: [isA<CounterState>()],
    verify: (state) {
      expect(state[0].count, 0);
      expect(state[0].loading, false);
    },
  );

  ajwahTest<CounterState>(
    'increment',
    build: () => controller!.stream$,
    act: () => controller?.increment(),
    skip: 1,
    expect: [isA<CounterState>()],
    verify: (state) {
      expect(state[0].count, 1);
      expect(state[0].loading, false);
    },
  );

  ajwahTest<CounterState>(
    'decrement',
    build: () => controller!.stream$,
    act: () => controller?.decrement(),
    skip: 1,
    expect: [isA<CounterState>()],
    verify: (state) {
      expect(state[0].count, -1);
      expect(state[0].loading, false);
    },
  );
  ajwahTest<CounterState>(
    'async increment',
    build: () => controller!.stream$,
    act: () => controller?.asyncInc(),
    skip: 1,
    expect: [isA<CounterState>(), isA<CounterState>()],
    verify: (state) {
      expect(state[0].count, 0);
      expect(state[0].loading, true);
      expect(state[1].count, 1);
      expect(state[1].loading, false);
    },
  );
  ajwahTest<CounterState>(
    'dispatch action',
    build: () => controller!.stream$,
    act: () => controller!.dispatch(IncrementByAction(10)),
    skip: 1,
    expect: [isA<CounterState>()],
    verify: (state) {
      expect(state[0].count, 10);
      expect(state[0].loading, false);
    },
  );

  ajwahTest<int>(
    'select(state=>state.count)',
    build: () => controller!.select((state) => state.count),
    act: () => controller!.dispatch(IncrementByAction(101)),
    skip: 1,
    expect: [isA<int>()],
    verify: (state) {
      expect(state[0], 101);
    },
  );
  ajwahTest<CounterState>(
    'Import State',
    build: () => controller!.stream$,
    act: () => controller!.importState(CounterState(3, false)),
    skip: 1,
    expect: [isA<CounterState>()],
    verify: (state) {
      expect(state[0].count, 3);
    },
  );
  ajwahTest<IncrementByAction>(
    'action handler isA',
    build: () => controller!.action$.isA<IncrementByAction>(),
    act: () {
      controller!.dispatch(IncrementByAction(3));
    },
    expect: [isA<IncrementByAction>()],
    verify: (models) {
      expect(models[0].num, 3);
    },
  );
  ajwahTest<Action>(
    'action handler whereType',
    build: () => controller!.action$.whereType('mono'),
    act: () {
      controller!.dispatch(Action(type: 'mono'));
    },
    expect: [isA<Action>()],
    verify: (models) {
      expect(models[0].type, 'mono');
    },
  );

  ajwahTest<Action>(
    'action handler whereTypes',
    build: () => controller!.action$.whereTypes(['monoX', 'mono']),
    act: () {
      controller!.dispatch(Action(type: 'mono'));
    },
    expect: [isA<Action>()],
    verify: (models) {
      expect(models[0].type, 'mono');
    },
  );
  ajwahTest<Action>(
    'action handler where',
    build: () => controller!.action$.where((action) => action.type == 'mono'),
    act: () {
      controller!.dispatch(Action(type: 'mono'));
    },
    expect: [isA<Action>()],
    verify: (models) {
      expect(models[0].type, 'mono');
    },
  );
  // test('get Remote state', () async {
  //   var state = await controller!.remoteState<RemoteController, String>();
  //   expect(state, 'REMOTE STATE');
  // });
  ajwahTest<Action>(
    'effect: send Action(testing) that response back Action(done)',
    build: () => controller!.action$.whereType('done'),
    act: () {
      controller!.dispatch(Action(type: 'testing'));
    },
    expect: [isA<Action>()],
    verify: (models) {
      expect(models[0].type, 'done');
    },
  );
  ajwahTest<CounterState>(
    'dispose',
    build: () => controller!.stream$,
    act: () {
      controller!.dispose();
      controller!.dispatch(Action(type: 'inc'));
    },
    expect: [isA<CounterState>()],
    verify: (models) {
      expect(models.length, 1);
      expect(models[0].count, 0);
      expect(models[0].loading, false);
    },
  );
}
