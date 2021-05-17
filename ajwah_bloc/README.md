# ajwah_bloc

Reactive state management library. Manage your application's states, effects, and actions easy way.
Make apps more scalable with a unidirectional data-flow.

- **[ajwah_bloc_test](https://pub.dev/packages/ajwah_bloc_test)**

Please head over to the [Example](https://github.com/JUkhan/ajwah_bloc_dart/tree/master/ajwah_bloc/example) . The example contains `counter` and `todos` pages to demonstrate ajwah_bloc lib out of the box.

### Counter State

```dart
class CounterStateController extends StateController<int> {

  CounterStateController() : super(0);

  inc() {
    emit(state + 1);
  }

  dec() {
    emit(state - 1);
  }

  asyncInc() async {
    dispatch(Action(type: 'start'));
    await Future.delayed(const Duration(seconds: 1));
    inc();
  }

  Stream<String> get count$ => Rx.merge([
        action$.whereType('start').mapTo('loading...'),
        stream$.map((count) => '$count'),
      ]).asBroadcastStream();

}

```

### Consuming State

```dart

final controller = CounterStateController();

class CounterWidget extends StatelessWidget {
  const CounterWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text('inc'),
            onPressed: controller.inc,
          ),
          ElevatedButton(
            child: Text('dec'),
            onPressed: controller.dec,
          ),
          ElevatedButton(
            child: Text('async(+)'),
            onPressed: controller.asyncInc,
          ),
          StreamBuilder(
            stream: controller.count$,
            initialData: '',
            builder: (context, snapshot) =>Text(snapshot.data)
          ),
        ],
      ),
    );
  }
}

```

### Testing

```dart

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

```

### Api

```dart

  Actions get action$
  void dispatch(Action action)
  void onAction(Action action)
  void onInit()
  S get state
  Stream<S> get stream$
  Stream<T> select<T>(T Function(S state) mapCallback)
  void emit(S newState)
  void registerEffects(Iterable<Stream<Action>> callbackList)
  void importState(S state)
  void dispose()
```
