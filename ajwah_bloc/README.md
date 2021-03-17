# ajwah_bloc

A reactive state management library. Manage your application's states, effects, and actions easy way.
Make apps more scalable with a unidirectional data-flow.

- **[ajwah_bloc_test](https://pub.dev/packages/ajwah_bloc_test)**

Define a state controller class

```dart
class CounterStateController extends StateController<int> {
  CounterStateController() : super(stateName: 'counter', initialState: 2);

  void increment() {
    emit(state + 1);
  }

  void decrement() {
    emit(state - 1);
  }
}

```

Consuming state

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
            initialData: controller.currentState,
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

**Testing:** We need to add the testing dependency `ajwah_bloc_test`

**Testing counter controller**

```dart
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

```

### Api

```dart
  //global api
  Actions get action$
  void dispatch(Action action)
  //StateController api
  void onAction(S state, Action action)
  void onInit()
  S get state
  Stream<S> get stream$
  Stream<T> select<T>(T Function(S state) mapCallback)
  void emit(S newState)
  void registerEffects(Iterable<Stream<Action>> callbackList)
  Stream<List<dynamic>> exportState()
  void importState(S state)
  Future<State> remoteState<State>(String stateName)
  void dispose()
```
