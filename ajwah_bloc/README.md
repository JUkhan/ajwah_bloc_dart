# ajwah_bloc

A reactive state management library. Manage your application's states, effects, and actions easy way.
Make apps more scalable with a unidirectional data-flow.

- **[ajwah_bloc_test](https://pub.dev/packages/ajwah_bloc_test)**
- **[mono_state](https://pub.dev/packages/mono_state)**

### Counter State

```dart
class CounterStateController extends StateController<int> {

  CounterStateController() : super(0);

  void increment() {
    emit(state + 1);
  }

  void decrement() {
    emit(state - 1);
  }

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
          RaisedButton(
            child: Text('inc'),
            onPressed: controller.increment,
          ),
          RaisedButton(
            child: Text('dec'),
            onPressed: controller.decrement,
          ),
          StreamBuilder(
            stream: controller.stream$,
            initialData: 0,
            builder: (context, snapshot) {
              return Container(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(snapshot.data.toString()),
              );
            },
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
  Future<State> remoteState<Controller, State>()
  void dispose()
```
